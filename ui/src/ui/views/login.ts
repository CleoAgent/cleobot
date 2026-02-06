/**
 * Login view component for CleoBot
 * Handles user authentication via Better-Auth
 */

import { html, css, type TemplateResult } from "lit";
import { type AppState } from "../app-state.js";

export interface LoginState {
  username: string;
  password: string;
  error: string | null;
  loading: boolean;
  rememberMe: boolean;
}

export function createDefaultLoginState(): LoginState {
  return {
    username: "",
    password: "",
    error: null,
    loading: false,
    rememberMe: true,
  };
}

export const loginStyles = css`
  .login-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    padding: 20px;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }

  .login-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 40px;
    width: 100%;
    max-width: 400px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  }

  .login-header {
    text-align: center;
    margin-bottom: 30px;
  }

  .login-header h1 {
    font-size: 28px;
    color: #1a1a2e;
    margin: 0 0 8px 0;
  }

  .login-header p {
    color: #666;
    margin: 0;
  }

  .form-group {
    margin-bottom: 20px;
  }

  .form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    color: #333;
  }

  .form-group input {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 16px;
    transition: border-color 0.2s;
    box-sizing: border-box;
  }

  .form-group input:focus {
    outline: none;
    border-color: #4a90d9;
  }

  .checkbox-group {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 20px;
  }

  .checkbox-group input[type="checkbox"] {
    width: 18px;
    height: 18px;
  }

  .checkbox-group label {
    color: #666;
    font-size: 14px;
  }

  .login-button {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, #4a90d9 0%, #357abd 100%);
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: transform 0.1s, box-shadow 0.2s;
  }

  .login-button:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(74, 144, 217, 0.4);
  }

  .login-button:disabled {
    opacity: 0.7;
    cursor: not-allowed;
    transform: none;
  }

  .error-message {
    background: #ffebee;
    color: #c62828;
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-size: 14px;
  }

  .tailscale-notice {
    text-align: center;
    margin-top: 20px;
    padding: 16px;
    background: #e3f2fd;
    border-radius: 8px;
    font-size: 14px;
    color: #1565c0;
  }
`;

export async function checkAuth(): Promise<boolean> {
  try {
    const response = await fetch("/api/auth/session");
    return response.ok;
  } catch {
    return false;
  }
}

export async function attemptLogin(
  username: string,
  password: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const response = await fetch("/api/auth/sign-in", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    if (response.ok && data.success) {
      return { success: true };
    } else {
      return { success: false, error: data.error || "Login failed" };
    }
  } catch {
    return { success: false, error: "Network error" };
  }
}

export async function logout(): Promise<void> {
  await fetch("/api/auth/sign-out", { method: "POST" });
}

export function renderLogin(
  state: AppState,
  loginState: LoginState,
  onUpdate: (updates: Partial<LoginState>) => void,
  onSubmit: () => void
): TemplateResult {
  return html`
    <style>
      ${loginStyles}
    </style>
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <h1>🤖 CleoBot</h1>
          <p>Sign in to access your agent</p>
        </div>

        ${loginState.error
          ? html`<div class="error-message">${loginState.error}</div>`
          : ""}

        <form
          @submit=${(e: Event) => {
            e.preventDefault();
            onSubmit();
          }}
        >
          <div class="form-group">
            <label for="username">Username</label>
            <input
              type="text"
              id="username"
              .value=${loginState.username}
              @input=${(e: Event) =>
                onUpdate({ username: (e.target as HTMLInputElement).value })}
              placeholder="Enter your username"
              ?disabled=${loginState.loading}
              autocomplete="username"
            />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input
              type="password"
              id="password"
              .value=${loginState.password}
              @input=${(e: Event) =>
                onUpdate({ password: (e.target as HTMLInputElement).value })}
              placeholder="Enter your password"
              ?disabled=${loginState.loading}
              autocomplete="current-password"
            />
          </div>

          <div class="checkbox-group">
            <input
              type="checkbox"
              id="remember"
              .checked=${loginState.rememberMe}
              @change=${(e: Event) =>
                onUpdate({ rememberMe: (e.target as HTMLInputElement).checked })}
            />
            <label for="remember">Remember me</label>
          </div>

          <button
            type="submit"
            class="login-button"
            ?disabled=${loginState.loading ||
            !loginState.username ||
            !loginState.password}
          >
            ${loginState.loading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        <div class="tailscale-notice">
          💡 Connected via Tailscale? You may be auto-authenticated.
        </div>
      </div>
    </div>
  `;
}
