# Bootstrap scripts for setting up my new system

bootstrap/
├── bootstrap.sh # Master script
├── scripts/
│ ├── base.sh # Shared essentials (e.g., curl, git, fonts)
│ ├── gnome.sh # Gnome tweaks, extensions, keybinds
│ ├── hyprland.sh # Hyprland-specific setup
│ ├── fedora.sh # Fedora-specific package installs
│ ├── arch.sh # Arch-specific installs
│ ├── tuxedo.sh # Tuxedo drivers/tools
│ ├── stow.sh # Dotfiles deployment
│ └── final-touches.sh # Fonts, themes, shell stuff
├── configs/
│ ├── .config/ # Dotfile stow packages
│ ├── .bashrc # Shell config
│ └── .gitconfig # etc.
├── README.md
└── logs/
