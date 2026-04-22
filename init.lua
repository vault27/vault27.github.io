-- A Lua script that runs every time Neovim starts
-- Lua is a programming language, like python

-- Enable mouse
-- Click, mark, scroll
vim.opt.mouse = "a"

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Enable true color
vim.opt.termguicolors = true

-- <leader> is a special prefix key you define to create your own shortcuts
vim.g.mapleader = " "

-- Vault27 Markdown Theme
-- Warm retro terminal style for Markdown-heavy work

vim.opt.termguicolors = true

vim.cmd([[
  highlight clear
  syntax reset

  let g:colors_name = "vault27_markdown"

  " ============================================================
  " Base UI
  " ============================================================
  highlight Normal        guifg=#e8dcc3 guibg=#16110d
  highlight NormalNC      guifg=#e0d2b4 guibg=#16110d
  highlight EndOfBuffer   guifg=#16110d guibg=#16110d
  highlight SignColumn    guibg=#16110d
  highlight FoldColumn    guifg=#8d7355 guibg=#16110d
  highlight CursorLine    guibg=#1f1813
  highlight CursorLineNr  guifg=#d9b36c guibg=#1f1813 gui=bold
  highlight LineNr        guifg=#7c6346 guibg=#16110d
  highlight ColorColumn   guibg=#211912
  highlight Conceal       guifg=#8d7355 guibg=#16110d

  " ============================================================
  " Selection / Search
  " ============================================================
  highlight Visual        guifg=NONE    guibg=#3a2b20
  highlight Search        guifg=#16110d guibg=#d9b36c gui=bold
  highlight IncSearch     guifg=#16110d guibg=#f0c674 gui=bold

  " ============================================================
  " Statusline / Split / Popup
  " ============================================================
  highlight StatusLine    guifg=#eadfc7 guibg=#241b14
  highlight StatusLineNC  guifg=#8d7355 guibg=#1d1611
  highlight VertSplit     guifg=#30241b guibg=#16110d
  highlight WinSeparator  guifg=#30241b guibg=#16110d

  highlight Pmenu         guifg=#e8dcc3 guibg=#211913
  highlight PmenuSel      guifg=#16110d guibg=#d9b36c gui=bold
  highlight PmenuSbar     guibg=#211913
  highlight PmenuThumb    guibg=#8d7355

  " ============================================================
  " Generic Syntax
  " ============================================================
  highlight Comment       guifg=#7c6a58 gui=italic
  highlight String        guifg=#9fef88
  highlight Character     guifg=#9fef88
  highlight Number        guifg=#e6a86a
  highlight Boolean       guifg=#e6a86a gui=bold
  highlight Float         guifg=#e6a86a
  highlight Identifier    guifg=#eadfc7
  highlight Function      guifg=#d8b25f
  highlight Statement     guifg=#cf9f63
  highlight Conditional   guifg=#cf9f63 gui=bold
  highlight Repeat        guifg=#cf9f63 gui=bold
  highlight Keyword       guifg=#cf9f63 gui=bold
  highlight Operator      guifg=#d6c3a0
  highlight PreProc       guifg=#c7a46a
  highlight Type          guifg=#bda06e
  highlight Special       guifg=#dfb77d
  highlight Delimiter     guifg=#a28663
  highlight Title         guifg=#e0b96d gui=bold

  " ============================================================
  " Diagnostics
  " ============================================================
  highlight DiagnosticError guifg=#ff7b72
  highlight DiagnosticWarn  guifg=#e0af68
  highlight DiagnosticInfo  guifg=#7fbfdf
  highlight DiagnosticHint  guifg=#8fbf8f

  " ============================================================
  " Markdown headings
  " ============================================================
  highlight markdownH1 guifg=#f0c674 guibg=NONE gui=bold
  highlight markdownH2 guifg=#e5b567 guibg=NONE gui=bold
  highlight markdownH3 guifg=#d9a95f guibg=NONE gui=bold
  highlight markdownH4 guifg=#c99657 guibg=NONE gui=bold
  highlight markdownH5 guifg=#b8844d guibg=NONE gui=bold
  highlight markdownH6 guifg=#9f6f42 guibg=NONE gui=bold

  " Header markers (#)
  highlight markdownHeadingDelimiter guifg=#7a5f43 gui=bold
  highlight markdownRule guifg=#6b5643

  " ============================================================
  " Markdown emphasis
  " ============================================================
  highlight markdownBold       guifg=#ffe4a3 guibg=NONE gui=bold
  highlight markdownItalic     guifg=#d9c8a3 guibg=NONE gui=italic
  highlight markdownBoldItalic guifg=#fff0b8 guibg=NONE gui=bold,italic

  " ============================================================
  " Markdown links / lists / quotes
  " ============================================================
  highlight markdownUrl        guifg=#7fcf9f guibg=NONE gui=underline
  highlight markdownLinkText   guifg=#d8b25f guibg=NONE gui=underline
  highlight markdownListMarker guifg=#ff8f5a guibg=NONE gui=bold
  highlight markdownBlockquote guifg=#9e8563 guibg=NONE gui=italic

  " ============================================================
  " Inline code and fenced code blocks
  " ============================================================
  highlight markdownCode      guifg=#b8ff9f guibg=#112017
  highlight markdownCodeBlock guifg=#b8ff9f guibg=#112017
  highlight markdownCodeDelimiter guifg=#6ccf8a guibg=#112017 gui=bold

  " ============================================================
  " Treesitter Markdown groups (important in modern Neovim)
  " ============================================================
  highlight @markup.heading.1.markdown guifg=#f0c674 gui=bold
  highlight @markup.heading.2.markdown guifg=#e5b567 gui=bold
  highlight @markup.heading.3.markdown guifg=#d9a95f gui=bold
  highlight @markup.heading.4.markdown guifg=#c99657 gui=bold
  highlight @markup.heading.5.markdown guifg=#b8844d gui=bold
  highlight @markup.heading.6.markdown guifg=#9f6f42 gui=bold

  highlight @markup.strong.markdown guifg=#ffe4a3 gui=bold
  highlight @markup.italic.markdown guifg=#d9c8a3 gui=italic
  highlight @markup.strikethrough.markdown guifg=#7c6a58 gui=strikethrough

  highlight @markup.link.label.markdown guifg=#d8b25f gui=underline
  highlight @markup.link.url.markdown guifg=#7fcf9f gui=underline

  highlight @markup.list.markdown guifg=#ff8f5a gui=bold
  highlight @markup.quote.markdown guifg=#9e8563 gui=italic

  highlight @markup.raw.markdown guifg=#b8ff9f guibg=#112017
  highlight @markup.raw.block.markdown guifg=#b8ff9f guibg=#112017

  " ============================================================
  " Markdown borders feeling via floating windows
  " ============================================================
  highlight FloatBorder   guifg=#5e4a38 guibg=#16110d
  highlight NormalFloat   guifg=#e8dcc3 guibg=#1a140f
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
    "hedyhli/markdown-toc.nvim",
    ft = "markdown", -- Загружать только для markdown файлов
    opts = {
      -- Настройки (можно оставить пустыми {})
      unidiff = false, -- Показывать изменения в отдельном окне (false = сразу в файле)
      cycle_max_level = 3, -- До какого уровня заголовков сканировать (по умолчанию до конца)
    },
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




