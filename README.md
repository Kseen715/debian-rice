# debian-rice
Debian 12.5.0 64-bit @ 2024.03.06

https://www.reddit.com/r/unixporn/comments/lydglv/kdeplasma_easy_on_the_eyes_gruvbox_theme/
https://www.reddit.com/r/unixporn/comments/kt1qlg/plasma_my_first_rice_on_endeavouros_with_kde/
https://www.reddit.com/r/unixporn/comments/wih7jm/kde_plasma_new_desktop_layout_for_my_daily_driver/
https://www.reddit.com/r/unixporn/comments/y72zlv/kde_kde_rice_without_blur_real/

**Конфигурация**:</br>
- OS: Debian</br>
- DE: KDE/Plasma</br>
- WM: KWin</br>
- Terminal: Konsole</br>
- Shell: ZSH with [Starship](https://starship.rs/)</br>
- Fonts: Fira Code + Iosevka</br>
- ColorScheme: My Gruvbox</br>
- Icons: My fork of tela icons to match the gruvbox vibes a bit more</br>
- Dotfiles: here</br>
- Wallpapers: here

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

Обновляем все:
``` bash
sudo apt update && sudo apt upgrade
```

В качестве текстового редактора будем использовать `micro`: 
``` bash
sudo apt install micro curl -y
```

``` bash
sudo apt install open-vm-tools -y
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
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
``` zsh
curl -sS https://starship.rs/install.sh | sudo sh
```

``` zsh
exec zsh
```


Настриаваем плазму:
micro ~/.config/plasma-org.kde.plasma.desktop-appletsrc
