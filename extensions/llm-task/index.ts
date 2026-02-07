import type { CleoBotPluginApi } from "../../src/plugins/types.js";
import { createLlmTaskTool } from "./src/llm-task-tool.js";

export default function register(api: CleoBotPluginApi) {
  api.registerTool(createLlmTaskTool(api), { optional: true });
}
