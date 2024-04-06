# debian-rice
Debian 12.5.0 64-bit @ 2024.03.06

<details open><summary><b>Вдохновлено</b></summary>

- [Reddit - Shaggy96Fi](https://www.reddit.com/r/unixporn/comments/lydglv/kdeplasma_easy_on_the_eyes_gruvbox_theme/)
- [Reddit - linuxscoop](https://www.reddit.com/r/unixporn/comments/wih7jm/kde_plasma_new_desktop_layout_for_my_daily_driver/)
- [Reddit - 8KCoffeeWizard](https://www.reddit.com/r/unixporn/comments/y72zlv/kde_kde_rice_without_blur_real/)
</details>

<p align="center">
  <img src="https://github.com/Kseen715/imgs/blob/main/sakura_kharune.png" title="Logo" alt="Logo" width="150" height="150"/>
</p>

**Конфигурация**:
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
</details>

<details><summary><b>Настройка пользователя</b></summary>

  Переходим в root:
  ``` bash
  su
  ```
  
  Устанавливаем sudo:
  ``` bash
  sudo apt install sudo
  ```
  
  Создаем нового пользователя (если уже не создан):
  ``` bash
  sudo adduser <username>
  ```
  
  Выдаем sudo для пользователя:
  ``` bash
  sudo usermod -aG sudo <username>
  ```
  
  Меняем пользователя на созданного:
  ``` bash
  su <username>
  ```
</details>

Обновляем все:
``` bash
sudo apt update && sudo apt upgrade
```

Устанавливаем необходимый софт:
<details><summary>список</summary>
  
- `micro`
- `curl`
- `htop`
- `btop`
</details>

``` bash
sudo apt install micro curl htop btop -y
```


Устанавливаем `zsh` и перезапускаем сессию:
``` bash
sudo ap install zsh -y && which zsh && chsh -s $(which zsh) && sudo reboot now
```

Устанавливаем `Oh My Zsh`
``` zsh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

Если не удается подключиться к GitHub, добавляем прокси:
```
# /etc/hosts
...
199.232.28.133 raw.githubusercontent.com
...
```

Плагины `OMZ`:
``` zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && curl -sS https://starship.rs/install.sh | sudo sh
```

``` zsh
exec zsh
```

Устанавливаем часовой пояс:
``` zsh
timedatectl set-timezone Europe/Moscow
```

<details><summary><b>Установка шрифтов</b></summary>
  
``` zsh
sudo mv *.ttf /usr/share/fonts/truetype
```
</details>

Настраиваем плазму:
- [Global Theme](https://store.kde.org/p/1327723)
- [Login Screen](https://store.kde.org/p/1312658)
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

Чистка раздражающих приложений:
``` zsh
sudo apt remove kmail kate konqueror -y
```
