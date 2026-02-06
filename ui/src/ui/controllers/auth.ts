/**
 * Authentication controller for Better-Auth integration
 */

import type { GatewayBrowserClient } from "../gateway.js";

export async function checkFirstRun(client: GatewayBrowserClient | null): Promise<boolean> {
  if (!client) {
    // Fallback to direct API call if client not available yet
    try {
      const response = await fetch("/api/auth/first-run");
      const data = await response.json();
      return data.firstRun === true;
    } catch (error) {
      console.error("Failed to check first-run status:", error);
      return false;
    }
  }

  // Use client if available
  try {
    const response = await fetch("/api/auth/first-run");
    const data = await response.json();
    return data.firstRun === true;
  } catch (error) {
    console.error("Failed to check first-run status:", error);
    return false;
  }
}

export async function completeSetup(
  username: string,
  password: string,
): Promise<{ success: boolean; error?: string; apiKey?: string }> {
  try {
    const response = await fetch("/api/auth/setup", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    if (response.ok && data.success) {
      return { success: true, apiKey: data.apiKey };
    } else {
      return { success: false, error: data.error || "Setup failed" };
    }
  } catch (error) {
    return { success: false, error: String(error) };
  }
}

export async function attemptLogin(
  username: string,
  password: string,
): Promise<{ success: boolean; error?: string }> {
  try {
    const response = await fetch("/api/auth/sign-in", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: `${username}@cleobot.local`,
        password,
      }),
    });

    const data = await response.json();

    if (response.ok && !data.error) {
      return { success: true };
    } else {
      return { success: false, error: data.error || "Login failed" };
    }
  } catch (error) {
    return { success: false, error: String(error) };
  }
}
