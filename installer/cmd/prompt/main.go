package main

import (
	"fmt"
	"net/http"
	"os/exec"

	"github.com/drew138/.dotfiles/installer/internal/application"
	"github.com/drew138/.dotfiles/installer/internal/infrastructure/prompt"
	"github.com/drew138/.dotfiles/installer/internal/infrastructure/provider"
	"github.com/drew138/.dotfiles/installer/internal/infrastructure/provisioner"
)

func main() {
	provider := provider.New(http.DefaultClient)

	provisioner := provisioner.New(exec.Command)

	service := application.New(provider, provisioner)

	prompt := prompt.New(service)

	if err := prompt.Run(); err != nil {
		panic(err)
	}

	fmt.Println("Installation complete!")
}
