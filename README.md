# Bootstrap scripts for setting up my new system

\*Currently Fedora focused. Will merge or add Arch and Ubuntu-based later.

bootstrap/
├── bootstrap.sh # 🧠 Master script to orchestrate everything
├── scripts/
│ ├── dev-base.sh # 🧱 Core utilities and build tools
│ ├── dev-tools.sh # 🦀 Rust, uv, cargo & Python tooling
│ ├── shell-tools.sh # 💻 Terminal enhancements (zoxide, oh-my-posh)
│ ├── vpn.sh # 🔐 Mullvad + ProtonVPN setup
│ ├── nerd-fonts.sh # 🔤 Installs patched Nerd Fonts
│ ├── fonts.sh # 🖋 Optional system fonts
│ ├── gnome.sh # 🖥️ GNOME tweaks (extensions/tools)
│ ├── hyprland.sh # 🎯 Hyprland setup (Wayland/sway tools)
│ ├── tuxedo.sh # 🧬 Tuxedo laptop drivers/tools
│ ├── stow.sh # 🗃 Dotfile deployment via GNU Stow
│ └── final-touches.sh # 🎀 Shell, themes, cleanup
├── configs/
│ ├── .config/ # ⬅️ Dotfiles structured for Stow
│ ├── .zshrc # (if used) Shell config
│ ├── .bashrc # Bash fallback
│ └── .gitconfig # Git identity/config
├── logs/ # 📜 Optional logs from script runs
├── docs/ # 📄 Notes (e.g., gnome-extensions.md)
│ └── gnome-extensions.md
└── README.md # 📘 Project overview & usage

# 🧩 GNOME Extensions

These are the GNOME extensions I typically use. Search and enable them in the Extensions app (or GNOME Extension Manager):

## Essential

- [x] Blur My Shell
- [x] Just Perfection
- [x] Open Bar
- [x] Space Bar
- [x] Switcher
- [x] Tactile
- [x] TopHat

## Utilities

- [x] Auto Move Windows
- [x] Native Window Placement
- [x] Screenshot Window Sizer
- [x] AppIndicator/KStatusNotifier Support (for tray icons)

## Optional

- [ ] Workspace Matrix
- [ ] Compiz Magic Lamp
- [ ] Burn My Windows (chaos mode)

---

## ⚙️ Tweaks I usually make

- **Just Perfection**: Hide Activities button, reduce top bar padding
- **Blur My Shell**: Set blur strength to ~20–30
- **Switcher**: Move switcher overlay to center
