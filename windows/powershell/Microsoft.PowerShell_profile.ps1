# (C) 2020 Gordon Engelke <reject@email.de>

# Powershell Core: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Powershell:      ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

write-host "Loading powershell profile...";

$host.UI.RawUI.ForegroundColor = "Gray"
$host.UI.RawUI.BackgroundColor = "Black"

#set-executionpolicy RemoteSigned process

function Get-OsType() {
    if ($IsLinux) {
        return "Linux"
    }

    if ($IsOSX) {
        return "MacOS"
    }
    return "Windows"
}

$osType = Get-OsType

Write-Host "Running on $osType platform."

#if ( ($host.Name -eq 'ConsoleHost') -And ($IsWindows) )
if ($osType -eq "Windows") {
    function ls_git { & 'C:\Program Files\Git\usr\bin\ls' --color=auto -hF $args }
    Set-Alias -Name ls -Value ls_git -Option AllScope
}

if ($osType -eq "Windows") {
    Set-Alias vim "C:\tools\vim\vim82\vim.exe"
    Set-Alias vi vim
}

if ($osType -eq "Windows") { function edit ($file) { & "{C:\Program Files\Notepad++\notepad++.exe" $file } }
function wipe { $Host.UI.RawUI.ForegroundColor = "white"; $Host.UI.RawUI.BackgroundColor = "black"; clear; }
function touch ($file) { echo "" >> $file; }
if ($osType -eq "Windows") { function explore { "explorer.exe $(pwd)" | iex } }
function cl($loc) {cd $loc; ls;} 
function up() {cd ..;}
function x { exit }

# Git helpers
function ga() { git add -A }
function gs() { git status }
function gas() { git add -A; git status }
function gcp($msg) { git commit -m "$msg"; git push }
function gacp($msg) { git add .; git commit -m "$msg"; git push }

function get() { git pull }

# which <app>: Get path for an executable
function which($app)
{
    (Get-Command $app).Definition
}

# Shortcuts for quick navigation
$tools 		= "c:\tools"
$documents 	= $home + "\Documents"
$desktop 	= $home + "\Desktop"
$downloads 	= $home + "\Downloads"
$modules 	= $home + "\Documents\WindowsPowerShell\Modules"

$UserInfo    	= $Env:USERNAME + '@' + $Env:COMPUTERNAME  

# Output verbose git status?
$git_status_verbose = $true

# History Search - CTRL-R
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function Complete

$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$UserType = "User"
$CurrentUser.Groups | foreach { 
    if ($_.value -eq "S-1-5-32-544") {
        $UserType = "Admin"
    } 
}

function prompt {
    $cwd = $(get-location)
    $cwd_short = Get-ShortPath $cwd
    if($UserType -eq "Admin") {
         $host.UI.RawUI.WindowTitle = "" + $cwd_short + " : *Administrator*"
         $host.UI.RawUI.ForegroundColor = "white"
     }
     else {
         $host.ui.rawui.WindowTitle = $cwd_short
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

    Write-Host ($env:UserName) -nonewline -foregroundcolor DarkGreen
    Write-Host (" at ") -nonewline -foregroundcolor Gray
    Write-Host ($env:COMPUTERNAME) -nonewline -foregroundcolor Blue
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
        $prompt = "$"
    }
    Write-Host($prompt) -nonewline -foregroundcolor Gray

    return " "
 }

function Test-Administrator {
    <#
    .Synopsis
    Return True if you are currently running PowerShell as an administrator, False otherwise.
    #>
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Install and setup Powerline stuff
#Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
#Install-Module posh-git -Scope CurrentUser
#Install-Module oh-my-posh -Scope CurrentUser

Import-Module PSReadLine
Import-Module posh-git
Import-Module oh-my-posh

#Set-Theme Paradox
#Set-Theme Honukai
