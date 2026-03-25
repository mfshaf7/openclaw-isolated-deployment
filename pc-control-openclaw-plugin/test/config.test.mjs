import test from "node:test";
import assert from "node:assert/strict";

import { resolvePcControlConfig } from "../src/config.mjs";

test("resolvePcControlConfig requires an explicit bridge URL", () => {
  delete process.env.PC_CONTROL_BRIDGE_URL;
  delete process.env.PC_CONTROL_BRIDGE_TOKEN;
  assert.throws(
    () => resolvePcControlConfig({ pluginConfig: {} }),
    /requires plugin config\.bridgeUrl or PC_CONTROL_BRIDGE_URL/,
  );
});

test("resolvePcControlConfig uses explicit plugin config and trims trailing slash", () => {
  process.env.OPENCLAW_GATEWAY_TOKEN = "token";
  const config = resolvePcControlConfig({
    pluginConfig: {
      bridgeUrl: "http://host.docker.internal:48721/",
      authTokenEnv: "OPENCLAW_GATEWAY_TOKEN",
      allowWriteOperations: true,
      sharedPathMap: {
        from: "/home/example/.openclaw",
        to: "/home/node/.openclaw/",
      },
    },
  });
  assert.equal(config.bridgeUrl, "http://host.docker.internal:48721");
  assert.equal(config.authToken, "token");
  assert.equal(config.allowWriteOperations, true);
  assert.deepEqual(config.sharedPathMap, {
    from: "/home/example/.openclaw",
    to: "/home/node/.openclaw",
  });
});

test("resolvePcControlConfig trims env-provided bridge settings", () => {
  process.env.PC_CONTROL_BRIDGE_URL = "  http://host.docker.internal:48721/  ";
  process.env.PC_CONTROL_BRIDGE_TOKEN = "  token-from-env  ";
  const config = resolvePcControlConfig({
    pluginConfig: {},
  });
  assert.equal(config.bridgeUrl, "http://host.docker.internal:48721");
  assert.equal(config.authToken, "token-from-env");
});
