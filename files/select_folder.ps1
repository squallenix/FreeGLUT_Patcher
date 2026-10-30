Add-Type -AssemblyName System.Windows.Forms

$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Select your Code::Blocks installation or MinGW directory (e.g. C:\Program Files\CodeBlocks\MinGW):"
$dialog.ShowNewFolderButton = $false

# Enable modern Vista/Win10/Win11 Explorer style folder picker if supported
if ($dialog.PSObject.Properties['AutoUpgradeEnabled']) {
    $dialog.AutoUpgradeEnabled = $true
}

# Optional initial path passed via argument or default candidate
if ($args.Count -gt 0 -and (Test-Path $args[0])) {
    $dialog.SelectedPath = $args[0]
} elseif (Test-Path "C:\Program Files\CodeBlocks\MinGW") {
    $dialog.SelectedPath = "C:\Program Files\CodeBlocks\MinGW"
} elseif (Test-Path "C:\Program Files\CodeBlocks") {
    $dialog.SelectedPath = "C:\Program Files\CodeBlocks"
}

# Show window in foreground
$form = New-Object System.Windows.Forms.Form
$form.TopMost = $true
$result = $dialog.ShowDialog($form)

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    [Console]::WriteLine($dialog.SelectedPath)
}
