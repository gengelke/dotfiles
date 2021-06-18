# (C) 2020 Gordon Engelke <reject@email.de>

# Powershell Core:   ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Powershell:        ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# Azure Cloud Shell: ~/.config/PowerShell/Microsoft.PowerShell_profile.ps1

write-host "Loading powershell profile...";

[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy('http://rb-proxy-de.bosch.com:8080')
[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $True

# $host.UI.RawUI.ForegroundColor = "Gray"
# $host.UI.RawUI.BackgroundColor = "Black"

#set-executionpolicy RemoteSigned process

function Get-OsType() {
    if ($IsLinux) {
        return "Linux"
    } 
    elseif ($IsMacOS) {
        return "MacOS"
    }
    elseif ($IsWindows) {
        return "Windows"
    } 
    else {
        return "unknown"
        exit -1
    }
}

$osType = Get-OsType
#Write-Host "Running on $osType platform."

#============#
# Colored ls #
#============#

if ($osType -eq "Linux") {
    function ls_color { & '/bin/ls' --color $args }
    Set-Alias -Name ls -Value ls_color -Option AllScope
}

if ($osType -eq "MacOS") {
    $env:CLICOLOR = 'true'
    function ls_color { & '/bin/ls' -G $args }
    Set-Alias -Name ls -Value ls_color -Option AllScope
}

if ($osType -eq "Windows") {
    function ls_color { & 'C:\Program Files\Git\usr\bin\ls' --color=auto -hF $args }
    Set-Alias -Name ls -Value ls_color -Option AllScope
}

#=============#
# CLI helpers #
#=============#

if ($osType -eq "Windows") { function edit ($file) { & "{C:\Program Files\Notepad++\notepad++.exe" $file } }
function wipe { $Host.UI.RawUI.ForegroundColor = "white"; $Host.UI.RawUI.BackgroundColor = "black"; Clear-Host; }
function touch ($file) { Write-Output "" >> $file; }
if ($osType -eq "Windows") { function explore { "explorer.exe $(Get-Location)" | Invoke-Expression } }
function cl($loc) {cd $loc; ls;} 
function up() {cd ..;}
function x { exit }
if ($osType -eq "Windows") { Set-Alias vim "C:\tools\vim\vim82\vim.exe"; Set-Alias vi vim }
# which <app>: Get path for an executable
function which($app) {
    (Get-Command $app).Definition
}

if ($osType -eq "Windows") {
    Set-Alias vim "C:\tools\vim\vim82\vim.exe"
    Set-Alias vi vim
}

#=============#
# Git helpers #
#=============#

function ga() { git add -A }
function gs() { git status }
function gas() { git add -A; git status }
function gcp($msg) { git commit -m "$msg"; git push }
function gacp($msg) { git add .; git commit -m "$msg"; git push }
function get() { git pull }
# Output verbose git status?
$git_status_verbose = $true

#================================#
# Shortcuts for quick navigation #
#================================#

$tools 	   = "c:\tools"
$documents = $home + "\Documents"
$desktop   = $home + "\Desktop"
$downloads = $home + "\Downloads"
$modules   = $home + "\Documents\WindowsPowerShell\Modules"

#=========================#
# History Search - CTRL-R #
#=========================#

Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function Complete

#$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
#$UserType = "User"
#$CurrentUser.Groups | foreach { 
#    if ($_.value -eq "S-1-5-32-544") {
#        $UserType = "Admin"
#    } 
#}

#===================#
# Customized Prompt #
#===================#

function prompt {
    $cwd = $(get-location)
    $cwd_short = Get-ShortPath $cwd
    if($UserType -eq "Admin") {
         $host.UI.RawUI.WindowTitle = "" + $cwd_short + " : *Administrator*"
         $host.UI.RawUI.ForegroundColor = "white"
     }
     else {
#         $host.ui.rawui.WindowTitle = $cwd_short
     }

    Write-Host("")

    $symbolicref = git symbolic-ref HEAD
    $has_changes = $false
    $git_branch = $NULL
    if($symbolicref -ne $NULL) {
        $git_branch = $symbolicref.substring($symbolicref.LastIndexOf("/") +1 )
        $differences = (git diff-index --name-status HEAD)
        if($differences -ne $NULL) {
            $git_update_count = [regex]::matches($differences, "M`t").count
            $git_create_count = [regex]::matches($differences, "A`t").count
            $git_delete_count = [regex]::matches($differences, "D`t").count
            $has_changes = ($git_create_count -gt 0) -or ($git_update_count -gt 0) -or ($git_delete_count -gt 0)
        }
    }

    Write-Host ([Environment]::UserName) -nonewline -foregroundcolor DarkGreen
    Write-Host (" at ") -nonewline -foregroundcolor Gray
    if (Test-Path env:AZURE_HTTP_USER_AGENT) { 
        Write-Host ("Azure") -nonewline -foregroundcolor Blue
    } else {
        Write-Host ([Environment]::MachineName) -nonewline -foregroundcolor Blue
    }
    Write-Host (" in ") -nonewline -foregroundcolor Gray
    Write-Host ($cwd_short) -nonewline -foregroundcolor Yellow

    if ($git_branch -ne $NULL) {
        Write-Host (" (") -nonewline -foregroundcolor Cyan
        Write-Host ($git_branch) -nonewline -foregroundcolor  Cyan
        Write-Host (") ") -nonewline -foregroundcolor Cyan
        Write-Host("[") -nonewline -foregroundcolor Gray
        if ($git_status_verbose -eq $true) {
        if ($has_changes -eq $true) {
                Write-Host("a") -nonewline -foregroundcolor Yellow
                Write-Host(":") -nonewline -foregroundcolor Gray
                Write-Host($git_create_count) -nonewline -foregroundcolor White
                Write-Host(",") -nonewline -foregroundcolor Gray
                Write-Host("m") -nonewline -foregroundcolor Yellow
                Write-Host(":") -nonewline -foregroundcolor Gray
                Write-Host($git_update_count) -nonewline -foregroundcolor White
                Write-Host(",") -nonewline -foregroundcolor Gray
                Write-Host("r") -nonewline -foregroundcolor Yellow
                Write-Host(":") -nonewline -foregroundcolor Gray
                Write-Host($git_delete_count) -nonewline -foregroundcolor White
            }
            else {
                Write-Host("$") -nonewline -foregroundcolor Yellow
            }
        }
        else {
            if ($has_changes -eq $true) {
                Write-Host("!") -nonewline -foregroundcolor Yellow
            }
            Write-Host("$") -nonewline -foregroundcolor Yellow
        }
        Write-Host("]") -nonewline -foregroundcolor Gray
    }

    Write-Host("")

    $prompt = "PS>"
    if ($git_branch -ne $NULL) {
        $prompt = "PS>"
    }
    Write-Host($prompt) -nonewline -foregroundcolor Gray

    return " "
 }

#function Test-Administrator {
#    <#
#    .Synopsis
#    Return True if you are currently running PowerShell as an administrator, False otherwise.
#    #>
#    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
#    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
#}

#=================#
# Powerline stuff #
#=================#

if (-Not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module -Name PSReadLine -Scope CurrentUser -SkipPublisherCheck -Confirm:$False -Force
    Import-Module PSReadLine
}
if (-Not (Get-Module -ListAvailable -Name posh-git)) {
    Install-Module -Name posh-git -Scope CurrentUser -Confirm:$False -Force
    Import-Module posh-git
}
if (-Not (Get-Module -ListAvailable -Name oh-my-posh)) {
    Install-Module -Name oh-my-posh -Scope CurrentUser -Confirm:$False -Force
    Import-Module oh-my-posh
}

function Get-Uptime {
    param([String] $ComputerName = $env:COMPUTERNAME)
    $os = Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    $uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)

    Write-Host ""
    Write-Host ("Booted:") -NoNewLine -Foreground $warn_fg -Background $accent_1
    Write-Host (" " + $os.ConvertToDateTime($os.LastBootUpTime)) -Foreground $accent_3

    Write-Host ("Uptime:") -NoNewLine -Foreground $warn_fg -Background $accent_1
    Write-Host (" " + $uptime.Days + "d " + $uptime.Hours + "h " + $uptime.Minutes + "m") -Foreground $accent_3
    Write-Host ""
}

#====================#
# Persistent History #
#====================#

# Source: https://stackoverflow.com/questions/16474973/windows-powershell-persistent-history

# Save last 200 history items on exit
$MaximumHistoryCount = 200
$historyPath = Join-Path (split-path $profile) history.clixml

# Hook powershell's exiting event & hide the registration with -supportevent (from nivot.org)
Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
      Get-History | Export-Clixml $historyPath
}.GetNewClosure()

# Load previous history, if it exists
if ((Test-Path $historyPath)) {
    Import-Clixml $historyPath | ? {$count++;$true} | Add-History
    Write-Host -Fore Green "`nLoaded $count history item(s).`n"
}

# Aliases and functions to make it useful
New-Alias -Name i -Value Invoke-History -Description "Invoke history alias"
Rename-Item Alias:\h original_h -Force
function h { Get-History -c $MaximumHistoryCount }
function hg($arg) { Get-History -c $MaximumHistoryCount | out-string -stream | select-string $arg }
