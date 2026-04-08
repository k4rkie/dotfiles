return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function ()
            require ( "nvim-treesitter.config" ).setup({
                ensure_installed = { "typescript", "javascriptreact", "javascript", "jsx", "tsx"},
                highlight = { enable = true, additional_vim_regex_highlighting = false },
            })
        end
    }
}
