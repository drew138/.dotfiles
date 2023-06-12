local ignore_patterns = {
    "node_modules/.*",
    ".git/*",
    ".cache",
    "%.o",
    "%.a",
    "%.out",
    "%.class",
    "%.pdf",
    "%.mkv",
    "%.mp4",
    "%.zip",
}

local picker_config = {
    previewer = false,
    hidden = true,
    file_ignore_patterns = ignore_patterns,
}

local Opts = {
    pickers = {
        find_files = picker_config,
        live_grep = picker_config,
        buffers = picker_config,
        diagnostics = picker_config,
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
}

return Opts
