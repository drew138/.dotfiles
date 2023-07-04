local Opts = {
    on_attach = function(bufnr)
        -- KEYS NEED TO BE SET HERE
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", ")", function()
            if vim.wo.diff then
                return ")"
            end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return "<Ignore>"
        end, { expr = true })

        map("n", "(", function()
            if vim.wo.diff then
                return "("
            end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return "<Ignore>"
        end, { expr = true })

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk)
        map("n", "<leader>hr", gs.reset_hunk)
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hp", gs.preview_hunk)
        map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
        end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function()
            gs.diffthis("~")
        end)
        map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>")
    end,
}

return Opts
