/**
 * Setup Wizard component for CleoBot
 * Guides new users through the initial setup process
 */

import { html, css, type TemplateResult } from "lit";
import { type AppState } from "../app-state.js";

export interface SetupState {
  initialized: boolean;
  username: string;
  password: string;
  confirmPassword: string;
  error: string | null;
  loading: boolean;
}

export function createDefaultSetupState(): SetupState {
  return {
    initialized: false,
    username: "",
    password: "",
    confirmPassword: "",
    error: null,
    loading: false,
  };
}

export const setupStyles = css`
  .setup-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    padding: 20px;
    background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  }

  .setup-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 40px;
    width: 100%;
    max-width: 500px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  }

  .setup-header {
    text-align: center;
    margin-bottom: 30px;
  }

  .setup-header h1 {
    font-size: 28px;
    color: #1a1a2e;
    margin: 0 0 8px 0;
  }

  .setup-header p {
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

  .setup-button {
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

  .setup-button:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(74, 144, 217, 0.4);
  }

  .setup-button:disabled {
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
`;

export async function initializeSetup(): Promise<boolean> {
  try {
    const response = await fetch("/api/auth/first-run");
    const data = await response.json();
    return data.firstRun;
  } catch {
    return false;
  }
}

export async function completeSetup(
  username: string,
  password: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const response = await fetch("/api/auth/setup", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const data = await response.json();

    if (response.ok && data.success) {
      return { success: true };
    } else {
      return { success: false, error: data.error || "Setup failed" };
    }
  } catch {
    return { success: false, error: "Network error" };
  }
}

export function renderSetup(
  state: AppState,
  setupState: SetupState,
  onUpdate: (updates: Partial<SetupState>) => void,
  onSubmit: () => void
): TemplateResult {
  return html`
    <style>
      ${setupStyles}
    </style>
    <div class="setup-container">
      <div class="setup-card">
        <div class="setup-header">
          <h1>Welcome to CleoBot 🛠️</h1>
          <p>Let's get you set up</p>
        </div>

        ${setupState.error
          ? html`<div class="error-message">${setupState.error}</div>`
          : ""}

        <form
          @submit=${(e: Event) => {
            e.preventDefault();
            onSubmit();
          }}
        >
          <div class="form-group">
            <label for="username">Admin Username</label>
            <input
              type="text"
              id="username"
              .value=${setupState.username}
              @input=${(e: Event) =>
                onUpdate({ username: (e.target as HTMLInputElement).value })}
              placeholder="Choose a username"
              ?disabled=${setupState.loading}
            />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input
              type="password"
              id="password"
              .value=${setupState.password}
              @input=${(e: Event) =>
                onUpdate({ password: (e.target as HTMLInputElement).value })}
              placeholder="Choose a password"
              ?disabled=${setupState.loading}
            />
          </div>

          <div class="form-group">
            <label for="confirm-password">Confirm Password</label>
            <input
              type="password"
              id="confirm-password"
              .value=${setupState.confirmPassword}
              @input=${(e: Event) =>
                onUpdate({
                  confirmPassword: (e.target as HTMLInputElement).value,
                })}
              placeholder="Confirm your password"
              ?disabled=${setupState.loading}
            />
          </div>

          <button
            type="submit"
            class="setup-button"
            ?disabled=${
              setupState.loading ||
              !setupState.username ||
              !setupState.password ||
              !setupState.confirmPassword ||
              setupState.password !== setupState.confirmPassword
            }
          >
            ${setupState.loading ? "Setting up..." : "Complete Setup"}
          </button>
        </form>
      </div>
    </div>
  `;
}
