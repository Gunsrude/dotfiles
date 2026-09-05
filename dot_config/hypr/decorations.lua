hl.config({
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.95,
        fullscreen_opacity = 1.0,
        dim_inactive = false,
        dim_strength = 0.05,
        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            vibrancy = 0.1696,
            noise = 0.0117,
            contrast = 0.8916,
            brightness = 0.8172,
            popups = true,
        },
    },
})

hl.layer_rule({ name = "waybar-blur", match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ name = "rofi-blur", match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ name = "notifications-blur", match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ name = "waybar-ignore-alpha", match = { namespace = "waybar" }, ignore_alpha = 0.0 })
