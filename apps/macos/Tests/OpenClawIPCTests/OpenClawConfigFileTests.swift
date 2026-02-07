import Foundation
import Testing
@testable import CleoBot

@Suite(.serialized)
struct CleoBotConfigFileTests {
    @Test
    func configPathRespectsEnvOverride() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("cleobot-config-\(UUID().uuidString)")
            .appendingPathComponent("cleobot.json")
            .path

        await TestIsolation.withEnvValues(["CLEOBOT_CONFIG_PATH": override]) {
            #expect(CleoBotConfigFile.url().path == override)
        }
    }

    @MainActor
    @Test
    func remoteGatewayPortParsesAndMatchesHost() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("cleobot-config-\(UUID().uuidString)")
            .appendingPathComponent("cleobot.json")
            .path

        await TestIsolation.withEnvValues(["CLEOBOT_CONFIG_PATH": override]) {
            CleoBotConfigFile.saveDict([
                "gateway": [
                    "remote": [
                        "url": "ws://gateway.ts.net:19999",
                    ],
                ],
            ])
            #expect(CleoBotConfigFile.remoteGatewayPort() == 19999)
            #expect(CleoBotConfigFile.remoteGatewayPort(matchingHost: "gateway.ts.net") == 19999)
            #expect(CleoBotConfigFile.remoteGatewayPort(matchingHost: "gateway") == 19999)
            #expect(CleoBotConfigFile.remoteGatewayPort(matchingHost: "other.ts.net") == nil)
        }
    }

    @MainActor
    @Test
    func setRemoteGatewayUrlPreservesScheme() async {
        let override = FileManager().temporaryDirectory
            .appendingPathComponent("cleobot-config-\(UUID().uuidString)")
            .appendingPathComponent("cleobot.json")
            .path

        await TestIsolation.withEnvValues(["CLEOBOT_CONFIG_PATH": override]) {
            CleoBotConfigFile.saveDict([
                "gateway": [
                    "remote": [
                        "url": "wss://old-host:111",
                    ],
                ],
            ])
            CleoBotConfigFile.setRemoteGatewayUrl(host: "new-host", port: 2222)
            let root = CleoBotConfigFile.loadDict()
            let url = ((root["gateway"] as? [String: Any])?["remote"] as? [String: Any])?["url"] as? String
            #expect(url == "wss://new-host:2222")
        }
    }

    @Test
    func stateDirOverrideSetsConfigPath() async {
        let dir = FileManager().temporaryDirectory
            .appendingPathComponent("cleobot-state-\(UUID().uuidString)", isDirectory: true)
            .path

        await TestIsolation.withEnvValues([
            "CLEOBOT_CONFIG_PATH": nil,
            "CLEOBOT_STATE_DIR": dir,
        ]) {
            #expect(CleoBotConfigFile.stateDirURL().path == dir)
            #expect(CleoBotConfigFile.url().path == "\(dir)/cleobot.json")
        }
    }
}
