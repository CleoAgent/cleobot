/**
 * Auth module exports
 */

export {
  signInEmail,
  signUpEmail,
  getSession,
  getSessionByToken,
  generateApiKey,
  validateApiKey,
  listApiKeys,
  revokeApiKey,
  isFirstRun,
  createFirstAdmin,
  setLegacyToken,
  validateLegacyToken,
  API_KEY_SCOPES,
  type ApiKeyScope,
} from "./auth.js";
