package prompt

import (
	"fmt"
	"log"

	"github.com/charmbracelet/huh"
	"github.com/charmbracelet/huh/spinner"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

type Prompt struct {
	selectedRoles *[]string
	debug         *bool
	form          *huh.Form
}

func createOptions(roles []string) []huh.Option[string] {
	options := []huh.Option[string]{}
	for _, role := range roles {
		titleCaseRole := cases.Title(language.English, cases.Compact).String(role)
		options = append(options, huh.NewOption(titleCaseRole, role).Selected(true))
	}
	return options
}

func New(roles []string) *Prompt {
	selectedRoles := []string{}
	debug := false

	form := huh.NewForm(
		huh.NewGroup(
			huh.NewMultiSelect[string]().
				Title("Roles").
				Options(
					createOptions(roles)...,
				).
				Value(&selectedRoles),

			huh.NewConfirm().
				Title("Run in debug mode?").
				Affirmative("Yes").
				Negative("No").
				Value(&debug),
		),
	)
	return &Prompt{selectedRoles: &selectedRoles, form: form, debug: &debug}
}

func (p *Prompt) Run(installRoles func([]string, bool) error) error {

	p.form.Run()

	action := func() {
		err := installRoles(*p.selectedRoles, *p.debug)
		if err != nil {
			log.Fatal(err)
		}
	}

	err := spinner.New().Title("Installing roles, this may take a while...").Action(action).Run()
	if err != nil {
		return err
	}
	fmt.Println("Installation complete!")
	return nil
}
