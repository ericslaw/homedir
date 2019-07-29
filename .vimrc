" standard settings
" TODO: isolate vi vs vim options for when 'alias vi=vim' was not performed
set display+=uhex isprint=
set bg=dark
set ignorecase
set smartcase
set expandtab
set tabstop=4
set shiftwidth=4
set nowrap
set hlsearch
"set autoindent
set backspace=indent,eol "start
"set modeline=on

" filetype detection exceptions
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
autocmd BufNewFile,BufReadPost *.md syntax on
autocmd BufNewFile,BufReadPost *.pl set filetype=perl
autocmd BufNewFile,BufReadPost *.pm set filetype=perl

" check perl code with :make (but how do I know it's perl?)
autocmd FileType perl set expandtab shiftwidth=4 softtabstop=4
autocmd FileType perl set makeprg=perl\ -c\ %\ $*
autocmd FileType perl set errorformat=%f:%l:%m
autocmd FileType perl set autowrite

" open at last edit - did not work
"autocmd BufWinLeave * mkview   " requires .vim/view
autocmd BufWinLeave * silent loadview

" auto backup files in the following directory searching until you find one
set backup
set writebackup
set backupdir=./backup,~/.backup,.,/tmp
autocmd BufWritePre * let &backupext = '-' . strftime("%Y%m%d_%H%M%S") . '~'

" double-escape converts all tabs to spaces
map <Esc><Esc> :%s/<C-I>/    /g<C-M>/replacedTabsWithSpaces<C-M>
map ,pt <Esc>:%!perltidy -ndsm -st -ce -bar -nola -l=220
iabbr _BEGIN BEGIN{use Cwd qw(abs_path);use File::Basename;chdir dirname(abs_path($0)); use lib '.';}
iabbr _DD use Data::Dumper;$Data::Dumper::Sortkeys=$Data::Dumper::Indent=$Data::Dumper::Terse=1;
iabbr _uniq sub uniq  { my %seen=(); return grep { ! $seen{$_}++ } @_; };
iabbr _slurp sub slurp {return unless -f $_[0];do{local(@ARGV)=$_[0]; return (wantarray) ? <> : join"",<> }}
iabbr _natsort sub natsort    {return map{$_->[0]}sort{$a->[1]cmp$b->[1]}map{[$_,naturalize($_)]}@_}
iabbr _natural sub naturalize {return join"",map{!m/\d/?$_:sprintf"%.*d",$_[1]?$_[1]:4,$_}split/(\d+)/,$_[0]}
iabbr _week  Week 2019-07-28 {{ {<C-M>U:<C-M>M: SOD xxxx EOD xxxx<C-M>T: SOD xxxx EOD xxxx<C-M>W: SOD xxxx EOD xxxx<C-M>R: SOD xxxx EOD xxxx<C-M>F: SOD xxxx EOD xxxx<C-M>S:<C-M>}} }
iabbr _## ################################################################################
iabbr _#- #-------------------------------------------------------------------------------
abbr _trim :%s/  *$//g<C-M>

" MAGIC+REGEX     see: http://andrewradev.com/2011/05/08/vim-regexes/
" magic \m (default) \m = normal regex chars: .?+() # missing *?
" very magic         \v = mostly perl compatible regex
" nomagic            \M = all chars nomral except $ (eol)
" very nomagic       \V = all chars normal, backslash to enable
"
" zero-width assertions: http://vimdoc.sourceforge.net/htmldoc/pattern.html#/zero-width
"
" note: GetModeline is just an autocmd function that searches for vim commands in comments and executes : see https://www.vim.org/scripts/script.php?script_id=72


" use standard {{{}}} marker notation for folding
" but bold highlights are distracting.
" mark folded lines with simple header line plus '...' suffix instead
set foldmethod=marker
: set fillchars=stl:=,stlnc:_,vert:\|,fold:\ ,diff:-
set foldtext=MyFoldText()
highlight Folded term=bold cterm=bold ctermbg=NONE ctermfg=NONE
function MyFoldText()
  let line = getline(v:foldstart)
  let sub = substitute(line, '/\*\|\*/\|{[{]{\d\=', '', 'g') . "...                                                                                                                                                                                    "
  # return v:folddashes . sub
  return sub
endfunction


"TODO: build function to map common unicode to ascii  '\%xHH','newchar'
" note: functions must start with uppercase!! (wut?)
" exec: call MyTidyUnicode()
" todo: call this on newly inserted text: autocmd {event} {pattern} {command}   # ie: :autocmd TextChanged,CompleteDone * call MyTidyUnicode()
" test: TextChanged - does not appear to trigger on normal insert/append with paste
" test: autocmd CompleteDone * :echo "TextChange" - does not trigger at all?
" eventlist: http://tech.saigonist.com/b/code/list-all-vim-script-events
" todo: perltidy on write
" https://vi.stackexchange.com/a/5962
" https://devhints.io/vimscript
" https://www.ibm.com/developerworks/library/l-vim-script-2/index.html
"function! Ascii() range
"  for i in range(a:firstline, a:lastline)
"    let line = getline(i)
"    let line = substitute(line,'\%xE2\%x80\%xA2','*','g')
"        call setline(l, substitute(line, '\([^= ]\)=', '\1 =', "g"))
"    call setline('.',line)
"  endfor
"  echo "applied Ascii " (a:firstline) "," (a:lastline) " (" (a:lastline - a:firstline + 1) ") lines"
"endfunction

let Tlist_Ctags_Cmd='/bin/ctags'

"TODO: auto load bin/skel.pl on empty .pl file
"TODO: auto write .pl files and set exec and test compile
"autocmd BufWritePost *.pl !chmod +x %
"autocmd BufWritePost *.pl !perl -c %
" other options - perltidy, perl -c'
" perlysense? emacs?
" dcbpw.org?

autocmd BufReadPost TODO.txt /ZZZZ
