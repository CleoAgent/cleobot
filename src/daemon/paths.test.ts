import path from "node:path";
import { describe, expect, it } from "vitest";
import { resolveGatewayStateDir } from "./paths.js";

describe("resolveGatewayStateDir", () => {
  it("uses the default state dir when no overrides are set", () => {
    const env = { HOME: "/Users/test" };
    expect(resolveGatewayStateDir(env)).toBe(path.join("/Users/test", ".cleobot"));
  });

  it("appends the profile suffix when set", () => {
    const env = { HOME: "/Users/test", CLEOBOT_PROFILE: "rescue" };
    expect(resolveGatewayStateDir(env)).toBe(path.join("/Users/test", ".openclaw-rescue"));
  });

  it("treats default profiles as the base state dir", () => {
    const env = { HOME: "/Users/test", CLEOBOT_PROFILE: "Default" };
    expect(resolveGatewayStateDir(env)).toBe(path.join("/Users/test", ".cleobot"));
  });

  it("uses CLEOBOT_STATE_DIR when provided", () => {
    const env = { HOME: "/Users/test", CLEOBOT_STATE_DIR: "/var/lib/openclaw" };
    expect(resolveGatewayStateDir(env)).toBe(path.resolve("/var/lib/openclaw"));
  });

  it("expands ~ in CLEOBOT_STATE_DIR", () => {
    const env = { HOME: "/Users/test", CLEOBOT_STATE_DIR: "~/cleobot-state" };
    expect(resolveGatewayStateDir(env)).toBe(path.resolve("/Users/test/openclaw-state"));
  });

  it("preserves Windows absolute paths without HOME", () => {
    const env = { CLEOBOT_STATE_DIR: "C:\\State\\openclaw" };
    expect(resolveGatewayStateDir(env)).toBe("C:\\State\\openclaw");
  });
});
