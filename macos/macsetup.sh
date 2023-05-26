#!/bin/bash

# (C) 2017-2021 Gordon Engelke

hostname="genmac12"
username="Gordon Engelke"
useraccount="gengelke"
userid="502"
usergroupid="20"

# Close any open System Preferences panes, to prevent them from overriding settings weâ€™re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

xcode-select --install
#xcode-select --reset
#sleep 120

cp bash/bashrc ~/.bashrc
cp vim/vimrc ~/.vimrc
cp tmux/tmux.conf ~/.tmux.conf
cp os/logouthook ~/.logouthook

# Install Homebrew
echo "Installing Homebrew package manager"

which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

# AppStore:
# Bandwith+
# Greenshot
# Magnet
# Microsoft Remote Desktop

echo "Installing desired/required Homebrew Cask packages"
brew tap homebrew/cask
brew install --cask \
     1password \
     1password-cli \
     angry-ip-scanner \
     awscli \
     azure-cli \
     balenaetcher \
     bartender \
     browsh \
     caffeine \
     carbon-copy-cloner \
     copyq \
     cryptomator \
     cyberduck \
     dash \
     docker \
     dozer \
     drawio \
     duet \
     firefox \
     gimp \
     google-chrome \
     grc \
     iterm2 \
     karabiner-elements \
     keycastr \
     kubectl \
     kubernetes-helm \
     little-snitch \
     lynx \
     micro-snitch \
     microsoft-office \
     microsoft-teams \
     minikube \
     mountain-duck \
     mosh \
     nordvpn \
     onedrive \
     pdf-expert \
     pngpaste \
     powershell \
     qrencode \
     sipcalc \
     tigervnc-viewer \
     tripmode \
     vagrant \
     virtualbox \
     virtualbox-extension-pack \
     visual-studio-code \
     vlc \
     vmware-fusion \
     vnc-viewer \
     w3m \
     wireshark \
     xnviewmp \
     xquartz
  
#     alfred \
#     amazon-music \
#     audio-hijack \
#     cakebrew \
#     clementine \
#     dozer \
#     evernote \
#     fantastical \
#     fluor \
#     hex-fiend \
#     istat-menus \
#     jumpcut \
#     keepassx \
#     libreoffice \
#     pycharm-ce \
#     skype \
#     slack \
#     snagit \
#     soundsource \
#     spectacle \
#     spotify \
#     telegram \
#     textual \
#     tunnelblick \
#     veracrypt \
#     vox \

# Install required/desired software through Homebrew
echo "Installing desired/required Homebrew packages"
brew install \
     ack \
     bat \
     ansible \
     bash \
     bash-completion \
     freerdp \
     gdb \
     git \
     glances \
     gnu-sed \
     java \
     jq \
     mas \
     netcat \
     nmap \
     node \
     openssl \
     packer \
     pulseaudio \
     pygments \
     python3 \
     socat \
     telnet \
     terraform \
     tmux \
     tree \
     wget \
     xbar

#     ext4fuse \
#     graphviz \
#     mono \
#     textbar \

echo "Installing security applications through Homebrew"
brew install --cask \
     blockblock \
     do-not-disturb \
     KextViewr \
     knockknock \
     Lockdown \
     lulu \
     RansomWhere \
     taskexplorer

echo "Installing Homebrew font packages"
brew tap homebrew/cask-fonts
brew install font-terminus \
             font-menlo-for-powerline \
             font-meslo-for-powerline \
             font-powerline-symbols

             #font-terminus-nerd-font \
             #font-terminus-nerd-font-mono \

#brew cask install mactex
#brew tap miktex/miktex
#brew install miktex

#brew cask install microsoft-azure-storage-explorer \
#                  android-platform-tools \

#brew tap cloudfoundry/tap
#brew install cf-cli

echo "Installing Python stuff"
brew install brew-pip pip-completion python
python3 -m pip install --upgrade pip
pip3 install nose tornado msrest msrestazure azure ansible[azure] openshift --upgrade

