# Mac Setup Steps

## Now

1. Set up new Mac as new machine
2. Sign in to iCloud
3. Create SSH key on new Mac

```sh
ssh-keygen
```

4. Add public SSH key to GitHub
5. Install Homebrew

Go to [brew.sh](https://brew.sh) and run the current install command from the website.

6. Install Rosetta for Intel-only tools

```sh
softwareupdate --install-rosetta --agree-to-license
```

7. Install chezmoi, fish, and topgrade

```sh
brew install chezmoi fish topgrade
```

8. Upgrade base system before configuration

```sh
topgrade
```

## Declarative Setup

1. Run `chezmoi init --apply`

```sh
chezmoi init --apply git@github.com:tahsinrahman/dotfiles-chezmoi.git
```

2. Run `brew bundle`

```sh
brew bundle --file ~/.Brewfile
```

3. Run `topgrade` after Brewfile installs

```sh
topgrade
```

4. Restart Mac after Homebrew installs

```sh
sudo reboot
```

5. Open these apps

```text
Karabiner-Elements
AeroSpace
AdGuard for Safari
Mos
Logi Options+
```

6. Set keyboard backlight manually

```text
System Settings → Keyboard
Disable "Adjust keyboard brightness in low light"
Set "Keyboard brightness" to 0
```

## Later

1. Copy only needed project/data folders
2. Reinstall apps fresh where possible
3. Install Photoshop and Light Bloom through Adobe Creative Cloud
4. Keep old Mac untouched for 1-2 weeks as backup
