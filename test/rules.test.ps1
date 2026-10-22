$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\rules.ps1')
$cases = @(
    @{ Name = "2 Yes, and always allow 'python -c test' in this conversation"; Id = 'ask-opt-P0-64-2'; Expected = $true },
    @{ Name = "2 Yes, and always allow 'winget --version; where.exe pdflatex; where.exe xelatex' in this conversation"; Id = 'ask-opt-P0-64-2'; Expected = $true },
    @{ Name = "2 Yes, and always allow 'python`n-c test' in this conversation"; Id = 'ask-opt-P0-64-2'; Expected = $true },
    @{ Name = "3 Yes, and always allow 'python'"; Id = 'ask-opt-P0-64-3'; Expected = $false },
    @{ Name = '1 Yes, allow this time'; Id = 'ask-opt-P0-64-1'; Expected = $false },
    @{ Name = "Yes, and always allow 'python' in this conversation"; Id = ''; Expected = $false },
    @{ Name = "2 Yes, and always allow 'python' in this conversation"; Id = 'unrelated-2'; Expected = $false },
    @{ Name = "2 Yes, and always allow 'python' in this conversation and elsewhere"; Id = 'ask-opt-P0-64-2'; Expected = $false }
)
foreach ($case in $cases) {
    if ((Test-ConversationOption $case.Name $case.Id) -ne $case.Expected) { throw "Approval rule test failed: $($case.Id)" }
}
foreach ($name in @('watcher.ps1', 'rules.ps1', 'scripts\package.ps1')) {
    $tokens = $null; $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot "..\$name"), [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { throw $errors }
}
Write-Output '8 approval matching cases and PowerShell syntax checks passed.'
