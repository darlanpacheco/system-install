#!/usr/bin/env bash

name=$(cat /softwares/name)
email=$(cat /softwares/email)
userhome="/home/$(whoami)"
config="${userhome}"/.config
var="${userhome}"/.var
font="JetBrains Mono"

tee "${userhome}"/.bashrc >/dev/null <<EOF
alias c="clear"
alias e="exit"
alias q="exit"

alias rm="trash"
alias dl="rm"
alias ls="ls --color"

alias update="sudo pacman -Syu && flatpak update -y && nix-channel --update && nix-env -u '*'"

alias gts="git status"
alias gta="git add"
alias gtc="git commit"
alias gtp="git push"
alias gtl="git log"

terminal() {
    local count="\${1:-1}"
    for ((i=0; i<count; i++)); do
        alacritty --working-directory "\${PWD}" &
    done
}
run() {
    nohup "\${@}" >/dev/null 2>&1 &
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

mkdir -p "${config}"
tee "${config}"/mimeapps.list >/dev/null <<EOF
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

mkdir -p "${config}"/gtk-3.0
tee "${config}"/gtk-3.0/settings.ini >/dev/null <<EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-font-name=${font} 12
gtk-icon-theme-name=Papirus
gtk-theme-name=adw-gtk3-dark
EOF
mkdir -p "${config}"/gtk-4.0
tee "${config}"/gtk-4.0/settings.ini >/dev/null <<EOF
[Settings]
gtk-application-prefer-dark-theme=true
gtk-font-name=${font}, 12
gtk-icon-theme-name=Papirus
gtk-theme-name=adw-gtk3-dark
EOF

mkdir -p "${config}"/hypr
tee "${config}"/hypr/hyprland.lua >/dev/null <<EOF
hl.on("hyprland.start", function()
	hl.exec_cmd("gammastep -O 2560k")
	hl.exec_cmd("alacritty --class dbar -e dbar")
	hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
	hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"')
	hl.exec_cmd('gsettings set org.gnome.desktop.interface font-name "JetBrains Mono 12"')
	hl.exec_cmd('gsettings set org.gnome.desktop.interface icon-theme "Papirus"')
end)

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})
hl.workspace_rule({
	workspace = "1",
	default = true,
	gaps_out = { top = 32, right = 8, bottom = 8, left = 8 },
})
hl.window_rule({
	name = "dbar-dmenu-float",
	match = { initial_class = "^(dbar|dmenu)$" },
	float = true,
})
hl.window_rule({
	name = "dbar",
	match = { initial_class = "^dbar$" },
	no_initial_focus = true,
	size = { "monitor_w", 24 },
	move = { 0, 0 },
	rounding = 0,
})
hl.window_rule({
	name = "dmenu",
	match = { initial_class = "^dmenu$" },
	size = { 512, 320 },
})

hl.bind("SUPER + K", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +8%"))
hl.bind("SUPER + J", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -8%"))

hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))

hl.bind("SUPER + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("alacritty --class dmenu -e dmenu"))
hl.bind("SUPER + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + Q", hl.dsp.window.close())

hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 64, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -64, relative = true }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -64, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 64, relative = true }))

hl.bind("SUPER + ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })

for _, d in ipairs({ "right", "up", "left", "down" }) do
	hl.bind("SUPER + " .. d, hl.dsp.focus({ direction = d }))
	hl.bind("SUPER + ALT + " .. d, hl.dsp.window.move({ direction = d }))
end

for i = 1, 4 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind("ALT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.config({
	input = {
		kb_layout = "br",
		sensitivity = -0.2,
		accel_profile = "flat",
	},

	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 0,
	},

	decoration = {
		active_opacity = 0.96,
		inactive_opacity = 0.96,
		fullscreen_opacity = 1,
		rounding = 8,

		shadow = { enabled = false },
		blur = { enabled = true },
	},

	animations = {
		enabled = false,
	},

	misc = {
		force_default_wallpaper = 2,
		enable_anr_dialog = false,
		disable_splash_rendering = true,
		-- disable_hyprland_logo = true,
		-- background_color      = 0x0f0f0f,
	},

	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
})
EOF

mkdir -p "${config}"/alacritty
tee "${config}"/alacritty/alacritty.toml >/dev/null <<EOF
[colors.primary]
background = "#0f0f0f"

[font]
size = 14
[font.normal]
family = "${font}"
style = "Regular"
[font.bold]
family = "${font}"
style = "Bold"
[font.bold_italic]
family = "${font}"
style = "Bold Italic"
[font.italic]
family = "${font}"
style = "Italic"
EOF

tee "${userhome}"/.gitconfig >/dev/null <<EOF
[user]
  name = ${name}
  email = ${email}
EOF

mkdir -p "${config}"/nvim/lua/plugins
tee "${config}"/nvim/init.lua >/dev/null <<EOF
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local function open_telescope()
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
require("plugins.lsps")
require("plugins.formatters")
require("plugins.gitsigns")
EOF
tee "${config}"/nvim/lua/configs.lua >/dev/null <<EOF
vim.opt.termguicolors = true

vim.opt.tabstop = 8
vim.opt.softtabstop = 8
vim.opt.shiftwidth = 8
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.laststatus = 0

vim.diagnostic.config({
	virtual_text = true,
	virtual_lines = false,
	update_in_insert = true,
	signs = false,
	underline = false,
})