#wget https://downloads.citrix.com/19721/CitrixWorkspaceApp.dmg?__gda__=exp=1628196887~acl=/*~hmac=64c654dfbb629db7eaa4cf96fe4cd9d0e6827a5406b417eec96098aa267cf9f8 -P ~/Downloads
#https://www.citrix.com/de-de/downloads/workspace-app/mac/

#wget https://downloads.citrix.com/11449/HDX_RealTime_Media_Engine_2.9.400_for_OSX.dmg?__gda__=exp=1628197194~acl=/*~hmac=8e6ad63feffeefe9e5abcfb6f0977e4a70f3b22a4c831396e3630169a7169d05 -P ~/Downloads
#https://www.citrix.com/de-de/downloads/citrix-receiver/additional-client-software/hdx-realtime-media-engine.html

#https://support.citrix.com/article/CTX136578

###############################################################################
# Security                                                                    #
###############################################################################

echo "Setting security preferences"

# Turn off the “Application Downloaded from Internet” quarantine warning:
defaults write com.apple.LaunchServices LSQuarantine -bool NO

# Set Lock Message to show on login screen
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "Device Owner: @web.de"

# Disable auto-login
# sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable guest user
defaults write com.apple.AppleFileServer guestAccess -bool false
defaults write SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

# Hide administrator account from login screen
sudo dscl . create /Users/admin IsHidden 1


###############################################################################
# Software updates                                                            #
###############################################################################

echo "Setting software updates preferences"

sudo softwareupdate --schedule OFF

# Automatically check for updates (required for any downloads):
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticCheckEnabled -bool YES

# Download updates automatically in the background
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool YES

# Install app updates automatically:
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool YES

# Don't Install macos updates automatically
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false

# Install system data file updates automatically:
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist ConfigDataInstall -bool YES

# Install critical security updates automatically:
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist CriticalUpdateInstall -bool YES

sudo softwareupdate --schedule ON


###############################################################################
# Files and folders                                                           #
###############################################################################

echo "Setting files and folders preferences"

# Show the ~/Library directory
chflags nohidden "${HOME}/Library"

# Show the /Volumes folder
chflags nohidden /Volumes

# Show the ~/bin directory
if [[ -d "${HOME}/bin" ]]; then
    chflags nohidden "${HOME}/bin"
fi

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true


###############################################################################
# Set energy preferences                                                      #
###############################################################################

echo "Setting energy preferences"

