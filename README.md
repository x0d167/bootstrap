# Bootstrap scripts for setting up my new system

Currently Fedora focused. Will merge or add Arch and Ubuntu-based later. Tree represents
future state. Might not have all scripts yet.

```bash
bootstrap/
├── bootstrap.sh                # 🧠 Master script to orchestrate everything
├── scripts/
│   ├── system-prep.sh          # 🧼 RPM Fusion, DNF tweaks, update & cleanup
│   ├── dev-base.sh             # 🧱 Core utilities and build tools
│   ├── dev-tools.sh            # 🦀 Rust, uv, cargo & Python tooling
│   ├── shell-tools.sh          # 💻 Terminal enhancements (zoxide, oh-my-posh)
│   ├── vpn.sh                  # 🔐 Mullvad + ProtonVPN setup
│   ├── fonts.sh                # 🔤 UI + Nerd + Terminus font installer
│   ├── kitty.sh                # 🐱 Custom Regular Kitty installer
│   ├── zen.sh                  # 🧘 Zen browser installer + profile backup/version check
│   ├── tuxedo.sh               # 🧬 Tuxedo laptop drivers/tools (Fedora-friendly)
│   ├── dotfiles.sh             # 🗃 Clones dotfiles repo, backs up existing, runs Stow
│   ├── final-touches.sh        # 🎀 Optional polish (themes, cleanup)
│   ├── 1password.sh            # 🔐 Manage passwords with desktop and CLI implementation
│   ├── security.sh             # 🛡️ UFW, sysctl, fail2ban, Portmaster & hardening
│   └── log-summary.sh          # 📋 Summarize logs and show audit results (optional)
├── logs/                       # 📜 Optional logs from script runs
├── docs/                       # 📄 Notes (e.g., gnome-extensions.md)
│   └── gnome-extensions.md
└── log-summary.sh              # 📋 Summarize logs and show audit results (optional)
└── README.md                   # 📘 Project overview & usage
```

## 🦀 Rust CLI Tools

To speed up CLI tool installation (like `eza`, `hx`, `rioterm`, etc.), we use [`cargo-binstall`](https://github.com/cargo-bins/cargo-binstall) when available to download prebuilt binaries instead of compiling from source.

This happens automatically inside `cargo-tools.sh`. If you’re low on resources or running on a VM, this will save a _lot_ of time.

## 🛠️ Dotfiles Setup

This script will:

- Clone your dotfiles repo into `~/.dotfiles`
- Back up any overlapping files
- Run `stow` to symlink everything cleanly

```bash
./scripts/dotfiles.sh
```
