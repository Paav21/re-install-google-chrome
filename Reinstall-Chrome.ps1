#####################################################################
# Script to fix the chrome video bug by re-installing Google Chrome #
#####################################################################

# Stop Chrome if running
Get-Process chrome | Stop-Process -Force

# Uninstall Google Chrome
$version=(Get-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome').version
$path="C:\Program Files\Google\Chrome\Application\$version\Installer\setup.exe "
$FullExecPath="$path --uninstall --system-level --chrome --verbose-logging --force-uninstall"

Write-Host "Chrome Version is "$version -ForegroundColor Green
Write-Host $FullExecPath -ForegroundColor Green

Invoke-WmiMethod -ComputerName localhost -Class win32_process -Name create -ArgumentList $FullExecPath
Wait-Event -Timeout 20

# Install Google Chrome
$LocalTempDir = $env:TEMP
$ChromeInstaller = "ChromeInstaller.exe"

(new-object System.Net.WebClient).DownloadFile('https://dl.google.com/chrome/install/375.126/chrome_installer.exe',"$LocalTempDir\$ChromeInstaller")
& "$LocalTempDir\$ChromeInstaller" /silent /install

$Process2Monitor = "ChromeInstaller"
Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
    If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 }
    else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } }
Until (!$ProcessesFound)

# Final
Write-Host "Install Complete"
