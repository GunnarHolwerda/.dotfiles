return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "mason-org/mason.nvim", opts = {} },
        "mason-org/mason-lspconfig.nvim",
        "saghen/blink.cmp",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("fidget").setup({})

        vim.lsp.config("*", {
            capabilities = require("blink.cmp").get_lsp_capabilities(),
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    },
                },
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "vtsls",
            },
        })

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
                local opts = { buffer = ev.buf }

                -- Navigation
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'grr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'gri', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)

                -- Documentation
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

                -- Refactoring
                vim.keymap.set('n', 'cd', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)

                -- Diagnostics
                vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, opts)
                vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, opts)
                vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
            end,
        })

        vim.diagnostic.config({
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true,
                header = "",
                prefix = "",
            },
        })
    end
}
