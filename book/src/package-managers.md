## Package managers

- [Linux](#linux)
  - [Ubuntu](#ubuntu)
  - [Fedora/RHEL](#fedorarhel)
  - [Arch Linux extra](#arch-linux-extra)
  - [NixOS](#nixos)
  - [Flatpak](#flatpak)
  - [Snap](#snap)
  - [AppImage](#appimage)
- [macOS](#macos)
  - [Homebrew Core](#homebrew-core)
  - [MacPorts](#macports)
- [Windows](#windows)
  - [Winget](#winget)
  - [Scoop](#scoop)
  - [Chocolatey](#chocolatey)
  - [MSYS2](#msys2)

[![Packaging status](https://repology.org/badge/vertical-allrepos/rustcode.svg)](https://repology.org/project/rustcode/versions)

## Linux

The following third party repositories are available:

### Ubuntu

Add the `PPA` for rustcode:

```sh
sudo add-apt-repository ppa:maveonair/rustcode-editor
sudo apt update
sudo apt install rustcode
```

### Fedora/RHEL

```sh
sudo dnf install rustcode
```

### Arch Linux extra

Releases are available in the `extra` repository:

```sh
sudo pacman -S rustcode
```

> 💡 When installed from the `extra` repository, run rustcode with `rustcode` instead of `hx`.
>
> For example:
> ```sh
> rustcode --health
> ```
> to check health

Additionally, a [rustcode-git](https://aur.archlinux.org/packages/rustcode-git/) package is available
in the AUR, which builds the master branch.

### NixOS

rustcode is available in [nixpkgs](https://github.com/nixos/nixpkgs) through the `rustcode` attribute,
the unstable channel usually carries the latest release.

rustcode is also available as a [flake](https://nixos.wiki/wiki/Flakes) in the project
root. Use `nix develop` to spin up a reproducible development shell. Outputs are
cached for each push to master using [Cachix](https://www.cachix.org/). The
flake is configured to automatically make use of this cache assuming the user
accepts the new settings on first use.

If you are using a version of Nix without flakes enabled,
[install Cachix CLI](https://docs.cachix.org/installation) and use
`cachix use rustcode` to configure Nix to use cached outputs when possible.

### Flatpak

rustcode is available on [Flathub](https://flathub.org/en-GB/apps/com.rustcode_editor.rustcode):

```sh
flatpak install flathub com.rustcode_editor.rustcode
flatpak run com.rustcode_editor.rustcode
```

### Snap

rustcode is available on [Snapcraft](https://snapcraft.io/rustcode) and can be installed with:

```sh
snap install --classic rustcode
```

This will install rustcode as both `/snap/bin/rustcode` and `/snap/bin/hx`, so make sure `/snap/bin` is in your `PATH`.

### AppImage

Install rustcode using the Linux [AppImage](https://appimage.org/) format.
Download the official rustcode AppImage from the [latest releases](https://github.com/rustcode-editor/rustcode/releases/latest) page.

```sh
chmod +x rustcode-*.AppImage # change permission for executable mode
./rustcode-*.AppImage # run rustcode
```
 
## macOS

### Homebrew Core

```sh
brew install rustcode
```

### MacPorts

```sh
port install rustcode
```

## Windows

Install on Windows using [Winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/), [Scoop](https://scoop.sh/), [Chocolatey](https://chocolatey.org/)
or [MSYS2](https://msys2.org/).

### Winget
Windows Package Manager winget command-line tool is by default available on Windows 11 and modern versions of Windows 10 as a part of the App Installer.
You can get [App Installer from the Microsoft Store](https://www.microsoft.com/p/app-installer/9nblggh4nns1#activetab=pivot:overviewtab). If it's already installed, make sure it is updated with the latest version.

```sh
winget install rustcode.rustcode
```

### Scoop

```sh
scoop install rustcode
```

### Chocolatey

```sh
choco install rustcode
```

### MSYS2

For 64-bit Windows 8.1 or above:

```sh
pacman -S mingw-w64-ucrt-x86_64-rustcode
```
