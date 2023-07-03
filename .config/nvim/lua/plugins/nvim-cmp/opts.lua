local lspkind = require("lspkind")
local cmp = require("cmp")

local Opts = {
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		-- ["<c-b>"] = cmp.mapping.scroll_docs(-4),
		-- ["<c-f>"] = cmp.mapping.scroll_docs(4),
		-- ["<c-Space>"] = cmp.mapping.complete(),
		["<c-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		["<c-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<c-x>"] = cmp.mapping.abort(),
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "luasnip" },
		{ name = "nvim_lsp", keyword_length = 3 },
		{ name = "nvim_lua", keyword_length = 3 },
		{ name = "buffer", keyword_length = 3 },
		{ name = "path", keyword_length = 3 },
	}),
	formatting = {
		format = lspkind.cmp_format({
			with_text = true,
			menu = {
				buffer = "[buf]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[api]",
				path = "[path]",
				luasnip = "[snip]",
			},
		}),
	},
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
}

return Opts
