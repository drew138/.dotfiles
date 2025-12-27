return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=never",
		"--query-driver=/usr/bin/clang++,/usr/local/bin/*",
	},
}