# From <https://github.com/rtrouton/rtrouton_scripts/>
IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`
if [[ "$IS_LAPTOP" != "" ]]; then
    sudo pmset -b sleep 30 disksleep 10 displaysleep 5 halfdim 1
    sudo pmset -c sleep 0 disksleep 0 displaysleep 30 halfdim 1
else
    sudo pmset sleep 0 disksleep 0 displaysleep 30 halfdim 1
fi

# Set standby delay to 24 hours (default is 1 hour)
sudo pmset -a standbydelay 86400


###############################################################################
# Audio and sound effects                                                     #
###############################################################################

echo "Setting audio and sound preferences"

# Disable feedback when changing volume
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false

# Disable flashing the screen when an alert sound occurs (accessibility)
defaults write NSGlobalDomain com.apple.sound.beep.flash -bool false

# Alert volume 50%
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0.6065307

# Disable interface sound effects
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -bool false


###############################################################################
# Ambient light sensor                                                        #
###############################################################################

echo "Setting ambient light sensor preferences"

# Display -> Do not automatically adjust brightness
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool false

# Keyboard -> Adjust keyboard brightness in low light
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool true
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Keyboard Dim Time" -int 300


###############################################################################
# Login screen                                                                #
###############################################################################

echo "Setting login screen preferences"

# Display login window as: Name and password
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool false

# Show shut down etc. buttons
sudo defaults write /Library/Preferences/com.apple.loginwindow PowerOffDisabled -bool false

# Don't show any password hints
sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0

# Allow fast user switching
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool true

# Hide users with UID under 500
sudo defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool YES
# Reveal IP address, hostname, OS version, etc. when clicking the clock

# in the login window
#sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName


###############################################################################
# Menu bar                                                                    #
###############################################################################

echo "Setting Menu bar preferencers"

defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/TextInput.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Displays.menu" \
    "/System/Library/CoreServices/Menu Extras/VPN.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"

# Show percentage value of remaining battery
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "YES"

# Setup the menu bar date format
defaults write com.apple.menuextra.clock DateFormat -string "MMM d HH:mm"

# Flash the : in the menu bar
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# 24 hour time
#defaults write NSGlobalDomain AppleICUForce24HourTime -bool false
#defaults write NSGlobalDomain AppleICUTimeFormatStrings -dict \
#  1 -string "H:mm" \
#  2 -string "H:mm:ss" \
#  3 -string "H:mm:ss z" \
#  4 -string "H:mm:ss zzzz"

# Show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true


###############################################################################
# General UI/UX                                                               #
###############################################################################

echo "Setting general UI/UX preferences"

# Set UI interface theme to dark
sudo defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark

# Make MacOS Mojave Dark Mode less dark
defaults write -g NSRequiresAquaSystemAppearance -bool Yes

# Set background color to "Solid Gray Pro Dark"
#osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Library/Desktop Pictures/Solid Colors/Solid Gray Pro Dark.png"'

# Set background picture
# TODO
sudo osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/$username/Documents/dotfiles/macos/wallpaper_grey_curves.jpg"'
# Expand 'Save As…' dialog boxes by default:
defaults write -g NSNavPanelExpandedStateForSaveMode -boolean true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel dialog boxes by default:
defaults write -g PMPrintingExpandedStateForPrint -boolean true
defaults write -g PMPrintingExpandedStateForPrint2 -bool true

# Quit Printer App after Print Jobs complete:
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Change login screen background:
# sudo defaults write /Library/Preferences/com.apple.loginwindow DesktopPicture "/Library/Desktop Pictures/Aqua Blue.jpg"

# Set computer name (as done via System Preferences -> Sharing)
sudo scutil --set ComputerName $hostname
sudo scutil --set HostName $hostname
sudo scutil --set LocalHostName $hostname
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $hostname

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Enable transparency in the menu bar and elsewhere
defaults write com.apple.universalaccess reduceTransparency -bool true
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Disable the â€œAre you sure you want to open this application?â€ dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable automatic capitalization as itâ€™s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as theyâ€™re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as itâ€™s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as theyâ€™re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
# all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
#sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and time & languages      #
###############################################################################

echo "Setting trackpad, keyboard and time & languages preferences"

# Disable â€œnaturalâ€ (Lion-style) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Swipe between pages with two fingers
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true

# Set scroll direction
sudo defaults write /Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool false

# Enable key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool FALSE

# Set keyboard repeat rate
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 2

#for USER_TEMPLATE in "/System/Library/User Template"/*
#  do
#    sudo defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences com.apple.swipescrolldirection -bool FALSE
#    sudo defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences ApplePressAndHoldEnabled -bool FALSE
#    sudo defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences KeyRepeat -int 2
#  done

# Set language and text formats
# Note: if youâ€™re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "US"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>10</integer><key>KeyboardLayout Name</key><string>USInternational-PC</string></dict>'
defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>11</integer><key>KeyboardLayout Name</key><string>German-DIN-2137</string></dict>'

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
systemsetup -settimezone "Europe/Berlin" > /dev/null


###############################################################################
# Screen                                                                      #
###############################################################################

echo "Setting screen preferences"

defaults write -g NSWindowShouldDragOnGesture -bool true

# Screen Saver: Flurry
defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName -string "Flurry" path -string "/System/Library/Screen Savers/Flurry.saver" type -int 0

# Save screenshots to the desktop
#defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots to directory ~/Pictures
defaults write com.apple.screencapture location -string "${HOME}/Pictures"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# Double-click a window's title bar to minimize
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false


###############################################################################
# Finder                                                                      #
###############################################################################

echo "Setting Finder preferences"

# Disable the macOS Crash reporter (quit dialog after an application crash)
defaults write com.apple.CrashReporter DialogType prompt
# To enable the crash reporter (default) change none to prompt
# Get a crash notification in the Notification Center instead of a window
defaults write com.apple.CrashReporter UseUNC 1

# Expand the "Open with" and "Sharing & Permissions" panes
defaults write com.apple.finder FXInfoPanesExpanded -dict OpenWith -bool true Privileges -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# New window points to home
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: allow quitting via âŒ˜ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Desktop as the default location for new Finder windows
# For other paths, use `PfLo` and `file:///full/path/here/`
#defaults write com.apple.finder NewWindowTarget -string "PfDe"
#defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: show path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true; killall Finder

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Enable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool true


# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false


###############################################################################
# Activity Monitor                                                            #
###############################################################################

echo "Setting Activity Monitor preferences"

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# Show all processes
defaults write com.apple.ActivityMonitor ShowCategory -int 100

# Mavericks: Add the "% CPU" column to the Disk and Network tabs
defaults write com.apple.ActivityMonitor "UserColumnsPerTab v4.0" -dict \
    '0' '( Command, CPUUsage, CPUTime, Threads, IdleWakeUps, PID, UID )' \
    '1' '( Command, anonymousMemory, Threads, Ports, PID, UID, ResidentSize )' \
    '2' '( Command, PowerScore, 12HRPower, AppSleep, graphicCard, UID )' \
    '3' '( Command, bytesWritten, bytesRead, Architecture, PID, UID, CPUUsage )' \
    '4' '( Command, txBytes, rxBytes, txPackets, rxPackets, PID, UID, CPUUsage )'

# Mavericks: Sort by CPU usage in Disk and Network tabs
defaults write com.apple.ActivityMonitor UserColumnSortPerTab -dict \
    '0' '{ direction = 0; sort = CPUUsage; }' \
    '1' '{ direction = 0; sort = ResidentSize; }' \
    '2' '{ direction = 0; sort = 12HRPower; }' \
    '3' '{ direction = 0; sort = CPUUsage; }' \
    '4' '{ direction = 0; sort = CPUUsage; }'

# Select the Network tab
defaults write com.apple.ActivityMonitor SelectedTab -int 4

# Update Frequency: Often (2 sec)
defaults write com.apple.ActivityMonitor UpdatePeriod -int 2

# Mavericks: Show Data in the Disk graph (instead of IO)
defaults write com.apple.ActivityMonitor DiskGraphType -int 1

# Mavericks: Show Data in the Network graph (instead of packets)
defaults write com.apple.ActivityMonitor NetworkGraphType -int 1


###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

echo "Setting Dock and Dashboard preferences"

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Minimize windows into their applicationâ€™s icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Hide the resently opened items in Dock
defaults write com.apple.dock show-recents -bool FALSE

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you donâ€™t use
# the Dock to launch apps.
defaults write com.apple.dock persistent-apps -array

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Visual Studio Code.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Outlook.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/VirtualBox.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/VMware Fusion.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Docker.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Cyberduck.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Spotify.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/XnViewMP.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Textual.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Slack.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Show only open applications in the Dock
#defaults write com.apple.dock static-only -bool true

# Donâ€™t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# Donâ€™t group windows by application in Mission Control
# (i.e. use the old ExposÃ© behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0
# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Do not Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool false


###############################################################################
# Safari & WebKit                                                             #
###############################################################################

echo "Setting Safari & WebKit preferences"

# Appearance

# Show status bar
defaults write com.apple.Safari ShowStatusBar -bool true

# Show favorites bar
defaults write com.apple.Safari ShowFavoritesBar -bool true
defaults write com.apple.Safari "ShowFavoritesBar-v2" -bool true

