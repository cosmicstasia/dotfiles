/**
 * Startup Header
 *
 * Replaces Pi's built-in startup header (logo + key hints) with the pi logo
 * plus project (git branch) and provider/model, without the key hints.
 *
 * `/header` toggles between this header and Pi's built-in one.
 */

import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";
import {
	backgroundAnsi,
	foregroundAnsi,
	rgbColor,
	truncateToWidth,
	visibleWidth,
} from "@earendil-works/pi-tui";

const GIT_TIMEOUT_MS = 1500;
const GIT_REFRESH_THROTTLE_MS = 3000;

// The built-in header uses these exact colors, independent of the theme.
const CORAL = rgbColor(228, 138, 122);
const BLUE = rgbColor(79, 142, 179);
const YELLOW = rgbColor(234, 182, 93);
const RESET = "\x1B[0m";

/** The two-line pi logo: coral/blue upper half block, blue/yellow lower half. */
type ColorMode = Parameters<typeof foregroundAnsi>[1];

function piLogo(mode: ColorMode): [string, string] {
	const fg = (color: typeof CORAL) => foregroundAnsi(color, mode);
	return [
		`${fg(CORAL)}${backgroundAnsi(BLUE, mode)}\u2580${RESET}${fg(CORAL)}\u2580\u2588${RESET} `,
		`${fg(BLUE)}\u2588\u2580${RESET} ${fg(YELLOW)}\u2588${RESET} `,
	];
}

interface HeaderState {
	project: string;
	branch?: string;
	model: string;
}

function basename(path: string): string {
	const parts = path.split(/[\\/]/).filter(Boolean);
	return parts.at(-1) ?? path;
}

export default function (pi: ExtensionAPI) {
	const state: HeaderState = { project: "", model: "" };
	let tui: { requestRender(): void } | undefined;
	let custom = true;
	let lastGitRefresh = 0;

	async function refreshGit(cwd: string): Promise<void> {
		lastGitRefresh = Date.now();
		try {
			const result = await pi.exec(
				"git",
				["rev-parse", "--show-toplevel", "--abbrev-ref", "HEAD"],
				{ cwd, timeout: GIT_TIMEOUT_MS },
			);
			if (result.code !== 0) {
				state.project = basename(cwd);
				state.branch = undefined;
				return;
			}
			const [top, head] = result.stdout.trim().split("\n");
			state.project = top ? basename(top) : basename(cwd);
			state.branch = head && head !== "HEAD" ? head : undefined;
		} catch {
			state.project = basename(cwd);
			state.branch = undefined;
		}
	}

	/** Project name in bold accent, branch after a muted separator. */
	function subtitle(theme: Theme): string {
		const project = theme.bold(theme.fg("accent", state.project || "pi"));
		if (!state.branch) return project;
		return `${project}${theme.fg("muted", " \u00B7 ")}${theme.fg("dim", state.branch)}`;
	}

	function renderHeader(_tui: unknown, theme: Theme) {
		// left/right on one terminal line, padded to the full width
		function join(left: string, right: string, width: number): string {
			const gap = Math.max(1, width - visibleWidth(left) - visibleWidth(right));
			return truncateToWidth(left + " ".repeat(gap) + right, width);
		}

		return {
			invalidate() {},
			render(width: number): string[] {
				const [logoTop, logoBottom] = piLogo(theme.getColorMode());
				return [
					join(logoTop + theme.fg("dim", `v${VERSION}`), theme.fg("dim", state.model), width),
					join(logoBottom + subtitle(theme), "", width),
				];
			},
		};
	}

	pi.on("session_start", async (_event, ctx) => {
		state.model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "";
		state.project = basename(ctx.cwd);
		if (ctx.mode === "tui" && custom) {
			ctx.ui.setHeader((headerTui, theme) => {
				tui = headerTui;
				return renderHeader(headerTui, theme);
			});
		}
		// Do not delay startup on git; fill in the branch when it resolves.
		await refreshGit(ctx.cwd);
		tui?.requestRender();
	});

	pi.on("model_select", async (event, _ctx) => {
		state.model = `${event.model.provider}/${event.model.id}`;
		tui?.requestRender();
	});

	// Pick up `git checkout` / branch switches made through bash.
	pi.on("tool_result", async (event, ctx) => {
		if (event.toolName !== "bash") return;
		if (Date.now() - lastGitRefresh < GIT_REFRESH_THROTTLE_MS) return;
		await refreshGit(ctx.cwd);
		tui?.requestRender();
	});

	pi.registerCommand("header", {
		description: "Toggle the custom startup header",
		handler: async (_args, ctx) => {
			custom = !custom;
			if (custom) {
				ctx.ui.setHeader((headerTui, theme) => {
					tui = headerTui;
					return renderHeader(headerTui, theme);
				});
				ctx.ui.notify("Custom header enabled", "info");
			} else {
				ctx.ui.setHeader(undefined);
				ctx.ui.notify("Built-in header restored", "info");
			}
		},
	});
}
