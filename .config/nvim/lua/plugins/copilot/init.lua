local Plugin = {
    "github/copilot.vim",
    dependencies = { { "EdenEast/nightfox.nvim" } },
    init = function()
        vim.g.copilot_no_tab_map = true
        -- DO NOT USE vim.keymap.set
        local set = vim.api.nvim_set_keymap
        set("i", "<leader><Tab>", 'copilot#Accept("")', { silent = true, expr = true })
    end,
}

return Plugin
