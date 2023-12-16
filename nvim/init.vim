" encode = utf-8
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" オートインデント
set autoindent
set smartindent
" 対応するカッコを表示
set showmatch
"シンタックスハイライト
syntax on
" タブをスペース4つ分に
set tabstop=4
" サーチ時に大文字小文字を区別しない
set ignorecase
" 小文字で検索すると大文字小文字を区別しない
set smartcase
" 検索がファイルの終わりまで行ったら先頭に戻る
set wrapscan
" 検索結果ハイライト表示
set hlsearch
" beepもビジュアルベルも無効
set vb t_vb=
" Clipboardからペースト可能に
vmap <C-c> "+y

" jjでEsc
inoremap <silent> jj <ESC>
inoremap <silent> っｊ <ESC>
