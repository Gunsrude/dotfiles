-- Window Rules
-- Original: rules.conf

-- Behavior Rules
hl.window_rule({ match = { class = "^(.*Vivaldi.*)$" }, tile = true })
hl.window_rule({ match = { class = "^(.*pavucontrol.*)$" }, float = true })
hl.window_rule({ match = { class = "^(.*nm-connection-editor.*)$" }, float = true })
hl.window_rule({ match = { class = "^(.*vlc.*)$" }, no_anim = true })
hl.window_rule({ match = { class = "^(.*smplayer.*)$" }, no_anim = true })
hl.window_rule({ match = { class = "^(.*python3.*)$" }, float = true })

-- Dialog Sizing Rules
hl.window_rule({ match = { class = "^(.*yad.*)$" }, float = true })
hl.window_rule({ match = { class = "^(.*yad.*)$" }, move = { "2%", "2%" } })
hl.window_rule({ match = { class = "^(.*yad.*)$" }, size = { "96%", "96%" } })
hl.window_rule({ match = { class = "^(.*steam_app_489830.*)$" }, float = true })
hl.window_rule({ match = { class = "^(.*steam_app_489830.*)$" }, move = { "2%", "2%" } })
hl.window_rule({ match = { class = "^(.*steam_app_489830.*)$" }, size = { "96%", "96%" } })

-- Workspace Assignment — Terminal
hl.window_rule({ match = { class = "^(.*terminator.*)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(.*alacritty.*)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(.*kitty.*)$" }, workspace = "1" })

-- Workspace Assignment — Browsers
hl.window_rule({ match = { class = "^(.*[Vv]ivaldi.*)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(.*[Ff]irefox.*)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(.*[Ll]ibrewolf.*)$" }, workspace = "2" })

-- Workspace Assignment — Editors
hl.window_rule({ match = { class = "^(.*subl.*)$" }, workspace = "3" })
hl.window_rule({ match = { class = "^(.*[Vv][Ss][Cc]odium.*)$" }, workspace = "3" })

-- Workspace Assignment — File Manager
hl.window_rule({ match = { class = "^(.*thunar.*)$" }, workspace = "4" })

-- Workspace Assignment — Comms
hl.window_rule({ match = { class = "^(.*Signal.*)$" }, workspace = "5" })
hl.window_rule({ match = { class = "^(.*[Dd]iscord.*)$" }, workspace = "5" })
hl.window_rule({ match = { class = "^(.*Microsoft Teams.*)$" }, workspace = "5" })
hl.window_rule({ match = { class = "^(.*thunderbird.*)$" }, workspace = "6" })

-- Workspace Assignment — Media
hl.window_rule({ match = { class = "^(.*vlc.*)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(.*smplayer.*)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(.*FreeTube.*)$" }, workspace = "7" })

-- Workspace Assignment — Gaming
hl.window_rule({ match = { class = "^(.*[Ss]team.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*[Hh]eroic.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*yad.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*gdlauncher.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*polymc.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*org.multimc.MultiMC.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*org.prismlauncher.PrismLauncher.*)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(.*factorio.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*Better MC.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*Minecraft.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*FTB Skies.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*UniversIO.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*Stone Technology.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*Enigmatica.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*SteamPunk.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*Another Quality.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*steam_app_.*)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(.*erraria.*)$" }, workspace = "9" })

-- Workspace Assignment — Misc
hl.window_rule({ match = { class = "^(.*[Vv]irtual[Bb]ox.*)$" }, workspace = "10" })
hl.window_rule({ match = { class = "^(com\\.obsproject\\.Studio)$" }, workspace = "11" })
hl.window_rule({ match = { class = "^(.*sublime_merge.*)$" }, workspace = "12" })
hl.window_rule({ match = { class = "^(.*q[Bb]ittorrent.*)$" }, workspace = "13" })

-- Title-Based Float Rules
hl.window_rule({ match = { title = "^(Open)$" }, float = true })
hl.window_rule({ match = { title = "^(Choose Files)$" }, float = true })
hl.window_rule({ match = { title = "^(Save As)$" }, float = true })
hl.window_rule({ match = { title = "^(Confirm to replace files)$" }, float = true })
hl.window_rule({ match = { title = "^(File Operation Progress)$" }, float = true })

-- Workspace Rule
hl.workspace_rule({ workspace = "special:magic", gaps_out = 50, gaps_in = 20 })
