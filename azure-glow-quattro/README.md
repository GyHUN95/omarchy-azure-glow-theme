# Azure Glow Quattro Theme

Azure glow palette (cyan → deep blue) with **top-to-bottom gradient borders** on
windows, the password field, and shell surfaces.

- **Theme** (`azure-glow-quattro`) — colors, background, and gradient borders.
  The active-window border (and every shell surface that inherits it: OSD,
  notifications, popups) is an azure `rgb(00ccff) → rgb(0011bb)` **top-to-bottom**
  `90deg` gradient.
- **Lock plugin** (`quattro-lock/`) — a Quickshell session lock with a **matte
  black background** and an **azure top-to-bottom gradient password field**.

## Install (fresh machine / opencode)

The package is self-contained. Unzip it anywhere, then run the installer:

```bash
unzip azure-glow-quattro-v2.0.zip -d ~/.config/omarchy/themes/
bash ~/.config/omarchy/themes/azure-glow-quattro/install.sh
```

`install.sh` (which opencode runs once) does everything:

1. Copies `quattro-lock/` → `~/.config/omarchy/plugins/quattro.lock`
2. Disables any other active lock service and enables `quattro.lock`
3. Applies the `azure-glow-quattro` theme
4. Syncs the Plymouth boot + SDDM login screens to the blue palette
   (`sudo omarchy plymouth set-by-theme azure-glow-quattro`) — reboot for the
   blue boot logo to appear

### Manual setup

```bash
omarchy theme set "azure-glow-quattro"
omarchy plugin enable quattro.lock   # after installing the plugin folder
sudo omarchy plymouth set-by-theme azure-glow-quattro   # blue boot logo
```

## What the final look is

| Surface         | Appearance                                        |
|-----------------|---------------------------------------------------|
| Window border   | azure `00ccff → 0011bb` gradient, top-to-bottom   |
| OSD / popups    | same azure top-to-bottom gradient (from the theme)|
| Lock background | matte black                                       |
| Lock field      | azure top-to-bottom gradient border               |
| Boot / login    | blue omarchy logo to match the background image   |

## Lock Screen Colors

| Role        | Hex       | Used for                        |
|-------------|-----------|---------------------------------|
| background  | `#000000` | Matte black lock screen         |
| text        | `#a8dfff` | Field text                      |
| placeholder | `#7298b1` | Password bullets                |
| text-error  | `#0099cc` | Wrong-password state            |
| selection   | `#00aaff` | Text selection                  |
| border      | gradient  | Azure `00ccff → 0011bb` (90deg) |

> Plugins run as unsandboxed code inside the long-lived omarchy-shell process.
> Review `quattro-lock/` before installing, and only install this package from a
> source you trust.
