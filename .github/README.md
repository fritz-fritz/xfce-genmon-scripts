# <p><img align="left" height="60px" alt="xfce4-genmon-plugin logo" src="https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/raw/45a914d8686021755adf956ef4fd76166da4dde9/data/icons/scalable/org.xfce.genmon.svg" /> xfce-genmon-scripts</p>


![GitHub License](https://img.shields.io/github/license/fritz-fritz/xfce-genmon-scripts?style=for-the-badge&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIwLjg4ZW0iIGhlaWdodD0iMWVtIiB2aWV3Qm94PSIwIDAgMTQgMTYiPjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgZD0iTTcgNGMtLjgzIDAtMS41LS42Ny0xLjUtMS41UzYuMTcgMSA3IDFzMS41LjY3IDEuNSAxLjVTNy44MyA0IDcgNHptNyA2YzAgMS4xMS0uODkgMi0yIDJoLTFjLTEuMTEgMC0yLS44OS0yLTJsMi00aC0xYy0uNTUgMC0xLS40NS0xLTFIOHY4Yy40MiAwIDEgLjQ1IDEgMWgxYy40MiAwIDEgLjQ1IDEgMUgzYzAtLjU1LjU4LTEgMS0xaDFjMC0uNTUuNTgtMSAxLTFoLjAzTDYgNUg1YzAgLjU1LS40NSAxLTEgMUgzbDIgNGMwIDEuMTEtLjg5IDItMiAySDJjLTEuMTEgMC0yLS44OS0yLTJsMi00SDFWNWgzYzAtLjU1LjQ1LTEgMS0xaDRjLjU1IDAgMSAuNDUgMSAxaDN2MWgtMWwyIDR6TTIuNSA3TDEgMTBoM0wyLjUgN3pNMTMgMTBsLTEuNS0zbC0xLjUgM2gzeiIgZmlsbD0id2hpdGUiLz48L3N2Zz4%3D&logoSize=auto) <img alt="Discord" src="https://img.shields.io/discord/1148436645973074060?style=for-the-badge&logo=discord&logoSize=auto&label=Community&link=https%3A%2F%2Fdiscord.gg%2FFWJS8RZrt8">

## xfce4 generic monitor plugin

The xfce4-genmon-plugin (GenMon) provides a plugin for xfce4-panel that cyclically spawns a script or program, captures its output and displays the result into the panel.

> [!IMPORTANT]
> Version [4.2.0](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/commit/8e9f0b4341cac7b0d128c25a53872d47eab015dc) introduced `<css>` tag support with commit [b631ca03](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/commit/b631ca039e9257b745f9e388eead32689fdacd7c) which merged [PR4](https://gitlab.xfce.org/panel-plugins/xfce4-genmon-plugin/-/merge_requests/4). This was crucial for the scripts below and hence you should ensure your installed version is **at least version 4.2.0**. At time of publishing, Debian is known to be out of date due to an upstream packaging hold and [should be built from source](https://salsa.debian.org/xfce-team/goodies/xfce4-genmon-plugin).

## Scripts

### <img align="left" height="40px" alt="nGPU demo gif" src="/docs/xfce4-genmon-nvidia/demo.gif" /><p>nGPU Temperature (Colorized) \[xfce4-genmon-nvidia\]</p>
<br>

This script retrieves the current temperature of the GPU using the NVIDIA `nvidia-smi` command and calculates an interpolated color based on the temperature range. The color is then used to represent the temperature visually in the progress bar in the panel.

The script allows for the customization of temperature thresholds and color values, enabling users to adjust the visual representation according to their preferences. The target, slowdown, shutdown, and max temperature threshold values are retrieved directly from the GPU via `nvidia-smi`.

See the [README](/xfce4-genmon-nvidia/README.md) for more information.

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
