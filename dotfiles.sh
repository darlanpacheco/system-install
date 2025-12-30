name=$(cat /softwares/name)
userhome="/home/$(whoami)"
email=$(cat /softwares/email)

tee "${userhome}"/.bashrc >/dev/null <<EOF
alias c="clear"
alias e="exit"

alias rm="trash"
alias dl="rm"
alias ls="eza --icons"

alias install="nix-env -iA"
alias uninstall="nix-env -e"
alias update="sudo pacman -Syu && flatpak update -y && nix-channel --update && nix-env -u '*'"
alias list="nix-env -q"

alias gts="git status"
alias gta="git add"
alias gtc="git commit"
alias gtp="git push"
alias gtl="git log"

terminal() {
  alacritty --working-directory \${PWD} &
}

export EDITOR=nvim
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_BACKEND=wayland
export GDK_BACKEND=wayland
export GTK_THEME=adw-gtk3-dark
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=gtk3
EOF

mkdir -p "${userhome}"/.config
tee "${userhome}"/.config/mimeapps.list >/dev/null <<EOF
[Default Applications]
x-scheme-handler/http=org.mozilla.firefox.desktop
x-scheme-handler/https=org.mozilla.firefox.desktop
image/png=org.gimp.GIMP.desktop
image/jpg=org.gimp.GIMP.desktop
image/jpeg=org.gimp.GIMP.desktop
image/webp=org.gimp.GIMP.desktop
image/gif=org.gimp.GIMP.desktop
video/mp4=org.mozilla.firefox.desktop
video/webm=org.mozilla.firefox.desktop
video/x-matroska=org.mozilla.firefox.desktop
video/ogg=org.mozilla.firefox.desktop
audio/mpeg=org.mozilla.firefox.desktop
audio/wav=org.mozilla.firefox.desktop
audio/ogg=org.mozilla.firefox.desktop
audio/mp4=org.mozilla.firefox.desktop
application/pdf=org.mozilla.firefox.desktop
EOF

mkdir -p "${userhome}"/.config/gtk-3.0
tee "${userhome}"/.config/gtk-3.0/settings.ini >/dev/null <<EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-font-name=JetBrains Mono 12
gtk-icon-theme-name=Papirus
gtk-theme-name=adw-gtk3-dark
EOF
mkdir -p "${userhome}"/.config/gtk-4.0
tee "${userhome}"/.config/gtk-4.0/settings.ini >/dev/null <<EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-font-name=JetBrains Mono, 12
gtk-icon-theme-name=Papirus
gtk-theme-name=adw-gtk3-dark
EOF

mkdir -p "${userhome}"/.config/hypr
tee "${userhome}"/.config/hypr/hyprland.conf >/dev/null <<EOF
{
    workspace = 1, default:true
}
{
    exec-once = gammastep -O 2560k
    exec-once = waybar
    exec-once = hyprctl setcursor Adwaita 32
    exec-once = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    exec-once = gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
    exec-once = gsettings set org.gnome.desktop.interface font-name "JetBrains Mono 12"
    exec-once = gsettings set org.gnome.desktop.interface icon-theme "Papirus"
}
{
    bind = super, k, exec, pactl set-sink-volume @DEFAULT_SINK@ +8%
    bind = super, j, exec, pactl set-sink-volume @DEFAULT_SINK@ -8%

    bind = super, t, togglefloating

    bind = super, return, exec, alacritty
    bind = super, r, exec, rofi -show drun
    bind = super, p, exec, grim -g "\$(slurp)" - | wl-copy

    bind = super, f, fullscreen, active
    bind = super, q, closewindow, active

    bind = super, right, movefocus, r
    bind = super, up, movefocus, u
    bind = super, left, movefocus, l
    bind = super, down, movefocus, d

    bind = super, 1, workspace, 1
    bind = super, 2, workspace, 2
    bind = super, 3, workspace, 3
    bind = super, 4, workspace, 4

    bind = alt_l, 1, movetoworkspace, 1
    bind = alt_l, 2, movetoworkspace, 2
    bind = alt_l, 3, movetoworkspace, 3
    bind = alt_l, 4, movetoworkspace, 4

    bind = superalt_l, right, movewindow, r
    bind = superalt_l, up, movewindow, u
    bind = superalt_l, left, movewindow, l
    bind = superalt_l, down, movewindow, d

    bind = supershift, right, resizeactive, 64 0
    bind = supershift, up, resizeactive, 0 -64
    bind = supershift, left, resizeactive, -64 0
    bind = supershift, down, resizeactive, 0 64

    bindm = superalt_l, mouse:272, movewindow
    bindm = supershift, mouse:272, resizewindow
}
input {
    kb_layout = br
    sensitivity = -0.2
    accel_profile = flat
}
general {
    gaps_in = 4
    gaps_out = 8
    border_size = 0
}
decoration {
    active_opacity = 1
    inactive_opacity = 1
    fullscreen_opacity = 1
    rounding = 8

    shadow {
        enabled = false
    }
    blur {
        enabled = true
    }
}
animations {
    enabled = false
}
misc {
    force_default_wallpaper = 2
    enable_anr_dialog = false
    disable_splash_rendering = true
    # disable_hyprland_logo = true
    # background_color = 0x0f0f0f
}
ecosystem {
    no_update_news = true
    no_donation_nag = true
}
EOF

