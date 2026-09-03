import { StringEnum } from "@earendil-works/pi-ai";
import type { AgentMessage } from "@earendil-works/pi-agent-core";
import type { AssistantMessage, TextContent } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Key, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { defaultPlanState, extractPlanSteps, isSafeCommand, summarizePlan, type PlanState, type PlanStep } from "./utils.ts";

const PLAN_MODE_TOOLS = ["read", "bash", "grep", "find", "ls", "plan_update", "questionnaire"];
const DISABLED_DURING_PLANNING = new Set(["edit", "write"]);
const MANAGED_TOOLS = new Set(["read", "bash", "grep", "find", "ls", "edit", "write"]);

const PlanUpdateParams = Type.Object({
	action: StringEnum(["show", "set", "add", "update", "start", "done", "block", "skip", "clear"] as const),
	goal: Type.Optional(Type.String({ description: "Plan goal when setting/replacing the plan" })),
	steps: Type.Optional(Type.Array(Type.String(), { description: "Full ordered step list for set" })),
	id: Type.Optional(Type.Number({ description: "Step id for update/start/done/block/skip" })),
	text: Type.Optional(Type.String({ description: "Step text for add/update" })),
	notes: Type.Optional(Type.String({ description: "Status note, blocker, verification result, or rationale" })),
});

interface PlanDetails extends PlanState {
	action: string;
	error?: string;
}

function isAssistantMessage(m: AgentMessage): m is AssistantMessage {
	return m.role === "assistant" && Array.isArray(m.content);
}

function textOf(message: AssistantMessage): string {
	return message.content
		.filter((block): block is TextContent => block.type === "text")
		.map((block) => block.text)
		.join("\n");
}

function cloneState(state: PlanState): PlanState {
	return { ...state, steps: state.steps.map((s) => ({ ...s })) };
}