_G.lsps = {
	c = { "clangd" },
	cpp = { "clangd" },
	zig = { "zls" },
	sh = { "bash-language-server", "start" },
	lua = { "lua-language-server" },
	html = { "vscode-html-language-server", "--stdio" },
	css = { "vscode-css-language-server", "--stdio" },
	js = { "typescript-language-server", "--stdio" },
	ts = { "typescript-language-server", "--stdio" },
	jsx = { "typescript-language-server", "--stdio" },
	tsx = { "typescript-language-server", "--stdio" },
	json = { "vscode-json-language-server", "--stdio" },
}
_G.formatters = {
	c = "clang-format",
	cpp = "clang-format",
	zig = "zig fmt --stdin",
	sh = "shfmt",
	py = "black --quiet -",
	lua = "stylua -",
	html = "prettier --stdin-filepath %:p",
	css = "prettier --stdin-filepath %:p",
	js = "prettier --stdin-filepath %:p",
	ts = "prettier --stdin-filepath %:p",
	jsx = "prettier --stdin-filepath %:p",
	tsx = "prettier --stdin-filepath %:p",
	json = "prettier --stdin-filepath %:p",
	vs = "clang-format",
	fs = "clang-format",
}
_G.border_style = "single"

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
EOF
tee "${config}"/nvim/lua/plugins.lua >/dev/null <<EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
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
})
EOF
tee "${config}"/nvim/lua/keymaps.lua >/dev/null <<EOF
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
EOF
tee "${config}"/nvim/lua/plugins/borders.lua >/dev/null <<EOF
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
tee "${config}"/nvim/lua/plugins/telescope.lua >/dev/null <<EOF
require("telescope").setup({
	defaults = {
		border = true,
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		file_ignore_patterns = {
			"%.git",
			"node_modules",
			"zig%-out",
			"%.zig%-cache",
		},
	},
})
EOF
tee "${config}"/nvim/lua/plugins/gitsigns.lua >/dev/null <<EOF
require("gitsigns").setup({
	preview_config = {
		border = _G.border_style,
	},
})
EOF
tee "${config}"/nvim/lua/plugins/lsps.lua >/dev/null <<EOF
vim.lsp.config("*", {
	root_markers = { ".git" },
})

for key, definition in pairs(_G.lsps) do
	local server_instance_name = "lsp_server_" .. key
	local executable_command = {}

	if type(definition) == "table" then
		for _, argument in ipairs(definition) do
			if type(argument) == "string" then
				table.insert(executable_command, argument)
			end
		end
	else
		executable_command = { definition }
	end

	local target_filetypes = (type(definition) == "table" and definition.filetypes) or { key }

	vim.lsp.config(server_instance_name, {
		cmd = executable_command,
		filetypes = target_filetypes,
		settings = definition.settings or {},
	})

	vim.lsp.enable(server_instance_name)
end
EOF
tee "${config}"/nvim/lua/plugins/formatters.lua >/dev/null <<EOF
local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = format_group,
	callback = function()
		local filename = vim.fn.expand("%:t")
		local ext = vim.fn.expand("%:e")
		local filetype = vim.bo.filetype

		local formatter = _G.formatters[filename] or _G.formatters[ext] or _G.formatters[filetype]
		if formatter == nil then
			return
		end

		local view = vim.fn.winsaveview()
		local filepath = vim.fn.expand("%:p")
		local cmd = formatter:gsub("%%:p", filepath)

		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local input_text = table.concat(lines, "\n")
		local output = vim.fn.system(cmd, input_text)

		if vim.v.shell_error == 0 and output ~= "" then
			local new_lines = vim.split(output, "\n")

			if new_lines[#new_lines] == "" then
				table.remove(new_lines)
			end

			vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
		end

		vim.fn.winrestview(view)
	end,
})
EOF

mkdir -p "${var}"/app/org.libretro.RetroArch/config/retroarch
mkdir -p "${var}"/app/org.libretro.RetroArch/config/retroarch/config/LRPS2
mkdir -p "${var}"/app/org.libretro.RetroArch/config/retroarch/config/remaps/"FinalBurn Neo"
tee "${var}"/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg >/dev/null <<EOF
video_driver = "vulkan"
video_fullscreen = "true"
video_font_enable = "false"
input_driver = "sdl2"
audio_driver = "sdl2"
assets_directory = "/app/share/libretro/assets/"
joypad_autoconfig_dir = "/app/share/libretro/autoconfig"
config_save_on_exit = "false"
EOF
tee "${var}"/app/org.libretro.RetroArch/config/retroarch/config/LRPS2/LRPS2.opt >/dev/null <<EOF
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
tee "${var}"/app/org.libretro.RetroArch/config/retroarch/config/remaps/"FinalBurn Neo"/"FinalBurn Neo.rmp" >/dev/null <<EOF
input_player1_btn_l = "12"
input_player1_btn_l2 = "13"
input_player1_btn_r = "10"
input_player1_btn_r2 = "11"
input_player1_btn_r3 = "2"
input_player1_btn_select = "-1"
input_player2_btn_l = "12"
input_player2_btn_l2 = "13"
input_player2_btn_r = "10"
input_player2_btn_r2 = "11"
input_player2_btn_r3 = "2"
input_player2_btn_select = "-1"
EOF
mkdir -p "${var}"/app/org.libretro.RetroArch/config/retroarch/config/Eden
tee "${var}"/app/org.libretro.RetroArch/config/retroarch/config/Eden/Eden.opt >/dev/null <<EOF
eden_renderer = "Vulkan"
eden_gpu_accuracy = "Accurate"
eden_resolution = "1x"
eden_scaling_filter = "FSR"
eden_fsr_sharpening = "0%"
eden_anti_aliasing = "None"
EOF

mkdir -p "${config}"/MangoHud
tee "${config}"/MangoHud/MangoHud.conf >/dev/null <<EOF
toggle_hud=F12

fps=1
cpu_temp=1
gpu_temp=1
ram
vram
EOF
