# <p><img align="left" height="60px" alt="nGPU demo gif" src="/docs/xfce4-genmon-nvidia/demo.gif" /> nGPU Temperature (Colorized) \[xfce4-genmon-nvidia\]</p>

This script retrieves the current temperature of the GPU using the NVIDIA `nvidia-smi` command and calculates an interpolated color based on the temperature range. The color is then used to represent the temperature visually in the progress bar in the panel.

The script allows for the customization of temperature thresholds and color values, enabling users to adjust the visual representation according to their preferences. The target, slowdown, shutdown, and max temperature threshold values are retrieved directly from the GPU via `nvidia-smi`.

> [!IMPORTANT]
> Version [4.2.0](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/commit/8e9f0b4341cac7b0d128c25a53872d47eab015dc) introduced `<css>` tag support with commit [b631ca03](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/commit/b631ca039e9257b745f9e388eead32689fdacd7c) which merged [PR4](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/merge_requests/4). This was crucial for the scripts below and hence you should ensure your installed version is **at least version 4.2.0**. At time of publishing, Debian is known to be out of date due to an upstream packaging hold and [should be built from source](https://salsa.debian.org/xfce-team/goodies/xfce4-genmon-plugin).

## Demo
<img width="80%" align="center" alt="GIF showing installation and use" src="/docs/xfce4-genmon-nvidia/demo_full.gif" />

## Installing
1. Clone this repo or [download the script directly](https://raw.githubusercontent.com/fritz-fritz/xfce-genmon-scripts/main/xfce4-genmon-nvidia/xfce4-genmon-nvidia.sh).
2. Make the script executable `chmod +x xfce4-genmon-nvidia`
3. Place the script in an appropriate spot such as `/usr/local/bin/`
4. Add a new generic monitor to the xfce4-panel
5. Set the monitor command to the path for the script and pass any flags you desire
6. Uncheck the label checkbox
7. Set an appropriate refresh interval

> [!TIP]
> You can call the script directly prior to adding it to the panel to verify it works.
> Try `xfce4-genmon-nvidia.sh --help` for more information

<img width="80%" align="center" alt="Terminal usage and installation GIF" src="/docs/xfce4-genmon-nvidia/demo_terminal.gif" />

## Dependencies
> [!WARNING]
> This script is intended ONLY for NVIDIA GPUs and will not work for others
- xfce4-panel
- xfce4-genmon-plugin >= 4.2.0
- nvidia-smi
- bc (Basic Calculator)

## FAQs

<details>
<summary><b>Q: The plugin isn't working like in the gif? What went wrong?</b></summary>

A: There's many reasons this could happen. Please ensure:
- Your xfce4-genmon-plugin package is at least version 4.2.0
- If you built xfce4-genmon-plugin from source did you install to an appropriate directory? Try `./configure --prefix=/usr`
- Did you make sure to chmod the script to be executable? `chmod +x /path/to/script.sh`
- Did you restart the panel after installing the new plugin? `xfce4-plugin -r`

</details>

<details>
<summary><b>Q: Can I change how it looks?</b></summary>

A: Definitely! There's a couple easy ways built-in to the script or you can manually adjust the CSS in the script to suit your liking.

#### Passing flags:
The easiest way to adjust the behavior
| flag | outcome |
| :--- | :--- |
| `-L`, `--label` | Set a custom label text<br>pass `-L ''` to have no label |
| `-LC`, `--lcolor` | Use color in the label text<br>0=off, 1=On, 2=Warn |
| `-l`, `--low` | Specify the lowest temperature used for the progressbar |
| `-n`, `--normal` | Specify what should be considered a "normal" temperature<br>this is arbitrary and used mainly for the color gradient|

#### Adjusting constants in the script directly:
There are several values that can be manually adjusted in the script directly if you prefer
| variable | outcome |
| :--- | :--- |
| GPU_NUM | Specifies the NVIDIA GPU to monitor |
| LABEL | Set the label text (overridden by flag) |
| LOWTEMP | The lowest temperature for progressbar scale |
| NORMAL | An arbitrary temperature between LOWTEMP and TARGET_TEMP |

#### Adjusting colors
Colors are set using RGB values in a bash array. Be careful changing these here as there is NOT validation that they are set correctly.

e.g. `COLD_COLOR=( 0 0 255 )` sets the cold color to be pure blue. You could change it to say `( 10 143 218 )` for a lighter blue. Pay attention to the spacing! The interpolation of colors for the gradient should continue to function without issue as long as valid rgb colors are specified ( 0 - 255 per value ).

#### Adjusting CSS
I won't go into detail on what CSS is supported as I have not thoroughly tested, but it seems to accurately reflect web standards. If you are looking to adjust this you should be comfortable modifying this script without guidance. The CSS code in the script is towards the bottom and conveniently consolidated.

</details>

<details>
<summary><b>Q: How do i know what CSS to use?</b></summary>

A: There are some useful starting points available in the gitlab repo inside the [CSS Styling.txt](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/blob/45a914d8686021755adf956ef4fd76166da4dde9/CSS%20Styling.txt) file. Beyond that, I found the [GTK Inspector](https://developer.gnome.org/documentation/tools/inspector.html) extremely helpful in attempting to copy the theme of an existing indicator.
</details>

<details>
<summary><b>Q: What's a sane refresh period to use?</b></summary>

A: That's entirely up to your preference and your systems resources. Keep an eye on your CPU load and adjust as necessary.

</details>

> [!TIP]
> You can relaunch your panel with an environment variable to get access to [GTK Inspector](https://developer.gnome.org/documentation/tools/inspector.html)
> `xfce4-panel -q`
> `GTK_DEBUG=interactive xfce4-panel -r`
> Once you are done, kill it again and relaunch without the environment variable.