# Don't show tab bar
defaults write com.apple.Safari AlwaysShowTabBar -bool false


# General settings

# Safari opens with: A new window
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -bool false

# New windows open with: Empty Page
defaults write com.apple.Safari NewWindowBehavior -int 1

# New tabs open with: Empty Page
defaults write com.apple.Safari NewTabBehavior -int 1

# Homepage
defaults write com.apple.Safari HomePage -string "about:blank"

# Don't open "safe" files after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false


# Tabs settings

# Open pages in tabs instead of windows: automatically
defaults write com.apple.Safari TabCreationPolicy -int 1

# Don't make new tabs active
defaults write com.apple.Safari OpenNewTabsInFront -bool false

# Command-clicking a link creates tabs
defaults write com.apple.Safari CommandClickMakesTabs -bool true


# Autofill settings

# Don't remember passwords
defaults write com.apple.Safari AutoFillPasswords -bool true


# Search settings

# Search engine: Google
defaults write -g NSPreferredWebServices -dict 'NSWebServicesProviderWebSearch' '{ NSDefaultDisplayName = Google; NSProviderIdentifier = com.google.www; }'

# Enable search engine suggestions
defaults write com.apple.Safari SuppressSearchSuggestions -bool false

# Smart search field:

# Disable Safari suggestions
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari UniversalSearchFeatureNotificationHasBeenDisplayed -bool true

# Disable top hit preloading
defaults write com.apple.Safari PreloadTopHit -bool false

# Disable quick website search
defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool false


# Security settings

# Warn About Fraudulent Websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Enable plug-ins
defaults write com.apple.Safari WebKitPluginsEnabled -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool true

# Enable Java
defaults write com.apple.Safari WebKitJavaEnabled -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool true

# Enable JavaScript
defaults write com.apple.Safari WebKitJavaScriptEnabled -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptEnabled -bool true

# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Reading list
defaults write com.apple.Safari com.apple.Safari.ReadingListFetcher.WebKit2PluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ReadingListFetcher.WebKit2LoadsImagesAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ReadingListFetcher.WebKit2LoadsSiteIconsIgnoringImageLoadingPreference -bool true
defaults write com.apple.Safari com.apple.Safari.ReadingListFetcher.WebKit2JavaScriptEnabled -bool false


# Privacy settings

# Cookies and website data
# - Always block
#defaults write com.apple.Safari WebKitStorageBlockingPolicy -int 2
#defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2StorageBlockingPolicy -int 2

# Website use of location services
# 0 = Deny without prompting
# 1 = Prompt for each website once each day
# 2 = Prompt for each website one time only
defaults write com.apple.Safari SafariGeolocationPermissionPolicy -int 0

# Do not track
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true


# Notifications

# Don't even ask about the push notifications
defaults write com.apple.Safari CanPromptForPushNotifications -bool true


# Extensions settings

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true


# Advanced settings

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Privacy: donâ€™t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safariâ€™s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Prevent Safari from opening â€˜safeâ€™ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Deny hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable Java
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Disable auto-playing video
defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

# Enable â€œDo Not Trackâ€
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true


###############################################################################
# Disk Utility                                                                #
###############################################################################

echo "Setting Disk Utility preferences"

# Enable the debug menu in Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# View -> Show All Devices
defaults write com.apple.DiskUtility SidebarShowAllDevices -bool true


###############################################################################
# Contacts (Address Book)                                                     #
###############################################################################

echo "Setting Contacts preferences"

# Address format
defaults write com.apple.AddressBook ABDefaultAddressCountryCode -string "fi"

# Sort by last name
defaults write com.apple.AddressBook ABNameSortingFormat -string "sortingLastName sortingFirstName"

# Display format "Last, First" (High Sierra)
defaults write NSGlobalDomain NSPersonNameDefaultDisplayNameOrder -int 2

# Prefer nicknames
defaults write NSGlobalDomain NSPersonNameDefaultShouldPreferNicknamesPreference -bool true


