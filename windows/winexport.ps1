# (C) 2020 Gordon Engelke

$CONFIGDIR = "$PSScriptRoot\configfiles"
Write-Host "`n`n`nExporting Windows 10 configuration data to $CONFIGDIR"


#=================================#
# Taskbar configuration           #
#=================================#

Write-Host "`n=> Exporting taskbar configuration data..."
REG EXPORT HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Streams\Desktop "$CONFIGDIR\taskbar.reg" /y
Write-Host "`n=> Exporting taskband configuration data..."
REG EXPORT HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$CONFIGDIR\taskband.reg" /y


#=================================#
# Start menu configuration        #
#=================================#

Write-Host "`n=> Exporting Start menu layout data..."
Export-StartLayout -UseDesktopApplicationID -path "$CONFIGDIR\StartMenuLayout_Modification.xml"


Write-Host "`nDone."
Write-Host "Please consider to save and/or git commit/push your just exported Windows 10 configuration data for later use."
Write-Host "Have fun!`n`n`n"
