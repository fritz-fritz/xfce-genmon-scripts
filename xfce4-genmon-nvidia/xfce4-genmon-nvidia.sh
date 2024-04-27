#!/bin/bash
#
# nGPU Temperature (Colorized)
#
# This script is a plug-in for `xfce4-genmon-plugin`. It retrieves the
# current temperature of the GPU using the NVIDIA `nvidia-smi` command
# and calculates an interpolated color based on the temperature range.
# The color is then used to represent the temperature visually in a
# progress bar.
#
# The script allows for customization of temperature thresholds and color 
# values, enabling users to adjust the visual representation according to 
# their preferences. The target, slowdown, shutdown, and max temperature
# threshold values are retrieved directly from the GPU via `nvidia-smi`.
#
# Author: Roland Fritz
# Version: 1.0
# License: LGPL-3.0
# URL: https://www.github.com/fritz-fritz/
#
# Copyright (c) 2024, Roland Fritz <code@fritztech.net>
# This script is licensed under the terms of the GNU Lesser General Public License v3.0
# For more details, see: https://www.gnu.org/licenses/lgpl-3.0.html
#
# Usage:
# - Ensure xfce4-genmon-plugin version is at least 4.2.0
# - Ensure `nvidia-smi` is installed and available on your system.
# - Install the script at the path of your choosing (eg /usr/local/bin/)
# - Customize the configurable values according to your requirements.
# - Make script executable `chmod +x /path/to/script.sh`
# - Add a new Generic Monitor and set the Command to the script path
#
# Dependencies:
# - xfce4-panel
# - xfce4-genmon-plugin >= 4.2.0
# - nvidia-smi
# - bc (Basic Calculator)
#
# Configuration:
# - LOWTEMP: Lowest temperature for the bar.
# - NORMAL: Temperature threshold for the transition from cold to normal color.
# - COLD_COLOR: RGB values for cold temperature.
# - NORMAL_COLOR: RGB values for normal temperature.
# - WARM_COLOR: RGB values for warm temperature.
# - HOT_COLOR: RGB values for hot temperature.
# - OVERHEAT_COLOR: RGB values for overheated temperature.
#
# Note: This script is intended for use with NVIDIA GPUs and is not 
# compatible with other hardware configurations.
#
# Note: At time of publishing, Debian repositories do not include an
# up to date version of `xfce4-genmon-plugin`. For progressbar formatting
# (such as color and style) to work, the package must be built from source.
#
# Disclaimer: Use this script at your own risk. The author is not responsible 
# for any damage or malfunction caused by its use. It is provided on an 'AS IS'
# basis without offer of warranty or support, express or implied.
#
# NVIDIA is a registered trademark of NVIDIA Corporation in the U.S. and other
# countries. This script is not affiliated with or endorsed by NVIDIA Corporation.
#

##############
# Configurable Values
#
# GPU Number (obtained from `nvidia-smi -L` and overriden by flag)
GPU_NUM=0
# Label text (overriden by flag)
LABEL=""
# a sane value for the bottom of the scale
LOWTEMP=40
# a sane value for what is a normal temp between LOW and TARGET
NORMAL=60
#
# COLOR VALUES in RGB bash arrays
COLD_COLOR=( 0 0 255 )
NORMAL_COLOR=( 0 255 0 )
WARM_COLOR=( 255 255 0 )
HOT_COLOR=( 255 0 0 )
OVERHEAT_COLOR=( 255 0 255 )
#
##############

