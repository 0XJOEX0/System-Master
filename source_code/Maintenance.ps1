Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- PATHS & STATE ---
$LogFile = [System.IO.Path]::Combine($PSScriptRoot, "Maintenance.log")
$IconPath = [System.IO.Path]::Combine($PSScriptRoot, "myicon.ico")
$global:updatesFound = 0; $global:updatesDone = 0; $global:tempsFound = 0; $global:tempsCleaned = 0; $global:freed = "0 MB"

# --- THEME ---
$RazerGreen = [System.Drawing.Color]::FromArgb(68, 255, 0)
$DarkGray   = [System.Drawing.Color]::FromArgb(45, 45, 45)
$MatteBlack = [System.Drawing.Color]::FromArgb(20, 20, 20)
$WriteLog = { param($msg) Add-Content $LogFile "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $msg" }

# --- UI SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Razer System Master"; $form.Size = '500,650'; $form.StartPosition = 'CenterScreen'; $form.BackColor = $MatteBlack

# --- CONTROLS ---
$btnClean = New-Object System.Windows.Forms.Button; $btnClean.Location = '50,50'; $btnClean.Size = '380,50'; $btnClean.BackColor = $DarkGray; $btnClean.ForeColor = $RazerGreen
$btnDns = New-Object System.Windows.Forms.Button; $btnDns.Location = '50,120'; $btnDns.Size = '380,50'; $btnDns.BackColor = $DarkGray; $btnDns.ForeColor = $RazerGreen
$btnUpdate = New-Object System.Windows.Forms.Button; $btnUpdate.Location = '50,190'; $btnUpdate.Size = '380,50'; $btnUpdate.BackColor = $DarkGray; $btnUpdate.ForeColor = $RazerGreen
$btnUpdateAll = New-Object System.Windows.Forms.Button; $btnUpdateAll.Location = '50,260'; $btnUpdateAll.Size = '380,50'; $btnUpdateAll.BackColor = $DarkGray; $btnUpdateAll.ForeColor = $RazerGreen
$langBox = New-Object System.Windows.Forms.ComboBox; $langBox.Location = '380,10'; $langBox.Size = '60,20'; $langBox.Items.AddRange(@("En", "Ru")); $langBox.SelectedIndex = 0; $langBox.BackColor = $DarkGray; $langBox.ForeColor = $RazerGreen
$progressBar = New-Object System.Windows.Forms.ProgressBar; $progressBar.Location = '50,350'; $progressBar.Size = '380,25'
$lblStats = New-Object System.Windows.Forms.Label; $lblStats.ForeColor = $RazerGreen; $lblStats.Location = '50,400'; $lblStats.AutoSize = $true
$lblTemp = New-Object System.Windows.Forms.Label; $lblTemp.ForeColor = $RazerGreen; $lblTemp.Location = '50,430'; $lblTemp.AutoSize = $true
$form.Controls.AddRange(@($btnClean, $btnDns, $btnUpdate, $btnUpdateAll, $langBox, $progressBar, $lblStats, $lblTemp))

# --- ACTIONS ---
$UpdateUI = {
    $global:updatesFound = [int]$global:updatesFound; $global:updatesDone = [int]$global:updatesDone
    $global:tempsFound = [int]$global:tempsFound; $global:tempsCleaned = [int]$global:tempsCleaned
    if ($langBox.SelectedItem -eq "Ru") {
        $btnClean.Text = "Очистка темпов"; $btnDns.Text = "Обновить DNS"; $btnUpdate.Text = "Поиск обновлений"; $btnUpdateAll.Text = "Обновить всё"
        $lblStats.Text = "Найдено обновлений: $global:updatesFound  |  Готово: $global:updatesDone"
        $lblTemp.Text = "Темпов найдено: $global:tempsFound  |  Очищено: $global:tempsCleaned  |  Освобождено: $global:freed"
    } else {
        $btnClean.Text = "Clean Temp Files"; $btnDns.Text = "DNS Refresh"; $btnUpdate.Text = "Check Updates"; $btnUpdateAll.Text = "Update All"
        $lblStats.Text = "Updates Found: $global:updatesFound  |  Done: $global:updatesDone"
        $lblTemp.Text = "Temp Found: $global:tempsFound  |  Cleaned: $global:tempsCleaned  |  Freed: $global:freed"
    }
}
$langBox.Add_SelectedIndexChanged($UpdateUI); &$UpdateUI

$btnClean.Add_Click({
    $progressBar.Value = 10; $global:tempsCleaned = 0; $totalBytes = 0
    foreach ($f in @($env:TEMP, "C:\Windows\Temp")) {
        Get-ChildItem $f -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            try { $size = $_.Length; Remove-Item $_.FullName -Force -ErrorAction Stop; $global:tempsCleaned++; $totalBytes += $size } catch { }
        }
    }
    $global:freed = if ($totalBytes -lt 1GB) { "$([Math]::Round(($totalBytes / 1MB), 1)) MB" } else { "$([Math]::Round(($totalBytes / 1GB), 2)) GB" }
    &$UpdateUI; &$WriteLog "Cleaned $global:tempsCleaned files. Freed: $global:freed."; $btnClean.Text += " ✅"; $progressBar.Value = 100
})

$btnDns.Add_Click({ 
    $progressBar.Value = 50; Start-Process ipconfig -ArgumentList "/flushdns" -WindowStyle Hidden -Wait
    &$WriteLog "DNS Flushed."; $btnDns.Text += " ✅"; $progressBar.Value = 100 
})

$btnUpdate.Add_Click({
    $progressBar.Value = 20; $btnUpdate.Enabled = $false
    try {
        $raw = winget upgrade 2>&1 | Out-String
        # Count rows that look like packages (usually contain version numbers like X.X.X)
        $global:updatesFound = ($raw | Select-String "\d+\.\d+").Count 
        if ($global:updatesFound -eq 0) { &$WriteLog "Debug Raw: $raw" }
    } catch { &$WriteLog "ERROR: $_" }
    &$UpdateUI; &$WriteLog "Update check done. Found: $global:updatesFound"; $btnUpdate.Enabled = $true; $btnUpdate.Text = "Check Updates ✅"; $progressBar.Value = 100
})

$btnUpdateAll.Add_Click({
    $progressBar.Value = 20; Start-Process winget -ArgumentList "upgrade --all --silent" -Wait
    $global:updatesDone = $global:updatesFound; &$UpdateUI; &$WriteLog "Updated $global:updatesDone apps."; $btnUpdateAll.Text += " ✅"; $progressBar.Value = 100
})

$form.ShowDialog()