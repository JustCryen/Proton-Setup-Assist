#!/bin/bash

echo -e "Third party launcher install script for Proton.\n"


### Game selection

read -p 'Choose a game you wish to instal a launcher to: ' game_choice
if [ ! -z "$game_choice" ]; then
  protontricks -s $game_choice | head -n -4
fi

read -p 'Insert a valid APPID: ' appid
echo "~/.steam/steam/steamapps/compatdata/$appid"

re='^[0-9]+$'
if ! [[ $appid =~ $re ]] ; then
  echo "error: Not a valid number" >&2; exit 1
  elif [ ! -d ~/.steam/steam/steamapps/compatdata/$appid ]; then
  echo "error: Wrong path to game prefix" >&2; exit 1
fi


### Clear prefix

echo ""
read -p "Clear prefix? [y/N]: " clear_prefix

case "$clear_prefix" in
 [yY] | [yY][eE][sS])
    rm -r  "$HOME/.steam/steam/steamapps/compatdata/$appid"
    echo -e "Prefix cleared \nGo and run a game at least once to create it again"
    exit 0
    ;;
 [nN] | [nN][oO] | *)
    ;;
esac


### Proton selection

echo -e "\nChoose a Proton version used for configuration:"

versions_directory=~/.steam/steam/compatibilitytools.d
if [ ! -d "$versions_directory" ]; then
  echo "error: No path to proton versions" >&2; exit 1
fi
versions="$versions_directory/*"
version_count=0
for proton_version in ${versions[@]}; do
  echo "$version_count. ${proton_version##*/}"
  version_count=$((version_count+1))
done

read -p 'Pick proton version by index: ' proton_choice

#re='^[0-9]+$'
if ! [[ $proton_choice =~ $re ]] ; then
  echo "error: Not a valid number" >&2; exit 1
  elif [ $proton_choice -ge $version_count ] ; then
  echo "error: Not a valid number" >&2; exit 1
fi

idx=0
for version in ${versions[@]}; do
  if (( $idx == $proton_choice )); then
    proton_version=$version
    break
  fi
  idx=$((idx+1))
done

echo "Picked version is: ${proton_version##*/}"


### Launcher selection

echo -e "\nChoose a third party launcher for installation:\n\
1. Origin\n\
2. Ubisoft Connect\n\
3. Games for Windows Live"
read -p "Pick a launcher by index: " exe_choice						#add a selection filter

if ! [[ $exe_choice =~ $re ]] ; then
   echo "error: Not a valid number" >&2; exit 1
fi


### Summmary:

game=`find ~/.steam/steam/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid|name/{ printf $4 "|" } END { print "" }' {} \; | column -t -s '|' | grep -w $appid | sed -e 's/^\w*\ *//'`
dir=$(pwd)
echo -e "\nSummary:"
echo "Game: $game"
echo "APPID: $appid"
echo "Proton: ${proton_version##*/}"
case $exe_choice in
  1)
    echo Launcher: Origin
    ;;
  2)
    echo Launcher: Ubisoft Connect
    ;;
  3)
    echo Launcher: GFWL
    echo -e "\nWARNING: the download link for Games for Windows Live is community contributed (not official)" 
    echo -e "You'd need to source it by yourself \nhttps://community.pcgamingwiki.com/files/file/1012-microsoft-games-for-windows-live/"
    echo "Place the zip in $dir/files/"
esac
echo -e "Current dir: $dir\n"

read -p "Proceed with installation? [y/N]: " final_selectiton
case "$final_selectiton" in
 [yY] | [yY][eE][sS])
    ;;
 [nN] | [nN][oO] | *)
    echo -e "\nerror: Aborted by user" >&2; exit 1
    ;;
esac


### Install script

if [ ! -d "$dir/files" ]; then
  mkdir files
fi

case "$exe_choice" in

  1)	#Origin
    exe="$dir/files/OriginSetup.exe"
    if [ ! -f "$exe" ]; then
      cd files
      wget https://download.dm.origin.com/origin/live/OriginSetup.exe
    fi
    ;;

  2)	#Ubisoft
    exe="$dir/files/UbisoftConnectInstaller.exe"
    old_launcher="$HOME/.steam/steam/steamapps/compatdata/$appid/pfx/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/"
    if [ -d $old_launcher ] ;then
      rm -r $old_launcher
      echo "Removed old Ubisoft Game Launcher directory"
    fi
    if [ ! -f "$exe" ]; then
      cd files
      wget https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe
    fi
    ;;

  3)	#GFWL
    exe="$dir/files/gfwlivesetup.exe"
    msi1="$dir/files/xliveredist.msi"
    msi2="$dir/files/gfwlclient.msi"
    #old_launcher="$HOME/.steam/steam/steamapps/compatdata/$appid/pfx/drive_c/Program Files (x86)/"
    if [ ! -f "$exe" ]; then
      if [ -f "$dir/files/gfwlivesetup.zip" ]; then
      cd files
      unzip gfwlivesetup.zip
      else
      echo -e "\nPlease provide a gfwlivesetup.zip or gfwlivesetup.exe file."
      fi
    fi
    #if [ -d $old_launcher ] ;then
      #rm -r $old_launcher
      #echo "Removed old Ubisoft Game Launcher directory"
    #fi
    ;;

  *)
    echo "error: Not a valid number" >&2; exit 1
    ;;
esac

if [ -f "$exe" ]; then
  echo "File found: $exe"
  echo -e "\nInstalling"
  else 
  echo "error: couldn't find the installer" >&2; exit 1
fi

compatdata="$HOME/.steam/steam/steamapps/compatdata"

if [[ $exe_choice =~ 3 ]]; then
  protontricks $appid dotnet45
  echo -e "\ndotnet45 installed."
  #read -p "Press enter to continue installation. " agreement
  protontricks $appid d3dx9
  echo -e "\nd3dx9 installed."
  #read -p "Press enter to continue installation. " agreement
  STEAM_COMPAT_DATA_PATH="$compatdata/$appid" WINEPREFIX="$compatdata/$appid/pfx" "$proton_version/proton" run $msi1
  echo -e "\nxliveredist.msi installed."
  #read -p "Press enter to continue installation. " agreement
  STEAM_COMPAT_DATA_PATH="$compatdata/$appid" WINEPREFIX="$compatdata/$appid/pfx" "$proton_version/proton" run $msi2
  echo -e "\ngfwlclient.msi installed."
                                                                                                                          # ADD Physics Installer
  protontricks $appid win7
fi
STEAM_COMPAT_DATA_PATH="$compatdata/$appid" WINEPREFIX="$compatdata/$appid/pfx" "$proton_version/proton" run $exe

echo -e "\nInstall complete!"