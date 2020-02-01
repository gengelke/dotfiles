# (C) 2020 Gordon Engelke <reject@email.de>

write-host "Loading powershell profile...";

# [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }
$host.UI.RawUI.ForegroundColor 	 = "Gray"
$host.UI.RawUI.BackgroundColor 	 = "Black"

function Set-ConsoleWindow
{
    param(
        [int]$Width,
        [int]$Height
    )

    $WindowSize = $Host.UI.RawUI.WindowSize
    $WindowSize.Width  = [Math]::Min($Width, $Host.UI.RawUI.BufferSize.Width)
    $WindowSize.Height = $Height

    try{
        $Host.UI.RawUI.WindowSize = $WindowSize
    }
    catch [System.Management.Automation.SetValueInvocationException] {
        $Maxvalue = ($_.Exception.Message |Select-String "\d+").Matches[0].Value
        $WindowSize.Height = $Maxvalue
        $Host.UI.RawUI.WindowSize = $WindowSize
    }
}

Set-ConsoleWindow 160 40

$os = Get-WmiObject Win32_OperatingSystem
Write-Host "Operating system: $($os.OSArchitecture) $($os.Caption) version $($os.Version)"
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"

Import-Module PSReadLine

#set-executionpolicy RemoteSigned process

Set-Alias vim "C:\tools\vim\vim82\vim.exe"
Set-Alias vi vim
function edit ($file) { & "{C:\ProgramData\chocolatey\bin\notepad++.exe" $file }
function wipe { $Host.UI.RawUI.ForegroundColor = "white"; $Host.UI.RawUI.BackgroundColor = "black"; clear; }
function touch ($file) { echo "" >> $file; }
function explore { "explorer.exe $(pwd)" | iex }
function cl($loc) {cd $loc; ls;} 
function up() {cd ..;}
function x { exit }

# Git helpers
function ga() { git add -A }
function gs() { git status }
function gas() { git add -A; git status }
function gcp($msg) { git commit -m "$msg"; git push }
function get() { git pull }

# which <app>: Get path for an executable
function which($app)
{
    (Get-Command $app).Definition
}

function getMachineType() {
    if ($IsLinux) {
        return "Linux";
    };

    if ($IsOSX) {
        return "macOS";
    }

    return "Windows";
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
    if($UserType -eq "Admin") {
         $host.UI.RawUI.WindowTitle = "" + $cwd + " : *Administrator*"
         $host.UI.RawUI.ForegroundColor = "white"
     }
     else {
         $host.ui.rawui.WindowTitle = $cwd
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
    Write-Host ("@") -nonewline -foregroundcolor DarkGreen
    Write-Host ($env:COMPUTERNAME) -nonewline -foregroundcolor DarkGreen
    Write-Host (" ") -nonewline -foregroundcolor Gray
    Write-Host ($cwd) -nonewline -foregroundcolor Yellow

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
