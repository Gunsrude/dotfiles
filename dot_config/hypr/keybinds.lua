-- Hyprland keybinds (Lua)
-- Generated from keybinds.conf

local mainMod = "SUPER"

-- Brightness keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 10%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))

-- Core keybinds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Escape", hl.dsp.window.close()) -- VERIFY: hl.dsp.window.close for killactive
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit()) -- VERIFY: hl.dsp.exit for exit
hl.bind(mainMod .. " + F", hl.dsp.fullscreen()) -- VERIFY: hl.dsp.fullscreen for fullscreen
hl.bind(mainMod .. " + Space", hl.dsp.togglefloating()) -- VERIFY: hl.dsp.togglefloating for togglefloating
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun -modi window"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("rofi -show window -modi window"))
hl.bind(mainMod .. " + B", hl.dsp.pseudo()) -- VERIFY: hl.dsp.pseudo for pseudo
hl.bind("ALT + J", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg togglesplit"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("grimblast save area ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"))

-- Gamemode toggle
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("~/.config/hypr/gamemode.sh"))

-- Lock
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Special workspace
hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.workspace.move_to("special:magic")) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace

-- Group keybinds
hl.bind(mainMod .. " + G", hl.dsp.group.toggle()) -- VERIFY: hl.dsp.group.toggle for togglegroup
hl.bind(mainMod .. " + Tab", hl.dsp.group.next()) -- VERIFY: hl.dsp.group.next for changegroupactive forward
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev()) -- VERIFY: hl.dsp.group.prev for changegroupactive backward

-- Focus navigation (HJKL)
hl.bind(mainMod .. " + H", hl.dsp.focus.move("l")) -- VERIFY: hl.dsp.focus.move for movefocus
hl.bind(mainMod .. " + L", hl.dsp.focus.move("r")) -- VERIFY: hl.dsp.focus.move for movefocus
hl.bind(mainMod .. " + K", hl.dsp.focus.move("u")) -- VERIFY: hl.dsp.focus.move for movefocus
hl.bind(mainMod .. " + J", hl.dsp.focus.move("d")) -- VERIFY: hl.dsp.focus.move for movefocus

-- Move window (SHIFT+HJKL)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move("l")) -- VERIFY: hl.dsp.window.move for movewindow
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move("r")) -- VERIFY: hl.dsp.window.move for movewindow
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move("u")) -- VERIFY: hl.dsp.window.move for movewindow
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move("d")) -- VERIFY: hl.dsp.window.move for movewindow

-- Workspace switch 1-10
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.workspace(i)) -- VERIFY: hl.dsp.workspace for workspace
end
hl.bind(mainMod .. " + 0", hl.dsp.workspace(10)) -- VERIFY: hl.dsp.workspace for workspace

-- Workspace switch 21-30 (ALT secondary)
for i = 1, 9 do
    hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.workspace(20 + i)) -- VERIFY: hl.dsp.workspace for workspace
end
hl.bind(mainMod .. " + ALT + 0", hl.dsp.workspace(30)) -- VERIFY: hl.dsp.workspace for workspace

-- Move to workspace (SHIFT+number)
for i = 1, 9 do
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.workspace.move_to(i)) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace
end
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.workspace.move_to(10)) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace

-- Move to workspace secondary (ALT+SHIFT+number)
for i = 1, 9 do
    hl.bind(mainMod .. " + ALT + SHIFT + " .. i, hl.dsp.workspace.move_to(20 + i)) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace
end
hl.bind(mainMod .. " + ALT + SHIFT + 0", hl.dsp.workspace.move_to(30)) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace

-- Move workspace to monitor (CTRL+1-4)
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.workspace.move_to_monitor(0)) -- VERIFY: hl.dsp.workspace.move_to_monitor for movecurrentworkspacetomonitor
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.workspace.move_to_monitor(1)) -- VERIFY: hl.dsp.workspace.move_to_monitor for movecurrentworkspacetomonitor
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.workspace.move_to_monitor(2)) -- VERIFY: hl.dsp.workspace.move_to_monitor for movecurrentworkspacetomonitor
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.workspace.move_to_monitor(3)) -- VERIFY: hl.dsp.workspace.move_to_monitor for movecurrentworkspacetomonitor

-- Window cycling (ALT+Tab)
hl.bind("ALT + Tab", hl.dsp.window.cycle_next()) -- VERIFY: hl.dsp.window.cycle_next for cyclenext
hl.bind("SHIFT + ALT + Tab", hl.dsp.window.cycle_prev()) -- VERIFY: hl.dsp.window.cycle_prev for cyclenext prev

-- Move window to adjacent workspace
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.workspace.move_to("e-1")) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.workspace.move_to("e+1")) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.workspace.move_to("e-1")) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace
hl.bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.workspace.move_to("e+1")) -- VERIFY: hl.dsp.workspace.move_to for movetoworkspace

-- Workspace navigation (mouse scroll + Tab)
hl.bind(mainMod .. " + mouse_down", hl.dsp.workspace("e+1")) -- VERIFY: hl.dsp.workspace for workspace
hl.bind(mainMod .. " + mouse_up", hl.dsp.workspace("e-1")) -- VERIFY: hl.dsp.workspace for workspace
hl.bind(mainMod .. " + Tab", hl.dsp.workspace("e+1")) -- VERIFY: hl.dsp.workspace for workspace (note: conflicts with group.next on same key)
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.workspace("e-1")) -- VERIFY: hl.dsp.workspace for workspace (note: conflicts with group.prev on same key)

-- Mouse binds (drag/resize)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.move(), { mouse = true }) -- VERIFY: hl.dsp.window.move for movewindow; mouse:272 format needs confirmation
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- VERIFY: hl.dsp.window.resize for resizewindow; mouse:273 format needs confirmation

-- Media keys
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
-- binde = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
-- binde = , XF86MonBrightnessDown, exec, brightnessctl s 10%-
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))

-- Commented resize submap
-- bind = $mainMod SHIFT, R, submap, resize
-- submap = resize
-- binde = , L, resizeactive, 40 0
-- binde = , H, resizeactive, -40 0
-- binde = , K, resizeactive, 0 -40
-- binde = , J, resizeactive, 0 40
-- bind = , escape, submap, reset
-- bind = , Return, submap, reset
-- submap = reset

-- OBS sendshortcut
hl.bind("CTRL + Insert", hl.dsp.send_shortcut("", "F10", "class:^(com\\.obsproject\\.Studio)$")) -- VERIFY: hl.dsp.send_shortcut for sendshortcut
