# (C) 2020-2022 Gordon Engelke
#
# Powershell Core:   ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Powershell:        ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# Azure Cloud Shell: ~/.config/PowerShell/Microsoft.PowerShell_profile.ps1

clear
write-host "`n-{ gengelke posh profile }-`n";

#$host.UI.RawUI.ForegroundColor = "Gray"
#$host.UI.RawUI.BackgroundColor = "Black"

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


#=====================================#
# Install required Powershell modules #
#=====================================#

#Write-Host "Loading Az..." -ForegroundColor Blue
if (-Not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -Scope CurrentUser -SkipPublisherCheck -Confirm:$False -Force -AllowClobber
}
#Import-Module Az

#Write-Host "Loading Terminal-Icons..." -ForegroundColor Blue
if (-Not (Get-Module -ListAvailable -Name Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Scope CurrentUser -SkipPublisherCheck -Confirm:$False -Force
}
Import-Module Terminal-Icons

#Write-Host "Loading PSREadLine..." -ForegroundColor Blue
if (-Not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module -Name PSReadLine -Scope CurrentUser -SkipPublisherCheck -Confirm:$False -Force
}
Import-Module PSReadLine

#Write-Host "Loading posh-git..." -ForegroundColor Blue
if (-Not (Get-Module -ListAvailable -Name posh-git)) {
    Install-Module -Name posh-git -Scope CurrentUser -Confirm:$False -Force
}
Import-Module posh-git

#Write-Host "Loading oh-my-posh..." -ForegroundColor Blue
#if (-Not (Get-Module -ListAvailable -Name oh-my-posh)) {
#    Install-Module -Name oh-my-posh -Scope CurrentUser -Confirm:$False -Force
#}
$env:POSH_GIT_ENABLED = $true
#Import-Module oh-my-posh
#Set-PoshPrompt -Theme sorin
#Set-PoshPrompt -Theme ~/.ge.theme.omp.json
#oh-my-posh init pwsh | Invoke-Expression
oh-my-posh init pwsh --config ~/.ge.theme.omp.json | Invoke-Expression


#==================#
# PSReadLine Stuff #
#==================#

Set-PSReadLineOption -MaximumHistoryCount 10000
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadlineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -BellStyle Visual
# Exit Powershell on Ctrl+d
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
#Set-PSReadLineOption -EditMode emacs
# Automatically copy text to Clipboard
Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste

# This key handler shows the entire or filtered history using Out-GridView. The
# typed text is used as the substring pattern for filtering. A selected command
# is inserted to the command line without invoking. Multiple command selection
# is supported, e.g. selected by Ctrl + Click.
Set-PSReadLineKeyHandler -Key F7 `
                         -BriefDescription History `
                         -LongDescription 'Show command history' `
                         -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern)
    {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath))
        {
            if ($line.EndsWith('`'))
            {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines)
                {
                    "$lines`n$line"
                }
                else
                {
                    $line
                }
                continue
            }

            if ($lines)
            {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern)))
            {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title History -PassThru
    if ($command)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}

# The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience.  I'd like to include functions
# in the module that do this, but this implementation still isn't as smart
# as ReSharper, so I'm just providing it as a sample.

Set-PSReadlineKeyHandler -Key '"',"'" `
                            -BriefDescription SmartInsertQuote `
                            -LongDescription "Insert paired quotes if not already on a quote" `
                            -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar) {
        # Just move the cursor
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else {
        # Insert matching quotes, move cursor to be in between the quotes
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)" * 2)
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
    }
}

Set-PSReadlineKeyHandler -Key '(','{','[' `
                            -BriefDescription InsertPairedBraces `
                            -LongDescription "Insert matching braces" `
                            -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)        
}

Set-PSReadlineKeyHandler -Key ')',']','}' `
                            -BriefDescription SmartCloseBraces `
                            -LongDescription "Insert closing brace or skip" `
                            -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadlineKeyHandler -Key Backspace `
                            -BriefDescription SmartBackspace `
                            -LongDescription "Delete previous character or matching quotes/parens/braces" `
                            -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0)
    {
        $toMatch = $null
        switch ($line[$cursor])
        {
            <#case#> '"' { $toMatch = '"'; break }
            <#case#> "'" { $toMatch = "'"; break }
            <#case#> ')' { $toMatch = '('; break }
            <#case#> ']' { $toMatch = '['; break }
            <#case#> '}' { $toMatch = '{'; break }
        }

        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}

