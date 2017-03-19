# fz

A shell plugin that has fuzzy search tab completion,
lets you easy to jump around among your historical directories.
Currently supports Bash and zsh.

* [Demo](#demo)
* [Installation](#installation)
   * [macOS](#macos)
      * [Bash](#bash)
      * [zsh](#zsh)
* [Usage](#usage)
* [See Also](#see-also)

## Demo

Watch video demo [here](https://youtu.be/GcVC1f2fdXk).

![gif-demo](fz-demo.gif)

## Installation

By simply sourcing corresponding script file for your shell, you're all set.
However, this plugin is sitting on top of [z](https://github.com/rupa/z) and
[fzf](https://github.com/junegunn/fzf), so you must have them installed as well.

### macOS

#### Bash

1. Install fzf via [Homebrew](https://brew.sh/).

    ```sh
    brew install fzf
    ```

2. Download z and fz.

   ```sh
   mkdir ~/.bash_completion.d
   curl "https://raw.githubusercontent.com/rupa/z/master/{z.sh}" \
       -o ~/.bash_completion.d/"#1"
   curl "https://raw.githubusercontent.com/changyuheng/fz/master/{fz.bash}" \
       -o ~/.bash_completion.d/"#1"
   ```

3. Add the following content to `~/.bashrc`:

    ```sh
    if [ -d ~/.bash_completion.d ]; then
      for file in ~/.bash_completion.d/*; do
        . $file
      done
    fi
    ```

#### zsh

1. Install fzf via [Homebrew](https://brew.sh/).

    ```sh
    brew install fzf
    ```

2. Install z and fz via [zplug](https://github.com/zplug/zplug).
    Add the following content to `~/.zshrc`:

    ```sh
    zplug "rupa/z", use:z.sh
    zplug "changyuheng/fz"
    ```

## Usage

- `tab`/`shift-tab`, `ctrl-n`/`ctrl-p`, `ctrl-j`/`ctrl-k`,
    for next and previous item. `Enter` for selection.
    Check fzf’s [doc](https://github.com/junegunn/fzf#search-syntax)
    for the search syntaxes.
- The function of fz is pretty much like what it is of
    [z](https://github.com/rupa/z).
    `-c` restricts the search base starting from current working directory.
    Check z’s doc for more information.

## See Also

- [cdr](https://github.com/willghatch/zsh-cdr) + [zaw](https://github.com/zsh-users/zaw)
- fzf’s [readme of completion](https://github.com/junegunn/fzf#fuzzy-completion-for-bash-and-zsh)
    and its [wiki](https://github.com/junegunn/fzf/wiki)
- [fasd](https://github.com/clvv/fasd)
- [autojump](https://github.com/wting/autojump)
- [命令行上的narrowing（随着输入逐步减少备选项）工具](http://www.cnblogs.com/bamanzi/p/cli-narrowing-tools.html)