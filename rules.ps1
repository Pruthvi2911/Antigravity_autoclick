function Test-ConversationOption([string]$Name, [string]$AutomationId) {
    $normalized = ($Name -replace '\s+', ' ').Trim()
    return ($AutomationId -cmatch '^ask-opt-.+-2$' -and
        $normalized -cmatch '^2 Yes, and always allow .+ in this conversation$')
}
