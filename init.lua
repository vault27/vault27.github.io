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
