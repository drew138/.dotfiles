package prompt

import (
	"log"

	"github.com/charmbracelet/huh"
	"github.com/charmbracelet/huh/spinner"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"

	"github.com/drew138/.dotfiles/installer/internal/application"
)

type repository struct {
	service application.Service
}

func New(service application.Service) *repository {
	return &repository{service: service}
}

func (r *repository) createOptions(roles []string) []huh.Option[string] {
	options := []huh.Option[string]{}
	for _, role := range roles {
		titleCaseRole := cases.Title(language.English, cases.Compact).String(role)
		options = append(options, huh.NewOption(titleCaseRole, role).Selected(true))
	}
	return options
}

func (r *repository) createForm(
	selectedRoles *[]string,
	options []huh.Option[string],
	debug bool,
) *huh.Form {
	return huh.NewForm(
		huh.NewGroup(
			huh.NewMultiSelect[string]().
				Title("Roles").
				Options(options...).
				Value(selectedRoles),

			huh.NewConfirm().
				Title("Run in debug mode?").
				Affirmative("Yes").
				Negative("No").
				Value(&debug),
		),
	)
}

func (r *repository) Run() error {
	roles, err := r.service.GetRoles()

	if err != nil {
		return err
	}

	options := r.createOptions(roles)

	var (
		selectedRoles []string
		debug         bool
	)

	form := r.createForm(&selectedRoles, options, debug)

	form.Run()

	action := func() {
		err := r.service.Pull(selectedRoles, debug)

		if err != nil {
			log.Fatal(err)
		}
	}

	return spinner.New().
		Title("Installing roles, this may take a while...").
		Action(action).
		Run()
}
