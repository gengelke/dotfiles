# (C) 2020 Gordon Engelke
# Please make sure that your PowerShell allows execution of scripts.
# When in doubt, just activate it for the current session:
# Set-ExecutionPolicy Bypass -Scope Process -Force

$SCRIPTNAME = $MyInvocation.MyCommand.Name
$CONFIGDIR = "$PSScriptRoot\configfiles"

##Requires -RunAsAdministrator
#if (-Not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
#	Write-Host "`n`n`nThe script '$SCRIPTNAME' cannot be run because it is required that the current Windows PowerShell session is running as Administrator. Start Windows PowerShell by using the 'Run as Administrator' option, and then try running the script again.`n`n`n"
#	Exit
#}


#=================================#
# UI/UX modifications             #
#=================================#

Write-Host "`n=> Setting desktop wallpaper..."
set-itemproperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value C:\Users\admin\Documents\dotfiles\wallpaper\windows_red.png
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters 1, True

Write-Output "`n=> Setting default explorer view to 'This PC'..."
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1

# Removing user folders under 'This PC' in Explorer..."
Write-Output "`n=> Removing 3D Objects folder from 'This PC'..."
If((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") -eq $True) {
	Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
}
If((Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}") -eq $True) {
	Remove-Item "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
}

Write-Output "`n=> Enabling Dark theme for system UI..."
set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name SystemUsesLightTheme -value 0
Write-Output "`n=> Enabling Darktheme for application UI colors..."
set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name AppsUseLightTheme -value 0
Write-Output "`n=> Disabling transparency for system UI..."
set-itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -name EnableTransparency -value 0

#Write-Output "`n=> Resetting Start menu layout to factory default..."
#Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*$start.tilegrid$windows.data.curatedtilecollection.tilecollection'  -Force -Recurse
#Get-Process Explorer | Stop-Process

Write-Output "`n=> Restoring Start menu layout..."
If((Test-Path $CONFIGDIR\StartMenuLayout_Modification.xml) -eq $True) {
	Copy-Item $CONFIGDIR\StartMenuLayout_Modification.xml $env:LOCALAPPDATA\Microsoft\Windows\Shell\LayoutModification.xml -Force
	Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*$start.tilegrid$windows.data.curatedtilecollection.tilecollection'  -Force -Recurse
}

#Write-Host "`n=> Restoring taskbar layout..."
#REG IMPORT "$CONFIGDIR\taskbar.reg"
#Write-Host "`n=> Restoring taskband layout..."
#REG IMPORT "$CONFIGDIR\taskband.reg"

Write-Host "`n=> Setting 'Use small taskbar buttons' to true..."
# 0 = Large taskbar buttons
# 1 = Small taskbar buttons
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /V TaskbarSmallIcons /T REG_DWORD /D 1 /F
Get-Process Explorer | Stop-Process


#=================================#
# Configure Proxy for Powershell  #
#=================================#

$PROXY_PROFILE = @" 
[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://rb-proxy-de.bosch.com:8080')
[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true
"@

if (!(Test-Path $profile)) {
  Write-Warning "$profile does not exist. Will create the file and proxy settings."
  New-Item "$profile"
  Add-Content $profile '$PROXY_PROFILE'
}
else {
  $SEL = Select-String -Path $profile -Pattern "new-object system.net.webproxy"
  if ($SEL -eq $null) {
    Write-Warning "$profile already exists but does not contain the proxy settings. Will create the proxy settings."
    Add-Content $profile "$PROXY_PROFILE"
  } else {
    Write-Warning "$profile already exists and already contains the proxy settings."
  }
}


#=================================#
# Chocolatey stuff                #
#=================================#

Write-Host "`n=> Install Chocolatey package manager..."
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Exit

# Auto approve all chocolatey package installations
choco feature enable -n=allowGlobalConfirmation

Write-Host "`n=> Install reqiured/desired software packages through Chocolatey..."
choco install `
	awscli `
	azure-cli `
	cloudfoundry-cli `
	ConEmu `
	cyberduck `
	docker-desktop `
	kubernetes-cli `
	kubernetes-helm `
	meld `
	packer `
	terraform `
	trafficlight-chrome `
	vagrant `
	vim `
	vlc `
	vscode `
	winmerge `
	wox `
	Xming

# Disable auto approve all chocolatey package installations
choco feature disable -n=allowGlobalConfirmation


#=================================#
# Enable WSL2 Ubuntu              #
#=================================#

Write-Host "`n=> Enable Windows Subsystem for Linux 2"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#wsl --set-default-version 2

$APPX = "$env:TEMP\Ubuntu1804.appx"
if (!(Test-Path $APPX)) {
  Write-Host "`n=> Download Ubuntu 18.04 WSL Distro"
  Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile "$APPX" -UseBasicParsing
} else {
  Write-Host "`n=> $APPX already existing."
}

Write-Host "`n=> Install Ubuntu 18.04 WSL Distro"
Add-AppxPackage "$APPX"

# Set www proxy configuration
# sudo echo vi /etc/apt/apt.conf
# add this text, change the proxy to your local one and save the file.
# Acquire::http::Proxy "http://rb-proxy-de.bosch.com:8080";
# Update the Distro
# sudo apt update
# sudo apt upgrade –y

Write-Host "`nDone."
Write-Host "Please consider to restart Windows now in order to make all changes effective."
Write-Host "Have fun!`n`n`n"