#endregion Smart Insert/Delete

# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadlineKeyHandler -Key Alt+w `
                            -BriefDescription SaveInHistory `
                            -LongDescription "Save current line in history but do not execute" `
                            -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# Insert text from the clipboard as a here string
Set-PSReadlineKeyHandler -Key Ctrl+Shift+v `
                            -BriefDescription PasteAsHereString `
                            -LongDescription "Paste the clipboard text as a here string" `
                            -ScriptBlock {
    param($key, $arg)

    Add-Type -Assembly PresentationCore
    if ([System.Windows.Clipboard]::ContainsText())
    {
        # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
        $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n","`n").TrimEnd()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
    }
}
    
# Tips:
# Insert the last argument from the previous command with Alt+.


#=========================#
# History Search - CTRL-R #
#=========================#

Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key Tab -Function Complete
#Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
function hh { Get-content (Get-PSReadLineOption).HistorySavePath }


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
function ll  { ls -al @args }
function lll { ls -strahl @args }


#=============#
# Cloud stuff #
#=============#

# Install and configure Azure DevOps CLI extension
if (-Not (az extension list -o table | grep azure-devops)) { 
    az extension add --name azure-devops
    az devops configure --defaults organization=https://dev.azure.com/bosch project=BoschDevelopmentCloud
}

New-Alias -Name kc -Value kubectl -Description "kubectl alias"
function kc-pods { kubectl get pods -A --field-selector=metadata.namespace!=kube-system -o wide }
function kc-kill { 
    $podId = kubectl get pods -n pgadmin-01 --output=jsonpath='{range .items[*]}{.metadata.name}{\"\n\"}{end}' | Select-String "pgadmin4";
    Write-Host "[$(Get-Date -Format HH:mm:ss)] Killing Pod $podId..." -ForegroundColor Yellow
    kubectl exec -n pgadmin-01 -it $podId -- /bin/sh -c  "/bin/kill 1" 
}

function az-logout() {
    Logout-AzAccount | Out-null
    az logout
}

function az-login() {
    if ([string]::IsNullOrEmpty($(Get-AzContext).Account)) { 
        Write-Host "Logging in to Azure (pwsh)..." -ForegroundColor Blue
        Connect-AzAccount | Out-null
    } else {
        Write-Host "Already logged in to Azure (pwsh)..." -ForegroundColor Green
    }
    Write-Host "Logging in to Azure (az)..." -ForegroundColor Blue
    az login
    az account show
}