mkdir -p "${userhome}"/.config/waybar
tee "${userhome}"/.config/waybar/config.jsonc >/dev/null <<EOF
{
  "position": "top",
  "modules-left": ["hyprland/workspaces"],
  "modules-center": ["custom/clock"],
  "modules-right": [
    "pulseaudio",
    "custom/cpu_temp",
    "custom/gpu_temp",
    "memory",
    "disk",
    "network",
    "tray",
  ],

  "hyprland/workspaces": {
    "format": "{name}",
  },
  "custom/clock": {
    "exec": "date '+%H:%M %a %m-%d'",
    "interval": 32,
    "format": "{}",
  },
  "pulseaudio": {
    "format": "VOL {volume}",
  },

  "network": {
    "interval": 1,
    "format-ethernet": "NETWORK {bandwidthDownBytes} {bandwidthUpBytes}",
    "format-wifi": "NETWORK {bandwidthDownBytes} {bandwidthUpBytes}",
  },
  "custom/cpu_temp": {
    "exec": "sensors | grep -i tctl | grep -oP '\\\\d+(?=\\\\.)'",
    "interval": 2,
    "format": "CPU {}",
  },
  "custom/gpu_temp": {
    "exec": "sensors | grep -i edge | grep -oP '\\\\d+(?=\\\\.)'",
    "interval": 2,
    "format": "GPU {}",
  },
  "memory": {
    "interval": 2,
    "format": "RAM {used:0.1f}",
  },
  "disk": {
    "interval": 8,
    "format": "DISK {specific_used:0.1f}",
    "unit": "GiB",
  },
  "tray": {
    "icon-size": 32,
  },
}
EOF
tee "${userhome}"/.config/waybar/style.css >/dev/null <<EOF
* {
  font-family: "JetBrains Mono";
  font-weight: Bold;
  font-size: 15px;
  border: none;
  outline: none;
  box-shadow: none;
  border-radius: 0px;
  color: #ffffff;
}

#waybar,
button,
button > *,
menu,
menuitem,
separator {
  background: #0f0f0f;
}
menuitem:hover {
  background: #242424;
}

button {
  padding: 4px;
}
button label {
  color: #242424;
}
button.active label {
  color: #ffffff;
}
menu {
  padding: 9px;
  border-radius: 8px;
}
menuitem {
  padding: 5px 9px;
}
tooltip {
  opacity: 0;
}

#pulseaudio,
#custom-cpu_temp,
#custom-gpu_temp,
#memory,
#disk,
#network {
  padding: 8px;
}
#tray {
  padding-right: 4px;
}
EOF

mkdir -p "${userhome}"/.config/rofi
tee "${userhome}"/.config/rofi/config.rasi >/dev/null <<EOF
configuration {
  font: "JetBrains Mono Bold 13";
}

* {
  fg: #242424;
  bg: #0f0f0f;
}

window {
  children: [inputbar, listview];
  padding: 9px;
  border-radius: 8px;
  border: 0px;
  width: 500px;
  background-color: var(bg);
}

inputbar {
  children: [entry];
}
entry {
  text-color: white;
}

listview {
  border: none;
  scrollbar: false;
  lines: 5;
}

element {
  children: [element-icon, element-text];
  padding: 9px;
}
element-text {
  text-color: white;
}
element normal normal {
  background-color: var(bg);
}
element alternate normal {
  background-color: var(bg);
}
element selected normal {
  background-color: var(fg);
}

textbox {
  text-color: white;
}
EOF

