/// The Haiku alias resolves to Anthropic's published dated model ID. Other
/// unexpected models still fail validation rather than silently switching.
bool matchesClaudeModel(String requested, String returned) =>
    requested == returned ||
    (requested == 'claude-haiku-4-5' &&
        returned == 'claude-haiku-4-5-20251001');
