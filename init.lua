-- A Lua script that runs every time Neovim starts
-- Lua is a programming language, like python:

-- Включает поддержку мыши во всех режимах Neovim.
-- Можно кликать, выделять, скроллить.
vim.opt.mouse = "a"

-- Говорит Neovim использовать системный clipboard macOS.
-- "unnamedplus" = регистр +, то есть общий clipboard системы.
-- После этого "+y и "+p работают с системным буфером.
vim.opt.clipboard = "unnamedplus"

-- Включает true color в терминале.
-- Нужен для нормальных современных цветов и тем.
vim.opt.termguicolors = true

vim.g.mapleader = " "

-- Vault27-style retro amber theme for terminal Markdown writing
vim.cmd([[
  " Main editor background and text
  highlight Normal       guifg=#e6d6b8 guibg=#1a120d
  highlight NormalNC     guifg=#e6d6b8 guibg=#1a120d
  highlight EndOfBuffer  guifg=#1a120d guibg=#1a120d
  highlight SignColumn   guibg=#1a120d
  highlight FoldColumn   guibg=#1a120d
  highlight LineNr       guifg=#8c6f4d guibg=#1a120d
  highlight CursorLineNr guifg=#cfa96a guibg=#1a120d gui=bold

  " Selection and search
  highlight Visual       guifg=NONE    guibg=#3a2a1f
  highlight Search       guifg=#1a120d guibg=#cfa96a
  highlight IncSearch    guifg=#1a120d guibg=#ffcc66 gui=bold

  " Status and split
  highlight StatusLine   guifg=#e6d6b8 guibg=#2a1b14
  highlight StatusLineNC guifg=#8c6f4d guibg=#2a1b14
  highlight VertSplit    guifg=#3a2a1f guibg=#1a120d
  highlight WinSeparator guifg=#3a2a1f guibg=#1a120d

  " Popup/menu
  highlight Pmenu        guifg=#e6d6b8 guibg=#241811
  highlight PmenuSel     guifg=#1a120d guibg=#cfa96a
  highlight PmenuSbar    guibg=#241811
  highlight PmenuThumb   guibg=#8c6f4d

  " Markdown headings - amber/gold, no ugly boxes
  highlight markdownH1   guifg=#d8b25f guibg=NONE gui=bold
  highlight markdownH2   guifg=#cfa96a guibg=NONE gui=bold
  highlight markdownH3   guifg=#c59a52 guibg=NONE gui=bold
  highlight markdownH4   guifg=#b98b49 guibg=NONE gui=bold
  highlight markdownH5   guifg=#a97b3d guibg=NONE gui=bold
  highlight markdownH6   guifg=#8f6731 guibg=NONE gui=bold

  " Markdown text styles
  highlight markdownBold       guifg=#f0dfb0 guibg=NONE gui=bold
  highlight markdownItalic     guifg=#d9c89e guibg=NONE gui=italic
  highlight markdownCode       guifg=#9fef00 guibg=#0f2a1c
  highlight markdownCodeBlock  guifg=#9fef00 guibg=#0f2a1c
  highlight markdownUrl        guifg=#7fbf7f guibg=NONE gui=underline
  highlight markdownLinkText   guifg=#cfa96a guibg=NONE gui=underline
  highlight markdownListMarker guifg=#ff5f4a guibg=NONE gui=bold

  " Generic syntax groups
  highlight Comment      guifg=#7d6a58 gui=italic
  highlight String       guifg=#9fef00
  highlight Identifier   guifg=#e6d6b8
  highlight Function     guifg=#d8b25f
  highlight Statement    guifg=#cfa96a
  highlight Keyword      guifg=#cfa96a gui=bold
  highlight Type         guifg=#b7a06d
]])

-- vim.fn.stdpath("data") - returns a directory where Neovim stores data
-- On your Mac, it is usually: /Users/philozow/.local/share/nvim
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" builds a full path: /Users/philozow/.local/share/nvim/lazy/lazy.nvim this is where the lazy.nvim plugin is installed
-- vim.opt.rtp means: runtimepath - It is a list of folders where Neovim looks for: plugins, colorschemes....
-- What does prepend mean - add this path to the BEGINNING of runtimepath - Neovim searches from top → down - Neovim searches from top → down
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
  "folke/tokyonight.nvim",
  config = function()
    require("tokyonight").setup({
      transparent = true
    })
    end,
  },

  { 
  "xiyaowong/transparent.nvim", 
  lazy = false,
  config = function()
    require("transparent").setup()
  end,
  },

  {
    -- Treesitter для современной подсветки синтаксиса
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  {
    -- Sidebar outline
    "hedyhli/outline.nvim",
    config = function()
      -- Инициализация outlin
      require("outline").setup()

      -- Открыть outline через Space + o
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>")
    end,
  },
})
vim.opt.clipboard = "unnamedplus"

-- $VIMRUNTIME/example_init.lua

-- Set <space> as the leader key
-- See `:h mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '

-- OPTIONS
--
-- See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:h option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

vim.o.number = true -- Show line numbers in a column.

-- Show line numbers relative to where the cursor is.
-- Affects the 'number' option above, see `:h number_relativenumber`.
vim.o.relativenumber = false

-- Sync clipboard between OS and Neovim. Schedule the setting after `UIEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:h 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.o.clipboard = 'unnamedplus'
  end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.cursorline = true -- Highlight the line where the cursor is on.
vim.o.scrolloff = 10 -- Keep this many screen lines above/below the cursor.
vim.o.list = true -- Show <tab> and trailing spaces.

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s). See `:h 'confirm'`
vim.o.confirm = true

-- KEYMAPS
--
-- See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- AUTOCOMMANDS (EVENT HANDLERS)
--
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- USER COMMANDS: DEFINE CUSTOM COMMANDS
--
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
  local filename = vim.api.nvim_buf_get_name(0)
  print(vim.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }):wait().stdout)
end, { desc = 'Print the git blame for the current line' })

-- PLUGINS
--
-- See `:h :packadd`, `:h vim.pack`

-- Add the "nohlsearch" package to automatically disable search highlighting after
-- 'updatetime' and when going to insert mode.
vim.cmd('packadd! nohlsearch')

-- Install third-party plugins via "vim.pack.add()".
vim.pack.add({
  -- Quickstart configs for LSP
  'https://github.com/neovim/nvim-lspconfig',
  -- Fuzzy picker
  'https://github.com/ibhagwan/fzf-lua',
  -- Autocompletion
  'https://github.com/nvim-mini/mini.completion',
  -- Enhanced quickfix/loclist
  'https://github.com/stevearc/quicker.nvim',
  -- Git integration
  'https://github.com/lewis6991/gitsigns.nvim',
})

require('fzf-lua').setup { fzf_colors = true }
require('mini.completion').setup {}
require('quicker').setup {}
require('gitsigns').setup {}
