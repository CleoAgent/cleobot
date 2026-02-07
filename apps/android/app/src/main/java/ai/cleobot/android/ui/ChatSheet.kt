package ai.cleobot.android.ui

import androidx.compose.runtime.Composable
import ai.cleobot.android.MainViewModel
import ai.cleobot.android.ui.chat.ChatSheetContent

@Composable
fun ChatSheet(viewModel: MainViewModel) {
  ChatSheetContent(viewModel = viewModel)
}