function renderPlan(state: PlanState): string {
	const title = state.goal ? `Goal: ${state.goal}\n` : "";
	if (state.steps.length === 0) return `${title}No active plan.`.trim();
	return `${title}${state.steps
		.map((s) => {
			const mark = s.status === "done" ? "x" : s.status === "in_progress" ? ">" : s.status === "blocked" ? "!" : s.status === "skipped" ? "-" : " ";
			return `[${mark}] #${s.id} ${s.text}${s.notes ? ` — ${s.notes}` : ""}`;
		})
		.join("\n")}`;
}

export default function planMode(pi: ExtensionAPI) {
	let state = defaultPlanState();
	let toolsBeforePlanning: string[] | undefined;

	pi.registerFlag("plan", {
		description: "Start in read-only plan mode",
		type: "boolean",
		default: false,
	});

	function activeSummary() {
		return state.planning ? `planning: ${summarizePlan(state)}` : state.executing ? `executing: ${summarizePlan(state)}` : undefined;
	}

	function updateUi(ctx: ExtensionContext) {
		const summary = activeSummary();
		ctx.ui.setStatus("plan-mode", summary ? ctx.ui.theme.fg(state.planning ? "warning" : "accent", `📋 ${summary}`) : undefined);

		if (!state.executing || state.steps.length === 0) {
			ctx.ui.setWidget("plan-mode", undefined);
			return;
		}
		ctx.ui.setWidget(
			"plan-mode",
			state.steps.map((s) => {
				const icon = s.status === "done" ? "☑" : s.status === "in_progress" ? "◉" : s.status === "blocked" ? "⚠" : s.status === "skipped" ? "⊝" : "☐";
				return `${icon} #${s.id} ${s.text}${s.notes ? ` — ${s.notes}` : ""}`;
			}),
		);
	}

	function unique(names: string[]) {
		return [...new Set(names)];
	}

	function enablePlanningTools() {
		if (!toolsBeforePlanning) toolsBeforePlanning = pi.getActiveTools();
		pi.setActiveTools(unique([...toolsBeforePlanning.filter((name) => !DISABLED_DURING_PLANNING.has(name)), ...PLAN_MODE_TOOLS]));
	}

	function restoreTools() {
		pi.setActiveTools(toolsBeforePlanning ?? unique([...pi.getActiveTools().filter((name) => !MANAGED_TOOLS.has(name)), "read", "bash", "edit", "write"]));
		toolsBeforePlanning = undefined;
	}

	function persist() {
		pi.appendEntry("plan-mode", { ...cloneState(state), toolsBeforePlanning });
	}

	function replacePlan(goal: string | undefined, steps: string[]) {
		state.goal = goal ?? state.goal;
		state.steps = steps.map((text, index) => ({ id: index + 1, text, status: "pending" }));
		state.nextId = state.steps.length + 1;
	}

	function startPlanning(ctx: ExtensionContext, goal?: string) {
		state = { ...defaultPlanState(), planning: true, goal: goal?.trim() || undefined };
		enablePlanningTools();
		updateUi(ctx);
		persist();
		ctx.ui.notify("Plan mode enabled: read-only exploration, edit/write disabled.", "info");
	}

	function stopPlanning(ctx: ExtensionContext) {
		state.planning = false;
		state.executing = false;
		restoreTools();
		updateUi(ctx);
		persist();
		ctx.ui.notify("Plan mode disabled.", "info");
	}

	function startExecution(ctx: ExtensionContext) {
		state.planning = false;
		state.executing = true;
		restoreTools();
		updateUi(ctx);
		persist();
		ctx.ui.notify("Executing plan with full tool access restored.", "info");
	}

	pi.registerTool({
		name: "plan_update",
		label: "Plan",
		description:
			"Maintain the active plan. Use during planning to set concrete steps; use during execution to start, complete, block, skip, or revise steps.",
		parameters: PlanUpdateParams,
		async execute(_toolCallId, params) {
			let error: string | undefined;
			const byId = (id?: number) => state.steps.find((s) => s.id === id);
			switch (params.action) {
				case "set":
					if (!params.steps?.length) error = "steps required";
					else replacePlan(params.goal, params.steps);
					break;
				case "add":
					if (!params.text) error = "text required";
					else state.steps.push({ id: state.nextId++, text: params.text, status: "pending", notes: params.notes });
					break;
				case "update": {
					const step = byId(params.id);
					if (!step) error = "step not found";
					else {
						if (params.text) step.text = params.text;
						if (params.notes !== undefined) step.notes = params.notes;
					}
					break;
				}
				case "start": {
					const step = byId(params.id);
					if (!step) error = "step not found";
					else step.status = "in_progress";
					break;
				}
				case "done": {
					const step = byId(params.id);
					if (!step) error = "step not found";
					else {
						step.status = "done";
						step.notes = params.notes ?? step.notes;
					}
					break;
				}
				case "block": {
					const step = byId(params.id);
					if (!step) error = "step not found";
					else {
						step.status = "blocked";
						step.notes = params.notes ?? "blocked";
					}
					break;
				}
				case "skip": {
					const step = byId(params.id);
					if (!step) error = "step not found";
					else {
						step.status = "skipped";
						step.notes = params.notes ?? step.notes;
					}
					break;
				}
				case "clear":
					state = defaultPlanState();
					break;
			}
			const details: PlanDetails = { ...cloneState(state), action: params.action, error };
			return { content: [{ type: "text", text: error ? `Plan error: ${error}` : renderPlan(state) }], details, isError: Boolean(error) };
		},
		renderCall(args, theme) {
			return new Text(theme.fg("toolTitle", theme.bold("plan ")) + theme.fg("muted", args.action) + (args.id ? theme.fg("accent", ` #${args.id}`) : ""), 0, 0);
		},
		renderResult(result, _opts, theme) {
			return new Text(theme.fg(result.isError ? "error" : "muted", result.content[0]?.type === "text" ? result.content[0].text : ""), 0, 0);
		},
	});

	pi.registerCommand("plan", {
		description: "Enter read-only plan mode; optional args become the goal",
		handler: async (args, ctx) => {
			if (state.planning) return stopPlanning(ctx);
			startPlanning(ctx, args);
			if (args?.trim()) {
				pi.sendUserMessage(`Create a high-quality implementation plan for: ${args.trim()}\n\nInspect the repo as needed. Do not modify files.`, { deliverAs: "followUp" });
			}
		},
	});

	pi.registerCommand("plan-exec", {
		description: "Execute the active plan with progress tracking",
		handler: async (_args, ctx) => {
			if (state.steps.length === 0) return ctx.ui.notify("No active plan to execute.", "error");
			startExecution(ctx);
			pi.sendUserMessage(`Execute the active plan step by step. Use plan_update to mark each step in_progress/done/blocked, revise the plan if reality differs, and run appropriate verification.\n\n${renderPlan(state)}`, { deliverAs: "followUp" });
		},
	});

	pi.registerCommand("plan-status", {
		description: "Show the active plan",
		handler: async (_args, ctx) => ctx.ui.notify(renderPlan(state), "info"),
	});

	pi.registerCommand("plan-clear", {
		description: "Clear plan mode state",
		handler: async (_args, ctx) => {
			state = defaultPlanState();
			restoreTools();
			updateUi(ctx);
			persist();
			ctx.ui.notify("Plan cleared.", "info");
		},
	});

	pi.registerShortcut(Key.ctrlAlt("p"), { description: "Toggle plan mode", handler: async (ctx) => (state.planning ? stopPlanning(ctx) : startPlanning(ctx)) });

	pi.on("tool_call", async (event) => {
		if (!state.planning || event.toolName !== "bash") return;
		const command = String((event.input as { command?: string }).command ?? "");
		if (!isSafeCommand(command)) return { block: true, reason: `Plan mode blocked non-read-only bash command. Disable plan mode or run /plan-exec to execute.\n${command}` };
	});

	pi.on("before_agent_start", async () => {
		if (state.planning) {
			return {
				message: {
					customType: "plan-mode-context",
					display: false,
					content: `[PLAN MODE ACTIVE]\nYou are in read-only planning mode.\n\nHard rules:\n- Do not modify files or system state. edit/write are disabled.\n- Bash is restricted to read-only commands.\n- Investigate enough to make a reliable plan; ask concise clarifying questions when needed.\n- Produce implementation-grade plans: objective, assumptions, affected files, ordered steps, risks, rollback, and verification.\n- Call plan_update(action=\"set\") with the final ordered steps.\n- Do not execute the plan until the user chooses /plan-exec.\n${state.goal ? `\nCurrent goal: ${state.goal}` : ""}`,
				},
			};
		}
		if (state.executing && state.steps.length > 0) {
			return {
				message: {
					customType: "plan-execution-context",
					display: false,
					content: `[EXECUTING PLAN]\nUse the active plan as the source of truth. Before working on a step, call plan_update(action=\"start\", id=...). After completion, call plan_update(action=\"done\", id=..., notes=verification). If blocked, call plan_update(action=\"block\"). Revise with add/update if needed.\n\n${renderPlan(state)}`,
				},
			};
		}
	});

	pi.on("agent_end", async (event, ctx) => {
		if (state.planning && state.steps.length === 0) {
			const last = [...event.messages].reverse().find(isAssistantMessage);
			const extracted = last ? extractPlanSteps(textOf(last)) : [];
			if (extracted.length > 0) replacePlan(state.goal, extracted);
		}
		if (state.executing && state.steps.length > 0 && state.steps.every((s) => s.status === "done" || s.status === "skipped")) {
			state.executing = false;
			ctx.ui.notify(`Plan complete.\n${renderPlan(state)}`, "info");
		}
		updateUi(ctx);
		persist();
	});

	function restoreFromBranch(ctx: ExtensionContext) {
		state = defaultPlanState();
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "custom" && entry.customType === "plan-mode" && "data" in entry) {
				const data = entry.data as Partial<PlanState> & { toolsBeforePlanning?: string[] };
				state = { planning: Boolean(data.planning), executing: Boolean(data.executing), goal: data.goal, steps: data.steps ?? [], nextId: data.nextId ?? ((data.steps?.length ?? 0) + 1) };
				toolsBeforePlanning = data.toolsBeforePlanning;
			}
			if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.toolName === "plan_update") {
				const details = entry.message.details as PlanDetails | undefined;
				if (details && !details.error) state = { planning: details.planning, executing: details.executing, goal: details.goal, steps: details.steps ?? [], nextId: details.nextId ?? ((details.steps?.length ?? 0) + 1) };
			}
		}
		if (pi.getFlag("plan") === true) state.planning = true;
		if (state.planning) enablePlanningTools();
		else if (!state.executing) restoreTools();
		updateUi(ctx);
	}

	pi.on("session_start", async (_event, ctx) => restoreFromBranch(ctx));
	pi.on("session_tree", async (_event, ctx) => restoreFromBranch(ctx));
}
