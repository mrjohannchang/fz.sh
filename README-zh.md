# fz

無縫接軌地為 [z](https://github.com/rupa/z) 的 tab 自動完成加上模糊搜尋功能，不需再綁定其他熱鍵。使用者可以透過此程式在歷史目錄清單中自由跳躍。支援 Bash 與 zsh。

* [展示](#展示)
* [安裝程序](#安裝程序)
   * [macOS](#macos)
      * [Bash](#bash)
      * [zsh](#zsh)
   * [Ubuntu](#ubuntu)
      * [Bash](#bash-1)
      * [zsh](#zsh-1)
* [使用說明](#使用說明)
* [相關資訊](#相關資訊)
* [授權條款](#授權條款)

## 展示

請[至此](http://www.tudou.com/programs/view/eO0ljcrQfbk/)觀賞示範影片。

![示意圖](fz-demo.gif)

## 安裝程序

由 shell 中 source 對應的程式檔案即可使用。但因本程式仰賴 [z](https://github.com/rupa/z) 與 [fzf](https://github.com/junegunn/fzf)，故此二者也需要一併安裝至系統中。

### macOS

#### Bash

1. 經由 [Homebrew](https://brew.sh/) 安裝 fzf：

    ```sh
    brew install fzf
    ```

2. 下載 z 與 fz：

    ```sh
    mkdir ~/.bash_completion.d
    curl "https://raw.githubusercontent.com/rupa/z/master/{z.sh}" \
        -o ~/.bash_completion.d/"#1"
    curl "https://raw.githubusercontent.com/changyuheng/fz/master/{fz.bash}" \
        -o ~/.bash_completion.d/"#1"
    ```

3. 在 `~/.bashrc` 中加入以下資訊：

    ```sh
    if [ -d ~/.bash_completion.d ]; then
      for file in ~/.bash_completion.d/*; do
        . $file
      done
    fi
    ```

#### zsh

1. 經由 [Homebrew](https://brew.sh/) 安裝 fzf：

    ```sh
    brew install fzf
    ```

2. 透過 [zplug](https://github.com/zplug/zplug) 部署 z 與 fz。將以下資訊加入 `~/.zshrc`：

    ```sh
    zplug "rupa/z", use:z.sh
    zplug "changyuheng/fz"
    ```

### Ubuntu

#### Bash

1. 經由 [Homebrew](https://brew.sh/) 安裝 fzf：

    ```sh
    brew install fzf
    ```

2. 下載 z 與 fz：

    ```sh
    mkdir ~/.bash_completion.d
    curl "https://raw.githubusercontent.com/rupa/z/master/{z.sh}" \
        -o ~/.bash_completion.d/"#1"
    curl "https://raw.githubusercontent.com/changyuheng/fz/master/{fz.bash}" \
        -o ~/.bash_completion.d/"#1"
    ```

3. 在 `~/.bashrc` 中加入以下資訊：

    ```sh
    if [ -d ~/.bash_completion.d ]; then
      for file in ~/.bash_completion.d/*; do
        . $file
      done
    fi
    ```

#### zsh

1. 經由 [Homebrew](https://brew.sh/) 安裝 fzf：

    ```sh
    brew install fzf
    ```

2. 透過 [zplug](https://github.com/zplug/zplug) 部署 z 與 fz。將以下資訊加入 `~/.zshrc`：

    ```sh
    zplug "rupa/z", use:z.sh
    zplug "changyuheng/fz"
    ```

## 使用說明

- `tab`/`shift-tab`、`ctrl-n`/`ctrl-p`、`ctrl-j`/`ctrl-k` 選擇下一個、上一個選項。`Enter` 選擇。
- 程式的功能與 [z](https://github.com/rupa/z) 雷同。`-c` 限制搜尋範圍為當前目錄及子目錄。

## 相關資訊

- [cdr](https://github.com/willghatch/zsh-cdr) + [zaw](https://github.com/zsh-users/zaw)
- fzf’s [readme of completion](https://github.com/junegunn/fzf#fuzzy-completion-for-bash-and-zsh)
    and its [wiki](https://github.com/junegunn/fzf/wiki)
- [fasd](https://github.com/clvv/fasd)
- [autojump](https://github.com/wting/autojump)
- [命令行上的narrowing（随着输入逐步减少备选项）工具](http://www.cnblogs.com/bamanzi/p/cli-narrowing-tools.html)

## 授權條款

本軟體以 [MIT 授權條款](LICENSE) 授權。