mkdir -p "${userhome}"/.config/alacritty
tee "${userhome}"/.config/alacritty/alacritty.toml >/dev/null <<EOF
[colors.primary]
background = "#0f0f0f"

[font]
size = 12
[font.normal]
family = "JetBrains Mono"
style = "Regular"
[font.bold]
family = "JetBrains Mono"
style = "Bold"
[font.bold_italic]
family = "JetBrains Mono"
style = "Bold Italic"
[font.italic]
family = "JetBrains Mono"
style = "Italic"
EOF

tee "${userhome}"/.gitconfig >/dev/null <<EOF
[user]
  name = ${name}
  email = ${email}
EOF

mkdir -p "${userhome}"/.config/ranger
tee "${userhome}"/.config/ranger/scope.sh >/dev/null <<EOF
#!/usr/bin/env bash

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$"\n"

FILE_PATH="${1}"
PV_WIDTH="${2}"
MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"

handle_mime() {
  local mimetype="${1}"
  if [[ "${mimetype}" == text/* ]]; then
    cat "${FILE_PATH}" && exit 2
  elif [[ "${mimetype}" == image/* ]]; then
    chafa --size="${PV_WIDTH}x${PV_WIDTH}" --colors=256 --symbols=all "${FILE_PATH}"
  fi
}

handle_mime "${MIMETYPE}"
file --dereference --brief -- "${FILE_PATH}" && exit 5
exit 1
EOF
chmod +x "${userhome}"/.config/ranger/scope.sh
tee "${userhome}"/.config/ranger/rc.conf >/dev/null <<EOF
set show_hidden true
set draw_borders both
EOF

mkdir -p "${userhome}"/.config/btop
tee "${userhome}"/.config/btop/btop.conf >/dev/null <<EOF
theme_background = False
EOF

mkdir -p "${userhome}"/.config/nvim/lua/plugins
tee "${userhome}"/.config/nvim/init.lua >/dev/null <<EOF
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

function open_telescope()
	vim.cmd("Telescope find_files hidden=true")
end
vim.api.nvim_create_autocmd("VimEnter", {
	callback = open_telescope,
})

require("configs")
require("keymaps")

require("plugins")
require("plugins.borders")
require("plugins.telescope")
require("plugins.lsp")
require("plugins.cmp")
require("plugins.conform")
require("plugins.gitsigns")
require("plugins.nvim-ts")
EOF
tee "${userhome}"/.config/nvim/lua/configs.lua >/dev/null <<EOF
vim.opt.termguicolors = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 10
vim.opt.laststatus = 0

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	update_in_insert = true,
	signs = false,
	underline = false,
})

_G.lsps = {
	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh" },
	},
	zls = {
		cmd = { "zls" },
		filetypes = { "zig" },
	},
	clangd = {
		cmd = { "clangd" },
		filetypes = { "c", "cpp" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		settings = {
			Lua = { diagnostics = { globals = { "vim" } } },
		},
	},
	ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
	tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
	html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
	},
	cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss" },
	},
	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
		filetypes = { "json", "jsonc" },
	},
}
_G.formatters = {
	bash = { "shfmt" },
	c = { "clang-format" },
	cpp = { "clang-format" },
	javascript = { "prettier" },
	typescript = { "prettier" },
	javascriptreact = { "prettier" },
	typescriptreact = { "prettier" },
	html = { "prettier" },
	css = { "prettier" },
	json = { "prettier" },
}
_G.border_style = "single"

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
EOF
tee "${userhome}"/.config/nvim/lua/plugins.lua >/dev/null <<EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"stevearc/conform.nvim",
		opts = {},
	},
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"lewis6991/gitsigns.nvim",
	},
	{
		"akinsho/toggleterm.nvim",
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter",
	},
	{
		"nvim-tree/nvim-web-devicons",
	},
})
EOF
tee "${userhome}"/.config/nvim/lua/keymaps.lua >/dev/null <<EOF
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<A-Right>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<A-Up>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<A-Left>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<A-Down>", "<C-w>j", { noremap = true, silent = true })

vim.keymap.set("n", "<C-Right>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-Left>", ":bprev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":bd<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>h", ":lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dg", ":lua vim.diagnostic.setloclist()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>df", ":lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gh", ":Gitsigns preview_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>f", ":Telescope find_files hidden=true<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tg", ":Telescope git_status<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>", { noremap = true, silent = true })
EOF
tee "${userhome}"/.config/nvim/lua/plugins/borders.lua >/dev/null <<EOF
local ignore_filetypes = {
	TelescopePrompt = true,
	TelescopeResults = true,
}

function set_border()
	local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	local win = vim.api.nvim_get_current_win()
	if not ignore_filetypes[buf_ft] then
		vim.api.nvim_win_set_config(win, { border = _G.border_style })
	end
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = set_border,
})
EOF
tee "${userhome}"/.config/nvim/lua/plugins/conform.lua >/dev/null <<EOF
require("conform").setup({
	formatters_by_ft = _G.formatters,
	format_on_save = {
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	},
})
EOF
tee "${userhome}"/.config/nvim/lua/plugins/cmp.lua >/dev/null <<EOF
local cmp = require("cmp")
cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete({}),
		["<CR>"] = cmp.mapping.confirm({}),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "path" },
	},
	window = {
		completion = cmp.config.window.bordered({ border = _G.border_style }),
		documentation = cmp.config.window.bordered({ border = _G.border_style }),
	},
})
EOF
tee "${userhome}"/.config/nvim/lua/plugins/telescope.lua >/dev/null <<EOF
require("telescope").setup({
	defaults = {
		border = true,
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		file_ignore_patterns = {
			".git/",
			"node_modules/",
		},
	},
})
EOF
tee "${userhome}"/.config/nvim/lua/plugins/gitsigns.lua >/dev/null <<EOF
require("gitsigns").setup({
	preview_config = {
		border = _G.border_style,
	},
})
EOF
tee "${userhome}"/.config/nvim/lua/plugins/lsp.lua >/dev/null <<EOF
vim.lsp.config("*", {
	root_markers = { ".git" },
})

for name, config in pairs(_G.lsps) do
	vim.lsp.config(name, {
		cmd = config.cmd,
		filetypes = config.filetypes,
	})
	vim.lsp.enable(name)
end
EOF
tee "${userhome}"/.config/nvim/lua/plugins/nvim-ts.lua >/dev/null <<EOF
require("nvim-treesitter.configs").setup({
	auto_install = true,
	highlight = {
		enable = true,
	},
})
EOF

mkdir -p "${userhome}"/.var/app/org.libretro.RetroArch/config/retroarch
mkdir -p "${userhome}"/.var/app/org.libretro.RetroArch/config/retroarch/config/LRPS2
mkdir -p "${userhome}"/.var/app/org.libretro.RetroArch/config/retroarch/config/remaps/"FinalBurn Neo"
tee "${userhome}"/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg >/dev/null <<EOF
video_driver = "vulkan"
video_fullscreen = "true"
video_font_enable = "false"
input_driver = "sdl2"
assets_directory = "/app/share/libretro/assets/"
joypad_autoconfig_dir = "/app/share/libretro/autoconfig"
ozone_menu_color_theme = "10"
menu_framebuffer_opacity = "1.000000"
config_save_on_exit = "false"
EOF
tee "${userhome}"/.var/app/org.libretro.RetroArch/config/retroarch/config/LRPS2/LRPS2.opt >/dev/null <<EOF
pcsx2_fastboot = "disabled"
pcsx2_axis_deadzone1 = "25%"
pcsx2_axis_deadzone2 = "25%"
pcsx2_axis_scale1 = "100%"
pcsx2_axis_scale2 = "100%"
pcsx2_button_deadzone1 = "25%"
pcsx2_button_deadzone2 = "25%"
pcsx2_texture_filtering = "Nearest"
pcsx2_trilinear_filtering = "disabled"
pcsx2_anisotropic_filtering = "disabled"
EOF
tee "${userhome}"/.var/app/org.libretro.RetroArch/config/retroarch/config/remaps/"FinalBurn Neo"/"FinalBurn Neo.rmp" >/dev/null <<EOF
input_libretro_device_p1 = "1"
input_libretro_device_p2 = "1"
input_libretro_device_p3 = "1"
input_libretro_device_p4 = "1"
input_libretro_device_p5 = "1"
input_libretro_device_p6 = "1"
input_libretro_device_p7 = "1"
input_libretro_device_p8 = "1"
input_player1_btn_l = "12"
input_player1_btn_l2 = "13"
input_player1_btn_r = "10"
input_player1_btn_r2 = "11"
input_player1_btn_r3 = "2"
input_player1_btn_select = "-1"
EOF
