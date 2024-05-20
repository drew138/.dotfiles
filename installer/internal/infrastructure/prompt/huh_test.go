package prompt

import (
	"testing"

	"github.com/charmbracelet/huh"
	"github.com/stretchr/testify/assert"

	"github.com/drew138/.dotfiles/installer/mocks"
)

func TestRepository_createOptions(t *testing.T) {

	mockService := mocks.NewService(t)
	r := New(mockService)

	t.Run("should return a list of options", func(t *testing.T) {
		// Arrange
		expectedOptions := []huh.Option[string]{
			huh.NewOption("Role1", "role1").Selected(true),
			huh.NewOption("Role2", "role2").Selected(true),
		}

		// Act
		options := r.createOptions([]string{"role1", "role2"})

		// Assert
		assert.Equal(t, expectedOptions, options, "they should be equal")

	})

}

func TestRepository_createForm(t *testing.T) {

	mockService := mocks.NewService(t)
	r := New(mockService)

	t.Run("should return a form", func(t *testing.T) {
		// Arrange
		selectedRoles := []string{"role1", "role2"}
		options := []huh.Option[string]{
			huh.NewOption("Role1", "role1").Selected(true),
			huh.NewOption("Role2", "role2").Selected(true),
		}
		debug := false

		// Act
		form := r.createForm(&selectedRoles, options, debug)

		// Assert
		assert.NotNil(t, form)
	})
}
