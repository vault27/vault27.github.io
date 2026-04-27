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

-- Cursor
vim.opt.guicursor = "n-v-c-i:block-Cursor-blinkwait175-blinkoff150-blinkon175"
-- n-v-c-i — Normal, Visual, Command-line, Insert modes
-- :block - block
vim.api.nvim_set_hl(0, 'Cursor', { fg = '#000000', bg = '#00FF00' })


-- Vault27 Markdown Theme
-- Warm retro terminal style for Markdown-heavy work
vim.cmd([[
  highlight clear
  syntax reset

  let g:colors_name = "vault27_fallout_markdown"

  " ============================================================
  " Base UI
  " ============================================================
  highlight Normal        guifg=#7ee787 guibg=#081008
  highlight NormalNC      guifg=#6fdc78 guibg=#081008
  highlight EndOfBuffer   guifg=#081008 guibg=#081008
  highlight SignColumn    guibg=#081008
  highlight FoldColumn    guifg=#3f7a46 guibg=#081008
  highlight LineNr        guifg=#24552a guibg=#081008
  highlight ColorColumn   guibg=#0d160d

  " ============================================================
  " Main text styles
  " ============================================================
  highlight Comment       guifg=#2f6e35 gui=italic
  highlight String        guifg=#a6f3a6
  highlight Identifier    guifg=#7ee787
  highlight Function      guifg=#d8ff9c gui=bold
  highlight Statement     guifg=#8df799 gui=bold
  highlight Keyword       guifg=#8df799 gui=bold
  highlight Type          guifg=#b8ffbf
  highlight Title         guifg=#f2f0c0 gui=bold

  " ============================================================
  " Selection / Search
  " ============================================================
  highlight Visual        guifg=#081008 guibg=#7ee787
  highlight Search        guifg=#081008 guibg=#d0a84f gui=bold
  highlight IncSearch     guifg=#081008 guibg=#f2cc60 gui=bold

  " ============================================================
  " Markdown headings
  " ============================================================
  highlight markdownH1    guifg=#f2f0c0 guibg=NONE gui=bold
  highlight markdownH2    guifg=#d8ff9c guibg=NONE gui=bold
  highlight markdownH3    guifg=#b8ff7a guibg=NONE gui=bold
  highlight markdownH4    guifg=#8df799 guibg=NONE gui=bold
  highlight markdownH5    guifg=#65d96b guibg=NONE gui=bold
  highlight markdownH6    guifg=#43b649 guibg=NONE gui=bold

  highlight @markup.heading.1.markdown guifg=#f2f0c0 gui=bold
  highlight @markup.heading.2.markdown guifg=#d8ff9c gui=bold
  highlight @markup.heading.3.markdown guifg=#b8ff7a gui=bold
  highlight @markup.heading.4.markdown guifg=#8df799 gui=bold
  highlight @markup.heading.5.markdown guifg=#65d96b gui=bold
  highlight @markup.heading.6.markdown guifg=#43b649 gui=bold

  " ============================================================
  " Bold / emphasis
  " ============================================================
  highlight Bold                    guifg=#ffbe55 guibg=NONE gui=bold
  highlight markdownBold            guifg=#ffbe55 guibg=NONE gui=bold
  highlight markdownItalic          guifg=#d8e6b0 guibg=NONE gui=italic
  highlight @markup.strong.markdown guifg=#ffbe55 gui=bold
  highlight @markup.italic.markdown guifg=#d8e6b0 gui=italic

  " ============================================================
  " Inline code - amber fallout
  " ============================================================
  highlight markdownCode            guifg=#ffbe55 guibg=NONE gui=bold
  highlight @markup.raw.markdown    guifg=#ffbe55 guibg=NONE gui=bold

  " ============================================================
  " Code blocks - amber fallout, no black box
  " ============================================================
  highlight markdownCodeBlock          guifg=#e6b35a guibg=NONE
  highlight markdownCodeDelimiter      guifg=#ffbe55 guibg=NONE gui=bold
  highlight @markup.raw.block.markdown guifg=#e6b35a guibg=NONE

  " ============================================================
  " Links
  " ============================================================
  highlight markdownUrl                  guifg=#9be9a8 guibg=NONE gui=underline
  highlight markdownLinkText             guifg=#7ee787 guibg=NONE gui=underline
  highlight @markup.link.label.markdown  guifg=#7ee787 gui=underline
  highlight @markup.link.url.markdown    guifg=#9be9a8 gui=underline

  " ============================================================
  " Dashed lists / markers
  " ============================================================
  highlight markdownListMarker        guifg=#ffbe55 guibg=NONE gui=bold
  highlight @markup.list.markdown     guifg=#ffbe55 gui=bold

  " ============================================================
  " Optional extras
  " ============================================================
  highlight markdownRule              guifg=#2f6e35
  highlight markdownHeadingDelimiter  guifg=#5fae66 gui=bold
  highlight markdownBlockquote        guifg=#6ea06e gui=italic
  highlight @markup.quote.markdown    guifg=#6ea06e gui=italic
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
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("cyberdream").setup({
            -- Optional configuration options here
            transparent = true,
            italic_comments = true,
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
  -- Table of contents generateor, command :Mtoc will generate TOC, it will be updated after each save
  {
    "hedyhli/markdown-toc.nvim",
    ft = "markdown", -- Use only for markdown files
    opts = {
      -- Options (We can leave blank {})
      unidiff = false, -- Show changes in separate window (false = in file)
      cycle_max_level = 6, -- Level to scan (till the end by default)
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