function az-set($env) {
    If ($env -eq 'dev' -Or $env -eq 'qa' -Or $env -eq 'prod' -Or $env -eq 'sandbox') {
        Write-Host "Setting Azure environment to '$env'..." -ForegroundColor Blue
        Write-Host "Will use Azure config dir '~/.azure_$($env)'..." -ForegroundColor Blue
        $env:AZURE_CONFIG_DIR="~/.azure_$($env)"
        Write-Host "Will use kubectl context $env-shared-01-aks'..." -ForegroundColor Blue
        kubectl config set-context "$($env)-shared-01-aks"
        kubectl config use-context "$($env)-shared-01-aks"
        $context = Get-AzContext
        if (!$context) {
            Write-Host "Connecting to Azure account..." -ForegroundColor Blue
            if ($env -eq 'sandbox') {
                Connect-AzAccount -Subscription HUGO-Sandbox | Out-null
            } else {
                Connect-AzAccount -Subscription HUGO-PALIM_Shared-$env | Out-null
            }
        } else {
            Write-Host "Already connected to Azure account." -ForegroundColor Green
        }

        if ($context.Subscription.Name -ne "HUGO-PALIM_Shared-$env" -Or $context.Subscription.Name -ne "HUGO-Sandbox") {
            if ($env -eq 'sandbox') {
                Write-Host "Connecting to subscription HUGO-Sandbox..." -ForegroundColor Blue
                Select-AzSubscription -SubscriptionName "HUGO-Sandbox" | Out-null
                Get-AzSubscription -SubscriptionName "HUGO-Sandbox" | Set-AzContext | Out-null
            } else {
                Write-Host "Connecting to subscription HUGO-PALIM_Shared-$env..." -ForegroundColor Blue
                Select-AzSubscription -SubscriptionName "HUGO-PALIM_Shared-$env" | Out-null
                Get-AzSubscription -SubscriptionName "HUGO-PALIM_Shared-$env" | Set-AzContext | Out-null
            }
        } else {
            if ($env -eq 'sandbox') {
                Write-Host "Already connected to subscription HUGO-Sandbox." -ForegroundColor Green
            } else {
                Write-Host "Already connected to subscription HUGO-PALIM_Shared-$env." -ForegroundColor Green
            }
        }

        if($(az account show)) {
            Write-Host "Already logged in to Azure (az login)..." -ForegroundColor Green
        } else {
            Write-Host "Logging in to Azure (az login)..." -ForegroundColor Blue
            az login --output none
        }
        if ($(az account show --query name -o tsv) -ne "HUGO-PALIM_Shared-$env" -Or $(az account show --query name -o tsv) -ne "HUGO-Sandbox") {
            if ($env -eq 'sandbox') {
                Write-Host "Setting active subscription to HUGO-Sandbox..." -ForegroundColor Blue
                az account set -s HUGO-Sandbox; 
            } else {
                Write-Host "Setting active subscription to HUGO-PALIM_Shared-$env..." -ForegroundColor Blue
                az account set -s HUGO-PALIM_Shared-$env; 
            }
        }
        else {
            if ($env -eq 'sandbox') {
                Write-Host "Already using subscription HUGO-Sandbox." -ForegroundColor Green
            } else {
                Write-Host "Already using subscription HUGO-PALIM_Shared-$env." -ForegroundColor Green
            }
        }
        If ($env -eq 'dev' -Or $env -eq 'qa' -Or $env -eq 'prod') {
            Write-Host "Setting AKS credentials..." -ForegroundColor Blue
            az aks get-credentials --resource-group $env-shared-01-aks-rg --name $env-shared-01-aks --subscription HUGO-PALIM_Shared-$env 
        }
        Write-Host "Adding local IP address $(get-ip) to KeyVault devcloud-$env-shared-kv..." -ForegroundColor Blue
        az keyvault network-rule add --name devcloud-$env-shared-kv --ip-address $(get-ip) -o none
    } else {
        Write-Host("Invalid environment given: '$env'. Must be 'dev', 'qa', 'prod' or 'sandbox'.") -ForegroundColor Red
    }
    $env:bdcenv = $env
}

function az-show {
    $subscription = az account show --query name -o tsv
    switch ($subscription.split("-")[-1].ToUpper()) {
        DEV  { $color = "Green"  }
        QA   { $color = "Yellow" }
        PROD { $color = "RED"    }
    }
    write-host $subscription -ForegroundColor $color
}

function az-tunnel {
    param (
        [string]$vmName
    )
    $instanceId = '01'
    write-host "Creating SSH tunnel to VM '$vmName-$instanceId'..."
    $subscriptionId = az account show --query id -o tsv
    az network bastion tunnel --name ${env}-shared-01-bastion --resource-group ${env}-shared-01-bastion-rg --target-resource-id /subscriptions/${subscriptionId}/resourceGroups/${env}-shared-${instanceId}-${vmName}-rg/providers/Microsoft.Compute/virtualMachines/${env}-shared-${instanceId}-${vmName}-vm --resource-port 22 --port 2222
}

function az-ssh {
    param (
        [string]$vmName,
        [string]$username
    )

    $instanceId = '01'
    write-host "Creating SSH connection to VM '$vmName-$instanceId'..."
    $vmPassword = az keyvault secret show --name ${vmName}Vm-01-${username}Password-utf8 --vault-name devcloud-${env}-shared-kv --query value -o tsv
    sshpass -p $vmPassword ssh ${username}@127.0.0.1 -p 2222 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=5" -o "ServerAliveCountMax=5"
}

function get-ip {
    curl ifconfig.me/ip
}


#=============#
# Git helpers #
#=============#

function ga() { git add -A }
function gs() { git status }
function gas() { git add -A; git status }
function gcp($msg) { git commit -m "$msg"; git push }
function gacp($msg) { git add .; git commit -m "$msg"; git push }
function get() { git checkout develop; git pull }
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


#===================#
# Customized Prompt #
#===================#

