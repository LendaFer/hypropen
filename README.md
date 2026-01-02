# Hypropen

## Description

Hypropen is a tool to automatically open preconfigured workspace and monitor layouts in hyprland. <br>
The example implementation in the *./workspaces/* folder is written for use within **Omarchy**.

## How it works

The tool is a single bash script (*hypropen.sh*) that takes one flag. This flag is the path to the .toml file of the configured environment. <br>
These .toml files are formatted like this:

```TOML
removePreviousWindows=false #a single flag determining wether 
                            #previously opened windows should be closed 
                            #or moved to another workspace

[Workspaces]
#here goes which workspaces should be on which monitor
#hyprland's monitor indexing is used
#the syntax is monitor<id>=<workspace id's separated by spaces>
monitor0=1 3
monitor1=2 4

[Workspace 1]
#here goes the bash command that is run via "hyprctl dispatch exec <cmd>" to open a window
alacritty

[Workspace 2]
#same as for Workspace 1
omarchy-launch-browser

#more workspaces, like the two above
```

Everything else is taken care of by the script.

To run this file from the console use:
```bash
./hypropen.sh workspaces/work.toml
```
from within this directory. 
To bind it to a key-combination, add
```bash
bindd = SUPER SHIFT, W, devEnv, exec, <path>/hypropen.sh <path>/workspaces/work.toml
```
to your hyprland config. Naturally, the <path> needs to be set to the path to this directory. Alternatively, the shell scirpt can be added to the PATH variable and then only the path to the .toml file needs to be set in the hyprland config.


## Further Development

In future, there should be possibilies to add more concrete layouts of the workspaces, like window sizes, vertical/horizontal split etc.  
