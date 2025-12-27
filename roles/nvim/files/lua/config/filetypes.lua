local M = {}

function M.setup_filetypes()
	vim.filetype.add({
		filename = {
			[".yamllint"] = "yaml",
			sketchybarrc = "bash",
			bordersrc = "bash",
			["local.yml"] = "ansible",
		},
		extension = {
			gitconfig = "gitconfig",
		},
		pattern = {
			["[Dd]ockerfile.*"] = "dockerfile",
			["[Dd]ocker%-compose.*%.ya?ml"] = "yaml.docker-compose",
			[".gitignore.*"] = "gitignore",
			[".*/tasks/.*%.yml"] = "yaml.ansible",
			[".*/roles/.*%.yml"] = "yaml.ansible",
			["playbook%.yml"] = "yaml.ansible",
			["local.yml"] = "yaml.ansible",
			["site%.yml"] = "yaml.ansible",
			[".*/.github/workflows/.*%.ya?ml"] = "yaml.github-actions",
		},
	})
end

function M.setup()
	M.setup_filetypes()
end

M.setup()