# Extract version from the comment block
version=$(grep -oP '(?<=Version: )\d+\.\d+' "$0" | head -n1)

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -g | --gpu)
            # Validate GPU number
            if ! [[ $2 =~ ^[0-9]+$ ]]; then
                echo "Invalid GPU number: '$2'. Must be a positive integer."
                exit 1
            fi
            GPU_NUM=$2
            shift
            shift
            ;;
        -L | --label)
            # Validate Label input
            if [[ $# -gt 1 ]]; then
                if [[ "$2" == -* ]]; then
                    echo "Error: Unable to parse label."
                    exit 1
                elif [[ "$2" != "" ]]; then
                    label_override=0
                else
                    label_override=1
                fi
                LABEL="$2"
            else
                echo "Error: Unable to parse label"
                exit 1
            fi
            shift
            shift
            ;;
        -l | --low)
            # Validate Low Temperature
            if ! [[ $2 =~ ^[0-9]+$ ]]; then
                echo "Invalid Temperature: '$2'. Must be a positive integer."
                exit 1
            fi
            LOWTEMP=$2
            shift
            shift
            ;;
        -n | --normal)
            # Validate Normal Temperature
            if ! [[ $2 =~ ^[0-9]+$ ]]; then
                echo "Invalid Temperature: '$2'. Must be a positive integer."
                exit 1
            fi
            NORMAL=$2
            shift
            shift
            ;;
        --lcolor | -LC)
            # Enable color for the label, 0=Off, 1=On, 2=Warn
            if ! [[ $2 =~ ^[0-2]$ ]]; then
                echo "Invalid Option: '$2'. 0=Off, 1=On, 2=Warn."
                exit 1
            fi
            LABELCOLOR=$2
            shift
            shift
            ;;
        --demo)
            # Demo mode randomly generates a current temperature, it takes no argument
            DEMO=1
            shift
            ;;
        --help)
            echo "nGPU Temperature (Colorized)"
            echo -e "Version: $version LGPL-3.0"
            echo "Retrieve temperature from NVIDIA GPU and format for xfce4-genmon-plugin"
            echo
            echo "Usage: $(basename $0) [OPTION <value>] [--demo]"
            echo
            echo -e "\t-g,  --gpu\tGPU Number from 'nvidia-smi -L' (integer)"
            echo -e "\t-L,  --label\tLabel text value. (Default = 'GPU')"
            echo -e "\t-LC, --lcolor\tEnable color in label text. "
            echo -e "\t             \t   (0=Off, 1=On, 2=Warn \\ Default = 0)"
            echo -e "\t-l,  --low\tLow temperature threshold. (Default = $LOWTEMP)"
            echo -e "\t-n,  --normal\tNormal temperature threshold. (Default = $NORMAL)"
            echo
            echo -e "\t     --demo\tSets a random temperature every run. (Takes no argument)"
            echo
            echo -e "\t-v,  --version\tVersion information"
            echo -e "\t     --help\tDisplay this help"
            echo
            echo "Example:"
            echo -e "   $(basename $0) -L \"GPU TEMP\" -g 1          Sets the plugin label and gathers data from the second GPU"
            echo -e "   $(basename $0) -L ''                       Override default value to hide label."
            echo -e "   $(basename $0)                             Runs the script with default values"
            exit 0
            ;;
        -h)
            echo "Usage: $(basename $0) [OPTION <value>] [--demo]"
            echo "Try '$(basename $0) --help' for more information."
            exit 0
            ;;
        --version)
            echo "nGPU Temperature (Colorized)"
            echo -e "Version: $version LGPL-3.0"
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            echo "Try '$(basename $0) --help' for more information."
            exit 1
            ;;
    esac
done

# locate nvidia-smi
nvidiasmi="$(which nvidia-smi)"
if [[ "$?" -ne 0 ]]; then
    echo "nvidia-smi not found."
    exit 1
fi

# query and cache nvidia-smi
smi=$($nvidiasmi -q -d TEMPERATURE -i "$GPU_NUM")

TARGET_TEMP=$(echo "$smi" | grep "GPU Target" | sed 's/.*: \([0-9]\+\) C.*/\1/g')
SLOWDOWN_TEMP=$(echo "$smi" | grep "GPU Slowdown" | sed 's/.*: \([0-9]\+\) C.*/\1/g')
SHUTDOWN_TEMP=$(echo "$smi" | grep "GPU Shutdown" | sed 's/.*: \([0-9]\+\) C.*/\1/g')
MAX_TEMP=$(echo "$smi" | grep "GPU Max" | sed 's/.*: \([0-9]\+\) C.*/\1/g')

