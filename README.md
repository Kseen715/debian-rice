# debian-rice
Debian 12.5.0 64-bit @ 2024.03.06

<details open><summary><b>Inspired by:</b></summary>

  - [Reddit - Shaggy96Fi](https://www.reddit.com/r/unixporn/comments/lydglv/kdeplasma_easy_on_the_eyes_gruvbox_theme/)
  - [Reddit - 8KCoffeeWizard](https://www.reddit.com/r/unixporn/comments/y72zlv/kde_kde_rice_without_blur_real/)
</details>

<p align="center">
  <img src="https://github.com/Kseen715/imgs/blob/main/sakura_kharune.png" title="Logo" alt="Logo" width="150" height="150"/>
</p>

**Config:**
- OS: Debian 12
- DE: KDE/Plasma
- WM: KWin
- Terminal: Konsole
- Shell: ZSH with [Starship](https://starship.rs/)
- Fonts:
  - Regular: [Iosevka](https://typeof.net/Iosevka/) / [Fira Code Nerd](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/FiraCode.zip)
  - Mono: [Fira Code Nerd](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.0/FiraCode.zip)
- ColorScheme: Gruvbox-Dark-B-LB
- Icons: Gruvbox
- Dotfiles: here
- Wallpapers: [here](https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/main/images/gruvbox_forest-4.png)

<img src=https://i.imgur.com/vaEOImP.jpeg>
<details><summary>More screenshots</summary>
  <img src=https://i.imgur.com/z89N0A5.jpeg>
  <img src=https://i.imgur.com/xdnn8W3.png>
</details>

<details><summary><b>User setup:</b></summary>

  Switch to root:
  ``` bash
  su
  ```
  
  Install `sudo`:
  ``` bash
  sudo apt install sudo
  ```
  
  Create new user (if not already):
  ``` bash
  sudo adduser <username>
  ```
  
  Allow sudo for new user:
  ``` bash
  sudo usermod -aG sudo <username>
  ```
  
  Switch to freshly sudoed user:
  ``` bash
  su <username>
  ```
</details>

Update all thingies:
``` bash
sudo apt update && sudo apt upgrade
```

Install neccessary (for me) soft:
<details><summary>list</summary>
  
  - `micro`
  - `curl`
  - `htop`
  - `btop`
  - `latte-dock`
  - `snapd`
  - `wireguard`
</details>

``` bash
sudo apt install micro curl htop btop latte-dock snapd wireguard -y
```


Install `zsh` & reboot session:
``` bash
sudo ap install zsh -y && which zsh && chsh -s $(which zsh) && sudo reboot now
```

Install `Oh My Zsh`:
``` zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```
<details><summary>If errors with GitHub appears</summary>

    Add this to `/etc/hosts`:
    ```
    199.232.28.133 raw.githubusercontent.com
    ```
</details>

Plugins for `Oh My Zsh`:
``` zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && curl -sS https://starship.rs/install.sh | sudo sh
```

Remember to restart zsh after reconfig:
``` zsh
exec zsh
```

Configure timezone:
``` zsh
timedatectl set-timezone Europe/Moscow
```

<details><summary><b>Install fonts</b></summary>
    
  ``` zsh
  sudo mv *.ttf /usr/share/fonts/truetype
  ```
</details>

Setting up KDE:
- [Global Theme](https://store.kde.org/p/1327723)
- [Login Screen](https://store.kde.org/p/1214121) (with global theme colors)
- [Screen Locking Wallpapers](https://store.kde.org/p/1069729)
- [Konsole Theme](https://store.kde.org/p/1327725)

<details><summary><b>VSCode</b></summary>
  
  ``` zsh
  sudo apt-get install wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  sudo apt update && sudo apt install code
  ```
</details>

<details open><summary><b>VSCode Insiders</b></summary>
  
  ``` zsh
  sudo apt-get install wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  sudo apt update && sudo apt install code-insiders
  ```
</details>

<details><summary><b>VSCodium</b></summary>
  
  ``` zsh
  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
      | gpg --dearmor \
      | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg \
  && echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
      | sudo tee /etc/apt/sources.list.d/vscodium.list \
  && sudo apt update && sudo apt install codium
  ```
</details>

<details open><summary><b>Telegram Desktop</b></summary>

  ``` zsh
  wget https://telegram.org/dl/desktop/linux -O tg.tar.xz \
  && tar -xf tg.tar.xz \
  && rm tg.tar.xz \
  && mv ./Telegram/Telegram ./Telegram/telegram \
  && mv ./Telegram/Updater ./Telegram/telegram-updater \
  && sudo mv ./Telegram/telegram /usr/bin/ \
  && sudo mv ./Telegram/telegram-updater /usr/bin/ \
  && rm -rf ./Telegram
  ```
</details>

<details open><summary><b>Shadowsocks</b></summary>
  
  ``` zsh
  wget https://github.com/shadowsocks/shadowsocks-qt5/releases/download/v3.0.1/Shadowsocks-Qt5-3.0.1-x86_64.AppImage -O shadowsocks \
  && chmod a+x shadowsocks \
  && sudo mv shadowsocks /usr/bin/
  ```
</details>

Delete some bloatware:
``` zsh
sudo apt remove kmail kate konqueror -y
```
