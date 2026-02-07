package ai.cleobot.android.protocol

import org.junit.Assert.assertEquals
import org.junit.Test

class CleoBotProtocolConstantsTest {
  @Test
  fun canvasCommandsUseStableStrings() {
    assertEquals("canvas.present", CleoBotCanvasCommand.Present.rawValue)
    assertEquals("canvas.hide", CleoBotCanvasCommand.Hide.rawValue)
    assertEquals("canvas.navigate", CleoBotCanvasCommand.Navigate.rawValue)
    assertEquals("canvas.eval", CleoBotCanvasCommand.Eval.rawValue)
    assertEquals("canvas.snapshot", CleoBotCanvasCommand.Snapshot.rawValue)
  }

  @Test
  fun a2uiCommandsUseStableStrings() {
    assertEquals("canvas.a2ui.push", CleoBotCanvasA2UICommand.Push.rawValue)
    assertEquals("canvas.a2ui.pushJSONL", CleoBotCanvasA2UICommand.PushJSONL.rawValue)
    assertEquals("canvas.a2ui.reset", CleoBotCanvasA2UICommand.Reset.rawValue)
  }

  @Test
  fun capabilitiesUseStableStrings() {
    assertEquals("canvas", CleoBotCapability.Canvas.rawValue)
    assertEquals("camera", CleoBotCapability.Camera.rawValue)
    assertEquals("screen", CleoBotCapability.Screen.rawValue)
    assertEquals("voiceWake", CleoBotCapability.VoiceWake.rawValue)
  }

  @Test
  fun screenCommandsUseStableStrings() {
    assertEquals("screen.record", CleoBotScreenCommand.Record.rawValue)
  }
}
