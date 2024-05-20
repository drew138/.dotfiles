package application

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/drew138/.dotfiles/installer/mocks"
)

func TestService_GetRoles(t *testing.T) {

	mockProvider := mocks.NewProvider(t)
	mockProvisioner := mocks.NewProvisioner(t)

	s := New(mockProvider, mockProvisioner)

	t.Run("should return a list of roles", func(t *testing.T) {
		// Arrange
		mockProvider.On("GetRoles").Return([]string{"role1", "role2"}, nil).Once()
		expectedRoles := []string{"role1", "role2"}

		// Act
		roles, err := s.GetRoles()

		// Assert
		assert.NoError(t, err)
		assert.Equal(t, expectedRoles, roles, "they should be equal")
	})

	t.Run("should return an error if provider fails", func(t *testing.T) {
		// Arrange
		mockProvider.On("GetRoles").Return(nil, errors.New("provider error")).Once()

		// Act
		roles, err := s.GetRoles()

		// Assert
		assert.Error(t, err)
		assert.Nil(t, roles)
	})

}

func TestService_Pull(t *testing.T) {
	mockProvider := mocks.NewProvider(t)
	mockProvisioner := mocks.NewProvisioner(t)

	s := New(mockProvider, mockProvisioner)

	t.Run("should pull the roles", func(t *testing.T) {
		// Arrange
		mockProvisioner.On("Pull", []string{"role1", "role2"}, false).Return(nil).Once()

		// Act
		err := s.Pull([]string{"role1", "role2"}, false)

		// Assert
		assert.NoError(t, err)
	})

	t.Run("should return an error if provisioner fails", func(t *testing.T) {
		// Arrange
		mockProvisioner.On("Pull", []string{"role1", "role2"}, false).
			Return(errors.New("provisioner error")).
			Once()

		// Act
		err := s.Pull([]string{"role1", "role2"}, false)

		// Assert
		assert.Error(t, err)
	})
}
