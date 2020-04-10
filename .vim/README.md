read:
https://vi.stackexchange.com/questions/9522/what-is-the-vim8-package-feature-and-how-should-i-use-it
https://vi.stackexchange.com/a/9523/22945
http://vimcasts.org/episodes/packages/
https://shapeshed.com/vim-packages/
https://git-scm.com/book/en/v2/Git-Tools-Submodules

defs
    script      code.vim
    plugin      {{name}}/plugin/{{name}}.vim  {{name}}/doc/{{name}}.txt # but which name is used to find? directory found in runtimepath   :set runtimepath+=~/.vim/plugins
    package     ~/.vim/pack/{{package}}/{start,opt}/{{plugins}}

    any dirs found in ~/.vim/pack/* that contain ./start get added to runtimepath

default packpath on macos vim8.0 2016-09-12
    packpath=~/.vim,/usr/share/vim/vimfiles,/usr/share/vim/vim80,/usr/share/vim/vimfiles/after,~/.vim/after
    runtimepath=~/.vim,/usr/share/vim/vimfiles,/usr/share/vim/vim80,/usr/share/vim/vimfiles/after,~/.vim/after

so do this

    mkdir -p ~/.vim/pack/default/{start,opt}
    # note: autostart with symlinks DOES NOT WORK
    cd ~/.vim/pack/default/start
    git submodule add https://github.com/elzr/vim-json.git
    git submodule update --remote --merge && git commit

    git submodule init
    git submodule deinit ?

    had to set filetype and some other stuffs in .vimrc
