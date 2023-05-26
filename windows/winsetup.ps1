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
# Activate Windows                #
#=================================#

Write-Host "`n=> Checking if Windows is activated..."
$status = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where PartialProductKey).licensestatus
If ($status -ne 1) { 
	Write-Host "Windows is not activated yet!"
	Write-Host "Enter your Windows product key: (e.g. '#####-#####-#####-#####-#####', RETURN = Skip)"
	$key = Read-Host
	If ($key -eq "") { Write-Host "Windows activation skipped by user." }
	else { 
		$service = get-wmiObject -query "select * from SoftwareLicensingService" -computername $env:COMPUTERNAME
		$service.InstallProductKey($key)
		$service.RefreshLicenseStatus()
		#slmgr.vbs /ipk #####-#####-#####-#####-#####
	}
} 
else { Write-Host "Windows is already activated. Nothing to do." }


#=================================#
# Set the computer name           #
#=================================#

Write-Host "`n=> Set computer name..."
Write-Host "Currently Computer name is set to '$env:COMPUTERNAME'."
Write-Host "Enter desired ComputerName: (RETURN = Skip)"
$computerName = Read-Host
if ($computerName -eq "") { "Setting Computer name skipped by user." }
elseif ($computerName -eq $env:COMPUTERNAME) { Write-Host "Computer name is already set to '$computerName'. Nothing to do." }
else { Rename-Computer -NewName $computerName }


#=================================#
# Add a standard user account     #
#=================================#

Write-Host "`n=> Create local standard user account..."
Write-Host "Enter desired Username: (RETURN = Skip)"
$username = Read-Host

if ($userame -eq "") { "Create local standard user account skipped by user." }
elseif (Get-LocalUser $username) { Write-Host "Local user account '$username' already exists. Nothing to do." }
else {
	Write-Host "Enter desired Password: "
	$Password = Read-Host -AsSecureString
	New-LocalUser $username -Password $Password -FullName $username -Description "Standard user account"
	Add-LocalGroupMember -Group "Users" -Member $username
	Add-LocalGroupMember -Group "docker-users" -Member $username
#	net localgroup docker-users gengelke /add
}


#=================================#
# Power savings                   #
#=================================#

Write-Host "`n=> Disabling power off when lid is closed..."
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0


#=================================#
# Logon Screen                    #
#=================================#

$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$img = "C:\Users\gengelke\Documents\dotfiles\wallpaper\ge-background.png"
Set-ItemProperty -Path $path -Name LockScreenImage -value $img


#=================================#
# Screen Saver                    #
#=================================#

Write-Host "`n=> Activating screen saver. TimeOut 60 seconds..."
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 1
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 60
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name scrnsave.exe -Value "c:\windows\system32\mystify.scr"


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
Write-Output "`n=> Enabling Dark theme for application UI colors..."
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
# Chocolatey stuff                #
#=================================#

Write-Host "`n=> Install Chocolatey package manager..."
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Exit

# Auto approve all chocolatey package installations
choco feature enable -n=allowGlobalConfirmation

Write-Host "`n=> Install reqiured/desired software packages through Chocolatey..."
choco install `
	1password `
	7zip `
	7zip.install `
	autohotkey `
	awscli `
	azure-cli `
	beyondcompare `
	brave `
	ccleaner `
	cloudfoundry-cli `
	ConEmu `
	curl `
	cyberduck `
	docker-desktop `
	dotnetcore `
	dotnetfx `
#	dropbox `
	etcher `
	expandrive `
#	fiddler `	
	gimp `
	git `
	github-desktop `
	gitkraken `
	glasswire `
#	greenshot `
	javaruntime `
	kubernetes-cli `
	meld `
	microsoft-windows-terminal `	
	mountain-duck `
#	musicbee `	
	nmap `
	nodejs-lts `
	nordvpn `
	notepadplusplus `
#	openssh `
	packer `
#	pdfsam `
#	putty `	
	python2 `
	python3 `
	recuve `
	screenpresso `	
	shutup10 `
#	skype `	
	sourcetree `
	sumatrapdf `
	sysinternals `
	terraform `
	tigervnc-viewer `
	trafficlight-chrome `
#	treesizefree `	
	vagrant `
	vcxsrv `
	veracrypt `
	vim `
	virtualbox `
	VirtualBox.ExtensionPack `
	vlc `
	vmware-workstation-player `
	vmwareplayer `
	vscode `
	winamp `
#	windirstat `	
	windows-terminal `
	winmerge `
	winscp `
	wireshark `
	wnetwatcher `
	wox `	
#	Xming `
	XnView
	
# Disable auto approve all chocolatey package installations
choco feature disable -n=allowGlobalConfirmation


#https://download.bitdefender.com/windows/installer/en-us/bitdefender_tsecurity.exe
#https://gdata-a.akamaihd.net/Q/Tools/2014/INT/INT_GD_USB_KEYBOARD_GUARD.exe
#https://www.netlimiter.com/files/download/nl4/netlimiter-4.0.59.0.exe
#https://shieldapps.com/external/webcam-blocker-setup.php
#https://www.tripmode.ch/appwin/TripMode-win64.msi
#https://www.expandrive.com/download-expandrive/#
#https://www.git-tower.com/download/windows


#=================================#
# Enable WSL2 Ubuntu              #
#=================================#

Write-Host "`n=> Enable Windows Subsystem for Linux 2"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#wsl --set-default-version 2

$APPX = "$env:TEMP\Ubuntu1804.appx"
if (!(Test-Path $APPX)) {
  Write-Host "`n=> Download Ubuntu 12.04 WSL Distro"
  Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1204 -OutFile "$APPX" -UseBasicParsing
} else {
  Write-Host "`n=> $APPX already existing."
}

Write-Host "`n=> Install Ubuntu 12.04 WSL Distro"
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
