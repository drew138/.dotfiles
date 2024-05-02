package ansible

import (
	"encoding/json"
	"os"
	"os/exec"
)

const repository = "https://github.com/Drew138/.dotfiles.git"

func AnsiblePull(roles []string, debug bool) error {

	data := map[string]interface{}{
		"selected_roles": roles,
		"selected_hosts": "localhost",
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	cmd := exec.Command(
		"ansible-pull",
		"-U",
		repository,
		"local.yml",
		"--extra-vars",
		string(jsonData),
	)

	if debug {
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	err = cmd.Run()
	if err != nil {
		return err
	}

	return nil
}
