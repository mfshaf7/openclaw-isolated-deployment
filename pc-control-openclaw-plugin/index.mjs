import { createPcControlTools } from "./src/tools.mjs";

export default function register(api) {
  const tools = createPcControlTools(api);
  for (const tool of tools) {
    api.registerTool(tool);
  }
}
