import Foundation

public enum CleoBotChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(CleoBotChatEventPayload)
    case agent(CleoBotAgentEventPayload)
    case seqGap
}

public protocol CleoBotChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> CleoBotChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [CleoBotChatAttachmentPayload]) async throws -> CleoBotChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> CleoBotChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<CleoBotChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension CleoBotChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "CleoBotChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> CleoBotChatSessionsListResponse {
        throw NSError(
            domain: "CleoBotChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
