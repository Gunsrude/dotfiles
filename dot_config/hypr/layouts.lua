hl.config({
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },
    master = {
        new_status = "master",
        mfact = 0.5,
        orientation = "left",
    },
    group = {
        col = {
            border_active = "rgb(ff9d00)",
            border_inactive = "rgba(595959aa)",
        },
        groupbar = {
            font_size = 10,
            gradients = true,
            render_titles = true,
            scrolling = true,
        },
    },
})
