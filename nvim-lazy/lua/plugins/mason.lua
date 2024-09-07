return {
    {
        "williamboman/mason.nvim",
        config = function()
						require("mason").setup()
				end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
						require("mason-lspconfig").setup()
				end
    },
		{
				"neovim/nvim-lspconfig",
				config = function()
						local lspconfig = require("lspconfig")

						-- Settings of LSP server by Mason-LSPconfig
						local servers = { "ts_ls", "lua_ls" }

						for _, lsp in ipairs(servers) do
								lspconfig[lsp].setup {}
						end
				end
		}
}