###############################################################################
# Calendar (iCal)                                                             #
###############################################################################

echo "Setting Calendar preferences"

# Show week numbers
defaults write com.apple.iCal "Show Week Numbers" -bool true

# Show 7 days
defaults write com.apple.iCal "n days of week" -int 7

# Week starts on monday
defaults write com.apple.iCal "first day of week" -int 1

# Day starts at 8am
defaults write com.apple.iCal "first minute of work hours" -int 480

# Day ends at 6pm
defaults write com.apple.iCal "last minute of work hours" -int 1080

# Show event times
defaults write com.apple.iCal "Show time in Month View" -bool true

# Show events in year view
defaults write com.apple.iCal "Show heat map in Year View" -bool true


###############################################################################
# Mail                                                                        #
###############################################################################

echo "Setting Mail preferences"

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Disable automatic spell checking
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

# Mark all messages as read when opening a conversation
defaults write com.apple.mail ConversationViewMarkAllAsRead -bool true


###############################################################################
# Terminal & iTerm 2                                                          #
###############################################################################

echo "Setting Terminal preferences"

cp ./Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4
# Use a modified version of the Solarized Dark theme by default in Terminal.app
#osascript <<EOD
#tell application "Terminal"
#	local allOpenedWindows
#	local initialOpenedWindows
#	local windowID
#	(* Store the IDs of all the open terminal windows. *)
#	set initialOpenedWindows to id of every window
#	set themeName to "genmac_grey.itermcolors"
#	(* Open the custom theme so that it gets added to the list
#	   of available terminal themes (note: this will open two
#	   additional terminal windows). *)
#	do shell script "open '$HOME/init/" & themeName & ".terminal'"
#	(* Wait a little bit to ensure that the custom theme is added. *)
#	delay 1
#	(* Set the custom theme as the default terminal theme. *)
#	set default settings to settings set themeName
#	(* Get the IDs of all the currently opened terminal windows. *)
#	set allOpenedWindows to id of every window
#	repeat with windowID in allOpenedWindows
#		(* Close the additional windows that were opened in order
#		   to add the custom theme to the list of terminal themes. *)
#		if initialOpenedWindows does not contain windowID then
#			close (every window whose id is windowID)
#		(* Change the theme for the initial opened terminal windows
#		   to remove the need to close them in order for the custom
#		   theme to be applied. *)
#		else
#			set current settings of tabs of (every window whose id is windowID) to settings set themeName
#		end if
#	end repeat
#end tell
#EOD

# Enable â€œfocus follows mouseâ€ for Terminal.app and all X11 apps
# i.e. hover over a window and start typing in it without clicking first
#defaults write com.apple.terminal FocusFollowsMouse -bool true
#defaults write org.x.X11 wm_ffm -bool true

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Disable the annoying line marks
defaults write com.apple.Terminal ShowLineMarks -int 0

# Shell opens with: /bin/bash
defaults write com.apple.Terminal Shell -string "/bin/bash"

# Install the Solarized Dark theme for iTerm
#open "${HOME}/init/Solarized Dark.itermcolors"
open "./genmac_grey.itermcolors"

# Donâ€™t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false


###############################################################################
# Time Machine                                                                #
###############################################################################

echo "Setting Time Machine preferences"

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true


# ==============================================
# Disable CD & DVD actions
# ==============================================

echo "Setting CD & DVD preferences"

# Disable blank CD automatic action.
defaults write com.apple.digihub com.apple.digihub.blank.cd.appeared -dict action 1

# Disable music CD automatic action.
defaults write com.apple.digihub com.apple.digihub.cd.music.appeared -dict action 1

# Disable picture CD automatic action.
defaults write com.apple.digihub com.apple.digihub.cd.picture.appeared -dict action 1

# Disable blank DVD automatic action.
defaults write com.apple.digihub com.apple.digihub.blank.dvd.appeared -dict action 1

# Disable video DVD automatic action.
defaults write com.apple.digihub com.apple.digihub.dvd.video.appeared -dict action 1


