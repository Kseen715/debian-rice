# debian-rice
Debian 12.5.0 64-bit @ 2024.03.06

https://www.reddit.com/r/unixporn/comments/lydglv/kdeplasma_easy_on_the_eyes_gruvbox_theme/
https://www.reddit.com/r/unixporn/comments/kt1qlg/plasma_my_first_rice_on_endeavouros_with_kde/
https://www.reddit.com/r/unixporn/comments/wih7jm/kde_plasma_new_desktop_layout_for_my_daily_driver/
https://www.reddit.com/r/unixporn/comments/y72zlv/kde_kde_rice_without_blur_real/

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
- Wallpapers: here

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
</details>

``` bash
sudo apt install micro curl open-vm-tools -y
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

Настриаваем плазму:
- [Global Theme](https://store.kde.org/p/1327723)
- [Login Screen](https://store.kde.org/p/1312658)
- [Screen Locking Wallpapers](https://store.kde.org/p/1069729)


Удаляем ненужное:
``` zsh
sudo apt remove nextcloud sweeper -y && sudo apt autoremove
```
