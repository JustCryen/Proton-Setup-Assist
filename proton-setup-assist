#!/bin/bash

echo -e "Third party launcher install script for Proton.\n" #Created by Cryen / github.com/JustCryen
dir=$(pwd)

### Find steam location

if [ -d $HOME/.local/steam/steamapps ] ; then
  steam_dir="$HOME/.local/steam"
  elif [ -d $HOME/.steam ] ; then
    if [ -L $HOME/.steam/steam ] ; then
      steam_dir=$(readlink -f $HOME/.steam/steam/)
      elif [ -d $HOME/.steam/steam/steamapps ] ; then
        steam_dir="$HOME/.steam/steam"
      elif [ -d $HOME/.steam/steamapps ] ; then
        steam_dir="$HOME/.steam"
      else
        echo "Couldn't find Steam dir"  >&2; exit 1
    fi
fi
echo -e "Steam location \n$steam_dir\n"

### Game selection

history -c
read -ep 'Serch for a game (protontricks): ' game_choice
if [ ! -z "$game_choice" ]; then
  protontricks -s $game_choice | head -n -4
fi

cd $steam_dir/steamapps/compatdata
read -ep 'Insert a valid APPID: ' appid

re='^[0-9]+$'
if ! [[ $appid =~ $re ]] ; then
  appid=`echo $appid | sed 's/.$//'`
  if ! [[ $appid =~ $re ]] ; then
    echo "error: Not a valid number" >&2; exit 1
  fi
fi

found_libs=`grep path $steam_dir/steamapps/libraryfolders.vdf | sed -e 's/\t\t//g' -e 's/path//' -e 's/"//g'`
echo -e "\nFound libraries \n$found_libs\n"

for steam in ${found_libs[@]}; do
  game_check=`find ${steam}/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid|name/{ printf $4 "|" } END { print "" }' {} \; | column -t -s '|' | grep -w $appid`
  game_name=`echo $game_check | sed 's/^\w*\ *//'`
  game_id=`echo $game_check | grep -o '^\S*'`
  if [[ $game_id =~ $appid ]]; then
    game=$game_name
    working_lib=${steam}
  fi
done

steamapps=$working_lib/steamapps

if [ -d $steamapps/compatdata/$appid ] ; then
  echo -e "$steamapps/compatdata/$appid\n"
  else
  echo -e "\nerror: Wrong path to game prefix" >&2; exit 1
fi

#for list_libs in ${found_libs[@]}; do                     # neat listing of found libraries
#  echo ${list_libs}
#done


### Clear prefix

#echo ""
read -p "Clear prefix? [y/N]: " clear_prefix

case "$clear_prefix" in
 [yY] | [yY][eE][sS])
    rm -r  "$steamapps/compatdata/$appid"
    echo -e "Prefix cleared \nGo and run a game at least once to create it again"; exit 0
    ;;
 [nN] | [nN][oO] | *)
    echo Ignored
    ;;
esac


### Proton selection

echo -e "\nChoose a Proton version used for configuration:"

versions_directory=$steam_dir/compatibilitytools.d
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
3. Games for Windows Live\n\
4. Custom file location"
read -ep "Pick a launcher by index: " exe_choice						#add a selection filter

if ! [[ $exe_choice =~ $re ]] ; then
   echo "error: Not a valid number" >&2; exit 1
fi


### Summmary:

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
    ;;
  4)
    echo Launcher: Custom
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
    #exe="$dir/files/OriginSetup.exe"
    exe="$dir/files/OriginThinSetup.exe"
    if [ ! -f "$exe" ]; then
      cd $dir/files
      #wget https://download.dm.origin.com/origin/live/OriginSetup.exe
      wget https://origin-a.akamaihd.net/Origin-Client-Download/origin/live/OriginThinSetup.exe
    fi
    ;;

  2)	#Ubisoft
    exe="$dir/files/UbisoftConnectInstaller.exe"
    old_launcher="$steamapps/compatdata/$appid/pfx/drive_c/Program Files (x86)/Ubisoft/Ubisoft Game Launcher/"
    if [ -d $old_launcher ] ;then
      rm -r $old_launcher
      echo "Removed old Ubisoft Game Launcher directory"
    fi
    if [ ! -f "$exe" ]; then
      cd $dir/files
      wget https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe
    fi
    ;;

  3)	#GFWL
    exe="$dir/files/gfwlivesetup.exe"
    msi1="$dir/files/xliveredist.msi"
    msi2="$dir/files/gfwlclient.msi"
    if [ ! -f "$exe" ]; then
      if [ -f "$dir/files/gfwlivesetup.zip" ]; then
      cd $dir/files
      unzip gfwlivesetup.zip
      else
      echo -e "\nPlease provide a gfwlivesetup.zip or gfwlivesetup.exe file."
      fi
    fi
    #if [ -d $old_launcher ] ;then                                                                                      #Add old launcher deletion
      #rm -r $old_launcher
    #fi
    ;;

  4)
    cd /
    read -ep "Provide a full path to the custom file: " exe
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

if [[ $exe_choice =~ 3 ]]; then
  protontricks $appid dotnet45
  echo -e "\ndotnet45 installed."
  #read -p "Press enter to continue installation. " agreement
  protontricks $appid d3dx9
  echo -e "\nd3dx9 installed."
  #read -p "Press enter to continue installation. " agreement
                                                                                                                            # ADD Physics Installer
  #STEAM_COMPAT_DATA_PATH="$steamapps/compatdata/$appid" WINEPREFIX="$steamapps/compatdata/$appid/pfx" "$proton_version/proton" run $dir/files/PhysX-9.14.0702.msi
  #echo -e "\nPhysX installed."
  read -p "Press enter to continue. " agreement
  STEAM_COMPAT_DATA_PATH="$steamapps/compatdata/$appid" WINEPREFIX="$steamapps/compatdata/$appid/pfx" "$proton_version/proton" run $msi1
  echo -e "\nxliveredist.msi installed."
  read -p "Press enter to continue. " agreement
  STEAM_COMPAT_DATA_PATH="$steamapps/compatdata/$appid" WINEPREFIX="$steamapps/compatdata/$appid/pfx" "$proton_version/proton" run $msi2
  echo -e "\ngfwlclient.msi installed."
  read -p "Press enter to continue. " agreement
fi
STEAM_COMPAT_DATA_PATH="$steamapps/compatdata/$appid" WINEPREFIX="$steamapps/compatdata/$appid/pfx" "$proton_version/proton" run $exe

if [[ $exe_choice =~ 3 ]]; then
  protontricks $appid win7
  # Fix for repeated GFWL install attempts in steam at startup
  protontricks -c 'wine cmd /C reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam\Apps\$appid" /v "Games For Windows Live Marketplace" /t REG_DWORD /d "1"' $appid
fi

echo -e "\nInstall complete!"
