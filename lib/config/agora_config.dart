// ⚠️ IMPORTANT: Get your free App ID from https://console.agora.io
// Create a project -> "Secured mode: APP ID + Token" is fine for testing
// (choose "Testing mode" / App ID without certificate while developing).
// Paste your App ID below.

class AgoraConfig {
  static const String appId = "4786a9ea682b4a8e8ba0afec77d6baf0";

  // For production you should generate temp tokens from your own backend
  // (Cloud Function). For now we leave token null which only works while
  // your Agora project is in "Testing Mode" (App ID auth, no certificate).
  static const String? tempToken = null;
}
