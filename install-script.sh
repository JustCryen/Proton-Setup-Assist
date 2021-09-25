#!/bin/bash

echo -e "Third party launcher install script for Proton.\n"


### Game selection

read -p 'Choose a game you wish to instal a launcher to: ' game_choice

protontricks -s $game_choice | head -n -4

read -p 'Insert a valid APPID: ' appid
echo "~/.steam/steam/steamapps/compatdata/$appid"

re='^[0-9]+$'
if ! [[ $appid =~ $re ]] ; then
   echo "error: Not a valid number" >&2; exit 1
elif [ ! -d ~/.steam/steam/steamapps/compatdata/$appid ]; then
  echo "error: Wrong path to game prefix" >&2; exit 1
fi


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


### Summmary:

game=`find ~/.steam/steam/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid|name/{ printf $4 "|" } END { print "" }' {} \; | column -t -s '|' | grep -w $appid | sed -e 's/^\w*\ *//'`
dir=$(pwd)
echo -e "\nSummary:"
echo "Game: $game"
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
esac
echo "Current dir: $dir"

read -p "Proceed installation? y/N: " final_selectiton
case "$final_selectiton" in
 [yY] | [yY][eE][sS])
    echo "Installing"
    ;;
 [nN] | [nN][oO] | *)
    echo "error: Aborted by user" >&2; exit 1
    ;;
esac


### Install script

if [ ! -d "$dir/files" ]; then
  mkdir files
fi

case "$exe_choice" in

  1)	#Origin
    if [ ! -f "$dir/files/OriginSetup.exe" ]; then			#keeps downloading over and over again
      cd files
      wget https://download.dm.origin.com/origin/live/OriginSetup.exe
      exe="$dir/files/OriginSetup.exe"
    else
      exe="$dir/files/OriginSetup.exe"
    fi
    ;;

  2)	#Ubisoft
    if [ ! -f "$dir/files/UbisoftConnectInstaller.exe" ]; then
      cd files
      wget https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe
      exe="$dir/files/UbisoftConnectInstaller.exe"
    else
      exe="$dir/files/UbisoftConnectInstaller.exe"
    fi
    ;;

  3)	#GFWL
    exe="~/Executables/gfwlivesetup.exe"
    ;;

  *)
    echo "error: Not a valid number" >&2; exit 1
    ;;
esac

echo "File found: $exe"

#STEAM_COMPAT_DATA_PATH="~/.steam/steam/steamapps/compatdata/$appid" WINEPREFIX="~/.steam/steam/steamapps/compatdata/$appid/pfx" "$proton_version/proton" run $exe