#function prompt {
#    $cwd = $(get-location)
#    #$cwd_short = Get-ShortPath $cwd
#    $cwd_short = ($pwd.path).Replace($env:HOME,"~")
#    if($UserType -eq "Admin"){
#         $host.UI.RawUI.WindowTitle = "" + $cwd_short + " : *Administrator*"
#         $host.UI.RawUI.ForegroundColor = "white"
#     }
#     else {
#         $host.ui.rawui.WindowTitle = $cwd_short
#     }
#
#    Write-Host("")
#
#    $symbolicref = git symbolic-ref HEAD
#    $has_changes = $false
#    $git_branch = $NULL
#    if($symbolicref -ne $NULL) {
#        $git_branch = $symbolicref.substring($symbolicref.LastIndexOf("/") +1 )
#        $differences = (git diff-index --name-status HEAD)
#        if($differences -ne $NULL) {
#            $git_update_count = [regex]::matches($differences, "M`t").count
#            $git_create_count = [regex]::matches($differences, "A`t").count
#            $git_delete_count = [regex]::matches($differences, "D`t").count
#            $has_changes = ($git_create_count -gt 0) -or ($git_update_count -gt 0) -or ($git_delete_count -gt 0)
#        }
#    }
#
#    Write-Host ([Environment]::UserName) -nonewline -foregroundcolor Green
#    Write-Host ("@") -nonewline -foregroundcolor Gray
#    if (Test-Path env:AZURE_HTTP_USER_AGENT) { 
#        Write-Host ("Azure") -nonewline -foregroundcolor Blue
#    } else {
#        Write-Host ([Environment]::MachineName) -nonewline -foregroundcolor Blue
#    }
#    Write-Host (": ") -nonewline -foregroundcolor Gray
#    Write-Host ($cwd_short) -nonewline -foregroundcolor Yellow
#
#    if ($git_branch -ne $NULL) {
#        Write-Host (" (") -nonewline -foregroundcolor Cyan
#        Write-Host ($git_branch) -nonewline -foregroundcolor  Cyan
#        Write-Host (") ") -nonewline -foregroundcolor Cyan
#        Write-Host("[") -nonewline -foregroundcolor Gray
#        if ($git_status_verbose -eq $true) {
#        if ($has_changes -eq $true) {
#                Write-Host("a") -nonewline -foregroundcolor Yellow
#                Write-Host(":") -nonewline -foregroundcolor Gray
#                Write-Host($git_create_count) -nonewline -foregroundcolor White
#                Write-Host(",") -nonewline -foregroundcolor Gray
#                Write-Host("m") -nonewline -foregroundcolor Yellow
#                Write-Host(":") -nonewline -foregroundcolor Gray
#                Write-Host($git_update_count) -nonewline -foregroundcolor White
#                Write-Host(",") -nonewline -foregroundcolor Gray
#                Write-Host("r") -nonewline -foregroundcolor Yellow
#                Write-Host(":") -nonewline -foregroundcolor Gray
#                Write-Host($git_delete_count) -nonewline -foregroundcolor White
#            }
#            else {
#                Write-Host("$") -nonewline -foregroundcolor Yellow
#            }
#        }
#        else {
#            if ($has_changes -eq $true) {
#                Write-Host("!") -nonewline -foregroundcolor Yellow
#            }
#            Write-Host("$") -nonewline -foregroundcolor Yellow
#        }
#        Write-Host("]") -nonewline -foregroundcolor Gray
##        & $GitPromptScriptBlock
#    }
#
#    Write-Host("")
#
#    $prompt = "posh>"
#    if ($git_branch -ne $NULL) {
#        $prompt = "posh>"
#    }
#    Write-Host($prompt) -nonewline -foregroundcolor Gray
#
#    return " "
# }

#function Test-Administrator {
#    <#
#    .Synopsis
#    Return True if you are currently running PowerShell as an administrator, False otherwise.
#    #>
#    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
#    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
#}

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

# Source: https://stackoverflow.com/questions/16474973/windows-powershell-persistent-history#

# Save last 200 history items on exit
$MaximumHistoryCount = 10000
$historyPath = Join-Path (split-path $profile) history.clixml

# Hook powershell's exiting event & hide the registration with -supportevent (from nivot.org)
Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
      Get-History | Export-Clixml $historyPath
}.GetNewClosure()

# Load previous history, if it exists
if ((Test-Path $historyPath)) {
    Import-Clixml $historyPath | ? {$count++;$true} | Add-History
#    Write-Host -Fore Green "Loaded $count history item(s)."
}

# Aliases and functions to make it useful
#New-Alias -Name i -Value Invoke-History -Description "Invoke history alias"
#Rename-Item Alias:\h original_h -Force
function h { Get-History -c $MaximumHistoryCount }
function hg($arg) { Get-History -c $MaximumHistoryCount | out-string -stream | select-string $arg }
