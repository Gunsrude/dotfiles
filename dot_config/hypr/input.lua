-- Input Configuration
-- Original: input.conf

hl.config({
    input = {
        follow_mouse = 1,
        mouse_refocus = false,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            tap_to_click = true,
        },
    },
})

-- cursor is a top-level section, sibling of input (not nested under it)
hl.config({
    cursor = {
        no_hardware_cursors = false,
        enable_hyprcursor = true,
    },
})

-- gestures {
--     workspace_swipe = true
--     workspace_swipe_fingers = 3
-- }
