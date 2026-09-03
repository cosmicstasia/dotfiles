const DESTRUCTIVE_PATTERNS = [
	/\brm\b/i,
	/\brmdir\b/i,
	/\bmv\b/i,
	/\bcp\b/i,
	/\bmkdir\b/i,
	/\btouch\b/i,
	/\bchmod\b/i,
	/\bchown\b/i,
	/\bchgrp\b/i,
	/\bln\b/i,
	/\btee\b/i,
	/\btruncate\b/i,
	/\bdd\b/i,
	/\bshred\b/i,
	/(^|[^<])>(?!>)/,
	/>>/,
	/\b(npm|yarn|pnpm|bun)\s+(install|uninstall|update|ci|link|publish|add|remove|upgrade)/i,
	/\b(pip|pipx|uv)\s+(install|uninstall|sync|add|remove)/i,
	/\b(cargo|go)\s+(install|get|mod\s+tidy)/i,
	/\b(apt|apt-get|dnf|pacman|yay|paru|brew)\s+(install|remove|purge|update|upgrade|sync)/i,
	/\bgit\s+(add|commit|push|pull|merge|rebase|reset|checkout|switch|branch\s+-[dD]|stash|cherry-pick|revert|tag|init|clone|clean)/i,
	/\bsudo\b/i,
	/\bsu\b/i,
	/\bkill\b/i,
	/\bpkill\b/i,
	/\bkillall\b/i,
	/\breboot\b/i,
	/\bshutdown\b/i,
	/\bsystemctl\s+(start|stop|restart|enable|disable|reload)/i,
	/\bservice\s+\S+\s+(start|stop|restart|reload)/i,
	/\b(vim?|nano|emacs|code|subl|zed)\b/i,
];

const SAFE_PATTERNS = [
	/^\s*(cat|head|tail|less|more|grep|find|ls|pwd|echo|printf|wc|sort|uniq|diff|file|stat|du|df|tree|which|whereis|type|env|printenv|uname|whoami|id|date|cal|uptime|ps|free|jq|awk|rg|fd|bat|eza)\b/i,
	/^\s*sed\s+-n\b/i,
	/^\s*git\s+(status|log|diff|show|branch|remote|config\s+--get|ls-files|ls-tree|grep|describe|rev-parse)\b/i,
	/^\s*(npm|yarn|pnpm|bun)\s+(list|ls|view|info|search|outdated|audit|why)\b/i,
	/^\s*(node|python|python3|ruby|go|cargo|rustc)\s+(--version|-v|version)\b/i,
	/^\s*curl\s+(-I|--head|--get|https?:\/\/)/i,
	/^\s*wget\s+(-O\s*-|--spider)/i,
];

export function isSafeCommand(command: string): boolean {
	const parts = command.split(/\s*(?:&&|\|\||;)\s*/).filter(Boolean);
	if (parts.length === 0) return false;
	return parts.every((part) => !DESTRUCTIVE_PATTERNS.some((p) => p.test(part)) && SAFE_PATTERNS.some((p) => p.test(part)));
}

export interface PlanStep {
	id: number;
	text: string;
	status: "pending" | "in_progress" | "done" | "blocked" | "skipped";
	notes?: string;
}

export interface PlanState {
	planning: boolean;
	executing: boolean;
	goal?: string;
	steps: PlanStep[];
	nextId: number;
}

export function defaultPlanState(): PlanState {
	return { planning: false, executing: false, steps: [], nextId: 1 };
}

export function summarizePlan(state: PlanState): string {
	if (state.steps.length === 0) return state.planning ? "planning" : "no plan";
	const done = state.steps.filter((s) => s.status === "done" || s.status === "skipped").length;
	const blocked = state.steps.filter((s) => s.status === "blocked").length;
	return `${done}/${state.steps.length}${blocked ? `, ${blocked} blocked` : ""}`;
}

export function extractPlanSteps(text: string): string[] {
	const header = text.match(/(?:^|\n)\s*(?:#{1,6}\s*)?(?:implementation\s+)?plan\s*:?\s*\n/i);
	if (!header?.index && header?.index !== 0) return [];
	const rest = text.slice(header.index + header[0].length);
	const lines = rest.split("\n");
	const steps: string[] = [];
	for (const line of lines) {
		if (/^\s*#{1,6}\s+/.test(line) && steps.length > 0) break;
		const match = line.match(/^\s*(?:[-*]\s+|\d+[.)]\s+)(?:\[[ xX~-]\]\s*)?(.+?)\s*$/);
		if (!match) continue;
		const cleaned = match[1].replace(/\*\*/g, "").replace(/^`|`$/g, "").trim();
		if (cleaned.length > 4) steps.push(cleaned);
	}
	return steps;
}
