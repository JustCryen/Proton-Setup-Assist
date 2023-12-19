# Proton Setup Assist
 Shell script made to simplify the installation process of Steam games that require third party launchers.
 
 This is a work in progress project.
 This shellscript should automatically find your Steam installation folder and adjust the commands according to your steam library location / locations.
 
### Features
- Origin installation
- Ubisoft Connect installation
- Games for Windows Live installation (requires a manual download)
- Custom install option for anything you might want to install to an existing proton prefix.
- Game ID prompt [ can be selected manually by using the `-i <GameID>` flag ]
- Automatic Proton detection [ can be selected manually by using the `-p <proton versiion>` flag ]
- Installer selection prompt [ can be selected manually by using the `-s <1-5>` flag ]
- Now a runner can be selected, either proton or wine (prompt)

### Dependencies

- sed and awk (for now)
- protontricks

### Todo

- Save last used configuration
- Load last used configuration

