# packages
https://vi.stackexchange.com/questions/9522/what-is-the-vim8-package-feature-and-how-should-i-use-it
https://vi.stackexchange.com/a/9523/22945
http://vimcasts.org/episodes/packages/
https://shapeshed.com/vim-packages/
https://git-scm.com/book/en/v2/Git-Tools-Submodules
https://www.reddit.com/r/vim/comments/7doeit/using_vim_8_package_loader_tipguide/

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

# conceal
https://vi.stackexchange.com/questions/8559/vim-conceal-indentation-replace-indentation-spaces-with-utf-8-chars

# folding
https://www.linux.com/training-tutorials/vim-tips-folding-fun/
questionable method: https://coderwall.com/p/faceag/format-json-in-vim
https://learnvimscriptthehardway.stevelosh.com/chapters/49.html
https://stackoverflow.com/questions/47565285/folding-json-at-specific-points

# git submodule

    cd ~/.vim/pack/default/start
    git submodule add https://github.com/elzr/vim-json.git
    git submodule update --remote --merge && git commit

    git submodule init
    git submodule deinit ?

    had to set filetype and some other stuffs in .vimrc

# markdown?
    markdown.vim    tim pope                            https://github.com/tpope/vim-markdown
        vim-flavored-markdown       jeff trainer        https://github.com/jtratner/vim-flavored-markdown
    vim-markdown-preview-red                            https://github.com/jamshedvesuna/vim-markdown-preview       perl renders into html then opens chrome
    instant-markdown-vim                                https://github.com/suan/vim-instant-markdown                nodejs render with nodejs miniserver :(
                                                        https://github.com/plasticboy/vim-markdown                  python

# other modules?
https://medium.com/@huntie/10-essential-vim-plugins-for-2018-39957190b7a9
https://opensource.com/article/19/11/vim-plugins
https://opensource.com/article/19/1/vim-plugins-developers
https://github.com/tpope/vim-surround
https://github.com/tpope?tab=repositories&q=vim-&type=source&language=

