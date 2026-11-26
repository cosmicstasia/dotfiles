/**
 * Pretty Footer
 *
 * Replaces Pi's built-in footer with a compact, themed one:
 *
 *   ~/Work/comp-sci   main · refactor-auth
 *   ↑1.2M ↓60k   cache 79%   $0.083        ▰▰▱▱▱▱▱▱ 24%/200k · deepseek-v4.1-flash high
 *
 * Path tail and model are accent/bold, numbers are muted, and the context
 * meter carries the color (green → amber → red). Detail drops out on narrow
 * terminals, and extension statuses keep their own line.
 *
 * `/footer` toggles between this footer and Pi's built-in one.
 */

import type {
	ExtensionAPI,
	ExtensionContext,
	ReadonlyFooterDataProvider,
	Theme,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const BRANCH_GLYPH = "\uE725"; // Nerd Font branch
const GAP = "   ";
const SEP = "  ·  ";

type Totals = {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: number;
};

type ContextUsage = { tokens: number | null; contextWindow: number; percent: number | null };

type Stats = { key: string; totals: Totals; hitRate?: number; usage?: ContextUsage };

type TuiHandle = { requestRender(): void };

/** Usage shape from providers: every field optional, cost sometimes nested. */
type AnyUsage = {
	input?: number;
	output?: number;
	cacheRead?: number;
	cacheWrite?: number;
	cost?: { total?: number } | number;
};

function addUsage(totals: Totals, usage: AnyUsage | undefined): void {
	if (!usage) return;
	totals.input += usage.input ?? 0;
	totals.output += usage.output ?? 0;
	totals.cacheRead += usage.cacheRead ?? 0;
	totals.cacheWrite += usage.cacheWrite ?? 0;
	const cost = typeof usage.cost === "number" ? usage.cost : usage.cost?.total;
	totals.cost += cost ?? 0;
}

function formatTokens(n: number): string {
	if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
	if (n >= 10_000) return `${Math.round(n / 1000)}k`;
	if (n >= 1_000) return `${(n / 1000).toFixed(1)}k`;
	return `${n}`;
}

function formatCost(cost: number): string {
	return cost < 0.1 ? `$${cost.toFixed(3)}` : `$${cost.toFixed(2)}`;
}

function splitPath(cwd: string, home: string | undefined): { prefix: string; name: string } {
	let path = cwd;
	if (home && (path === home || path.startsWith(`${home}/`))) {
		path = `~${path.slice(home.length)}`;
	} else if (path.length > 1 && path.endsWith("/")) {
		path = path.slice(0, -1);
	}
	const index = path.lastIndexOf("/");
	if (index <= 0) return { prefix: "", name: path };
	return { prefix: path.slice(0, index + 1), name: path.slice(index + 1) };
}

function usageTone(percent: number): "success" | "warning" | "error" {
	if (percent > 85) return "error";
	if (percent > 60) return "warning";
	return "success";
}

function contextBar(theme: Theme, percent: number, cells: number): string {
	const clamped = Math.max(0, Math.min(100, percent));
	const filled = Math.round((clamped / 100) * cells);
	return (
		theme.fg(usageTone(clamped), "▰".repeat(filled)) +
		theme.fg("dim", "▱".repeat(cells - filled))
	);
}

/** Shortest useful rendering of a model id: drop any provider-ish prefix. */
function modelTail(id: string): string {
	const index = id.lastIndexOf("/");
	return index === -1 ? id : id.slice(index + 1);
}

export default function (pi: ExtensionAPI) {
	let current: ExtensionContext | undefined;
	let tui: TuiHandle | undefined;
	let custom = true;
	let cache: Stats | undefined;

	function collectStats(ctx: ExtensionContext): Stats {
		const sessionManager = ctx.sessionManager;
		const entries = sessionManager.getEntries();
		const key = `${sessionManager.getSessionId()}:${sessionManager.getLeafId()}:${entries.length}`;
		if (cache?.key === key) return cache;

		const totals: Totals = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0 };
		let hitRate: number | undefined;

		for (const entry of entries) {
			if (entry.type === "usage") {
				addUsage(totals, (entry as { usage?: AnyUsage }).usage);
			} else if (entry.type === "message" && entry.message.role === "assistant") {
				const usage = entry.message.usage as AnyUsage | undefined;
				addUsage(totals, usage);
				const promptTokens = (usage?.input ?? 0) + (usage?.cacheRead ?? 0) + (usage?.cacheWrite ?? 0);
				if (promptTokens > 0) {
					hitRate = ((usage?.cacheRead ?? 0) / promptTokens) * 100;
				}
			} else if (entry.type === "message" && entry.message.role === "toolResult") {
				addUsage(totals, (entry.message as { usage?: AnyUsage }).usage);
			} else if (entry.type === "branch_summary" || entry.type === "compaction") {
				addUsage(totals, (entry as { usage?: AnyUsage }).usage);
			}
		}

		cache = { key, totals, hitRate, usage: ctx.getContextUsage() as ContextUsage | undefined };
		return cache;
	}

	function renderFooter(
		theme: Theme,
		footerData: ReadonlyFooterDataProvider,
		width: number,
	): string[] {
		const ctx = current;
		if (!ctx) return [""];

		const lines: string[] = [];

		// Path · branch · session name
		const { prefix, name } = splitPath(ctx.sessionManager.getCwd(), process.env.HOME);
		let title = theme.fg("dim", prefix) + theme.bold(theme.fg("accent", name));
		const branch = footerData.getGitBranch();
		if (branch) {
			title += theme.fg("muted", `  ${BRANCH_GLYPH} ${branch}`);
		}
		const sessionName = ctx.sessionManager.getSessionName();
		if (sessionName) {
			title += theme.fg("dim", `${SEP}${sessionName}`);
		}
		lines.push(truncateToWidth(title, width));

		// Context meter / model, richest first. Narrow lines fall back to a
		// bare percentage and a shortened model id.
		const stats = collectStats(ctx);
		const usage = stats.usage;
		const meterVariants: string[] = [];
		if (usage) {
			const window = formatTokens(usage.contextWindow);
			if (usage.percent !== null) {
				const percent = Math.max(0, Math.min(100, usage.percent));
				const label = theme.fg(usageTone(percent), `${percent.toFixed(0)}%`) + theme.fg("dim", `/${window}`);
				const cells = width >= 100 ? 8 : width >= 80 ? 6 : 4;
				meterVariants.push(`${contextBar(theme, percent, cells)} ${label}`);
				meterVariants.push(label);
			} else {
				meterVariants.push(theme.fg("dim", `ctx ?/${window}`));
			}
		}
		meterVariants.push("");

		const model = ctx.model;
		const level = model?.reasoning && ctx.thinkingLevel !== "off" ? ctx.thinkingLevel : undefined;
		const modelVariants: string[] = [];
		if (model) {
			// A provider-ish prefix in the id is noise; the provider is set elsewhere.
			const id = modelTail(model.id);
			const name = theme.bold(theme.fg("accent", id));
			if (level) modelVariants.push(name + theme.fg("muted", ` ${level}`));
			modelVariants.push(name);
		}
		modelVariants.push("");

		// Prefer showing the model over the context meter when space is tight,
		// and prefer the richest variant that still fits.
		const separator = theme.fg("dim", SEP);
		const rightOptions: Array<{ text: string; hasModel: boolean }> = [];
		const seen = new Set<string>();
		for (const meter of meterVariants) {
			for (const modelText of modelVariants) {
				const text = [meter, modelText].filter(Boolean).join(separator);
				if (seen.has(text)) continue;
				seen.add(text);
				rightOptions.push({ text, hasModel: modelText !== "" });
			}
		}
		rightOptions.sort((a, b) => {
			if (a.hasModel !== b.hasModel) return a.hasModel ? -1 : 1;
			return visibleWidth(b.text) - visibleWidth(a.text);
		});
		const rightVariants = rightOptions.map((option) => option.text);

		// Token/cost stats, richest first; detail drops out when the line does not fit.
		const { totals, hitRate } = stats;
		const leftParts: string[] = [];

		const tokens: string[] = [];
		if (totals.input) tokens.push(theme.fg("dim", "↑") + theme.fg("muted", formatTokens(totals.input)));
		if (totals.output) tokens.push(theme.fg("dim", "↓") + theme.fg("muted", formatTokens(totals.output)));
		if (tokens.length) leftParts.push(tokens.join(" "));

		if (hitRate !== undefined && (totals.cacheRead || totals.cacheWrite)) {
			leftParts.push(theme.fg("dim", "cache ") + theme.fg("muted", `${hitRate.toFixed(0)}%`));
		}

		if (totals.cost) {
			leftParts.push(theme.fg("warning", formatCost(totals.cost)));
		}

		// Sacrifice token/cost detail before the model or the context meter.
		let statsLine = "";
		outer: for (const right of rightVariants) {
			const rightWidth = visibleWidth(right);
			for (let keep = leftParts.length; keep >= 0; keep--) {
				const left = leftParts.slice(0, keep).join(GAP);
				const padding = width - visibleWidth(left) - rightWidth;
				if (padding >= 1) {
					statsLine = left + " ".repeat(padding) + right;
					break outer;
				}
			}
		}
		if (!statsLine) {
			statsLine = truncateToWidth(rightVariants[0] ?? "", width, theme.fg("dim", "…"));
		}
		lines.push(truncateToWidth(statsLine, width));

		// Extension statuses keep their own line, like the built-in footer.
		const statuses = footerData.getExtensionStatuses();
		if (statuses.size > 0) {
			const statusLine = Array.from(statuses.entries())
				.sort(([a], [b]) => a.localeCompare(b))
				.map(([, text]) => text.replace(/\s+/g, " ").trim())
				.filter(Boolean)
				.join(theme.fg("dim", GAP));
			if (statusLine) lines.push(truncateToWidth(statusLine, width));
		}

		return lines;
	}

	function install(ctx: ExtensionContext): void {
		ctx.ui.setFooter((footerTui, theme, footerData) => {
			tui = footerTui;
			const unsubscribe = footerData.onBranchChange(() => footerTui.requestRender());
			return {
				dispose: unsubscribe,
				invalidate() {
					cache = undefined;
				},
				render(width: number) {
					return renderFooter(theme, footerData, width);
				},
			};
		});
	}

	pi.on("session_start", async (_event, ctx) => {
		current = ctx;
		cache = undefined;
		if (ctx.mode !== "tui" || !custom) return;
		install(ctx);
	});

	pi.on("model_select", async (_event, ctx) => {
		current = ctx;
		cache = undefined;
		tui?.requestRender();
	});

	pi.on("message_end", async (_event, ctx) => {
		current = ctx;
		tui?.requestRender();
	});

	pi.on("turn_end", async (_event, ctx) => {
		current = ctx;
		tui?.requestRender();
	});

	pi.registerCommand("footer", {
		description: "Toggle the pretty footer",
		handler: async (_args, ctx) => {
			custom = !custom;
			current = ctx;
			cache = undefined;
			if (custom) {
				install(ctx);
				ctx.ui.notify("Pretty footer enabled", "info");
			} else {
				ctx.ui.setFooter(undefined);
				ctx.ui.notify("Built-in footer restored", "info");
			}
		},
	});
}
