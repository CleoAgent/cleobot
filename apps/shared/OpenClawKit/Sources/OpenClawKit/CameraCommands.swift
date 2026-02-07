import Foundation

public enum CleoBotCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum CleoBotCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum CleoBotCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum CleoBotCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct CleoBotCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: CleoBotCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: CleoBotCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: CleoBotCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: CleoBotCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct CleoBotCameraClipParams: Codable, Sendable, Equatable {
    public var facing: CleoBotCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: CleoBotCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: CleoBotCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: CleoBotCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