###############################################################################
# TextEdit                                                                    #
###############################################################################

echo "Setting TextEdit preferences"

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4


###############################################################################
# VMware Fusion                                                               #
###############################################################################

echo "Setting VMware Fusion preferences"

# Applications menu: Show in Menu Bar
defaults write com.vmware.fusion showStartMenu3 -int 1

# Show the toolbar items
defaults write com.vmware.fusion fusionDevicesToolbarItemIsExpanded -bool true

echo "Removing Quarantine from VMware Fusion Helpers"
sudo xattr -rd com.apple.quarantine /Applications/VMware\ Fusion.app/Contents/Library/LaunchServices/


###############################################################################
# Mac App Store                                                               #
###############################################################################

echo "Setting Mac App Store preferences"

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# Allow the App Store to reboot machine on macOS updates
defaults write com.apple.commerce AutoUpdateRestartRequired -bool true


###############################################################################
# Photos                                                                      #
###############################################################################

echo "Setting Photos preferences"

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###############################################################################
# XQuartz                                                                     #
###############################################################################

echo "Setting XQuartz preferences"

# Prevent XQuartz from opening an xterm when it starts
defaults write org.macosforge.xquartz.X11 app_to_run /usr/bin/true

# Auto-quit on close last window (XQuartz)
defaults write org.macosforge.xquartz.X11 wm_auto_quit -boolean true

# Focus follows mouse (10.5.5 and up) (XQuartz)
defaults write org.macosforge.xquartz.X11 wm_ffm -boolean true


###############################################################################
# Setup ViM                                                                   #
###############################################################################

echo "Setting ViM preferences"
# Install Vundle plugin manager (https://github.com/VundleVim/Vundle.vim)
if test -f "~/.vim/bundle/Vundle.vim"; then
    git -C ~/.vim/bundle/Vundle.vim pull
else
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
#wget --quiet https://raw.githubusercontent.com/gengelke/dotfiles/master/macos/vimrc -P /tmp
mv ~/.vimrc ~/.vimrc_old
cp vim/vimrc ~/.vimrc
#rm /tmp/vimrc


###############################################################################
# Setup Bash                                                                  #
###############################################################################

echo "Setting Bash preferences"
#wget --quiet https://raw.githubusercontent.com/gengelke/dotfiles/master/macos/bashrc -P /tmp
mv ~/.bashrc ~/.bashrc_old
cp bash/bashrc ~/.bashrc
#rm /tmp/bashrc
sudo chsh -s /bin/bash


###############################################################################
# Setup Tmux                                                                  #
###############################################################################

echo "Setting Tmux preferences"
#wget --quiet https://raw.githubusercontent.com/gengelke/dotfiles/master/macos/tmux.conf -P /tmp
mv ~/.tmux.conf ~/.tmux.conf_old
cp tmux/tmux.conf ~/.tmux.conf
#rm /tmp/tmux.conf


###############################################################################
# Setup user accounts                                                         #
###############################################################################

echo "Setting up user account $useraccount"
sudo dscl . -create /Users/$useraccount
sudo dscl . -create /Users/$useraccount UserShell /bin/bash
sudo dscl . -create /Users/$useraccount RealName "$username"
sudo dscl . -create /Users/$useraccount UniqueID "$userid"
sudo dscl . -create /Users/$useraccount PrimaryGroupID $usergroupid
sudo dscl . -create /Users/$useraccount NFSHomeDirectory /Users/$useraccount
sudo dscl . -create /Users/$useraccount Picture "/Users/$useraccount/Documents/dotfiles/avatar_big.jpg"
sudo dscl . -passwd /Users/$useraccount $useraccount$userid


###############################################################################
# Final cleanup tasks                                                         #
###############################################################################

echo "Doing some final cleanup"
# Restart UI services in order to enable previously made changes
killall Dock
killall SystemUIServer
killall Finder

echo "Done. Note that some of these changes require a logout/restart to take effect."
