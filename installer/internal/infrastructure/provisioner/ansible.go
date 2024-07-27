package provisioner

import (
	"encoding/json"
	"os"
	"os/exec"

	"github.com/drew138/.dotfiles/installer/internal/application"
)

const url = "https://github.com/Drew138/.dotfiles.git"

type Command = func(name string, arg ...string) *exec.Cmd

type repository struct {
	application.Provider
	command Command
}

func New(command Command) *repository {
	return &repository{command: command}
}

func (r *repository) Pull(roles []string, debug bool) error {

	data := map[string]interface{}{
		"selected_roles": roles,
		"selected_hosts": "localhost",
	}

	jsonData, err := json.Marshal(data)

	if err != nil {
		return err
	}

	cmd := r.command(
		"ansible-pull",
		"-U",
		url,
		"--vault-password-file",
		"$ANSIBLE_VAULT_PASSWORD_FILE",
		"local.yml",
		"--extra-vars",
		string(jsonData),
	)

	if debug {
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	return cmd.Run()
}