if [[ "$DEMO" -eq 1 ]]; then
    temp=$((LOWTEMP + RANDOM % (MAX_TEMP - LOWTEMP)))
else
    temp=$(echo "$smi" | grep "GPU Current" | sed "s/.*: \([0-9]\+\) C.*/\1/g")
fi
temp_pct=$( bc -l <<< "100 * ($temp - $LOWTEMP)/($MAX_TEMP - $LOWTEMP)" | xargs printf "%.2f" )
temp_pct_int=$( bc -l <<< "($temp_pct + 0.5)/1" | xargs printf "%.0f" )

# Calculate the color
if [ "$temp" -ge "$SLOWDOWN_TEMP" ]; then
    # color=(${HOT_COLOR[@]})
    for i in 0 1 2
    do
        color[i]=$(bc -l <<< "scale=1; ${HOT_COLOR[i]} + ((($temp - $SLOWDOWN_TEMP) / ($SHUTDOWN_TEMP - $SLOWDOWN_TEMP)) * (${OVERHEAT_COLOR[i]} - ${HOT_COLOR[i]}))" | xargs printf "%.0f")
    done
elif [ "$temp" -ge "$TARGET_TEMP" ]; then
    # color=(${WARM_COLOR[@]})
    for i in 0 1 2
    do
        color[i]=$(bc -l <<< "scale=1; ${WARM_COLOR[i]} + ((($temp - $TARGET_TEMP) / ($SLOWDOWN_TEMP - $TARGET_TEMP)) * (${HOT_COLOR[i]} - ${WARM_COLOR[i]}))" | xargs printf "%.0f")
    done
elif [ "$temp" -ge $NORMAL ]; then
    # color=(${NORMAL_COLOR[@]})
    for i in 0 1 2
    do
        color[i]=$(bc -l <<< "scale=1; ${NORMAL_COLOR[i]} + ((($temp - $NORMAL) / ($TARGET_TEMP - $NORMAL)) * (${WARM_COLOR[i]} - ${NORMAL_COLOR[i]}))" | xargs printf "%.0f")
    done
else
    # color=(${COLD_COLOR[@]})
    for i in 0 1 2
    do
        color[i]=$(bc -l <<< "scale=1; ${COLD_COLOR[i]} + ((($temp - $LOWTEMP) / ($NORMAL - $LOWTEMP)) * (${NORMAL_COLOR[i]} - ${COLD_COLOR[i]}))" | xargs printf "%.0f")
    done
fi

# Output the data for xfce4-genmon-plugin
echo "<css>"
if [[ "$LABELCOLOR" -eq 2 && "$temp" -ge "$TARGET_TEMP" ]]; then
    echo ".genmon_valuebutton { color: rgb(${color[0]},${color[1]},${color[2]}) }"
elif [ "$LABELCOLOR" -eq 1 ]; then
    echo ".genmon_valuebutton { color: rgb(${color[0]},${color[1]},${color[2]}) }"
fi
echo "progressbar.genmon_progressbar { padding-left: 4px; padding-right: 4px }"
echo "progressbar.genmon_progressbar trough { background-color: rgb(39,42,52); box-shadow: 0 0 0 1px rgba(39,119,255,0) inset; color: rgb(255,255,255); outline-color: rgba(255,255,255,0.07); padding-bottom: 2px; padding-left: 3px; padding-right: 3px; padding-top: 2px; text-decoration-color: rgb(255,255,255); }"
echo "progressbar.genmon_progressbar trough progress { background-color: rgb(${color[0]},${color[1]},${color[2]}); border-top-style: none; border-bottom-style: none; border-left-style: none; border-right-style: none; margin-bottom: 0; margin-top: 0; min-width: 4px; }"
echo "</css>"
if [ -n "$LABEL" ]; then
    echo "<txt>$LABEL</txt><txtclick>nvidia-settings</txtclick>"
elif [[ $label_override -eq 0 ]]; then
    echo "<txt>GPU</txt><txtclick>nvidia-settings</txtclick>"
fi
echo "<bar>$temp_pct</bar>"
echo "<tool><b>NVIDIA GPU</b>
Temp:  $temp °C</tool>"
