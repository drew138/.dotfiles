package main

import (
	"net/http"

	"github.com/drew138/.dotfiles/internal/ansible"
	"github.com/drew138/.dotfiles/internal/prompt"
	"github.com/drew138/.dotfiles/internal/roles"
)

func main() {
	roles := roles.New(http.DefaultClient)

	availableRoles, err := roles.GetRoles()
	if err != nil {
		panic(err)
	}

	prompt := prompt.New(availableRoles)

	err = prompt.Run(ansible.AnsiblePull)
	if err != nil {
		panic(err)
	}
}
