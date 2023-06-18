# Neovim: Testing cmp for color with Tailwind

- [ ] It should detect a project uses tailwind, maybe via some kind of config file 
(`tailwind.config.{cjs,mjs,js,ts,json,tsx,toml,yaml}`), or just based on the 
string content or via tree-stiter. Check this by `:LspInfo` and `tailwindcss-lsp`
should attach to the current buffer that has tailwind-css string
- [ ] Type in a classname `text-red-500`, just stop at somewhere and start
browsing the cmp-lsp window. It should show a color in place of `lspkind`.
This validates `tailwindcss-colorizer-cmp.nvim` is good
- [ ] Hit that autocomplete, the string should show the color red. This validates
`nvim-colorizer.lua` is properly setup.

