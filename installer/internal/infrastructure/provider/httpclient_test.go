package provider

import (
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/drew138/.dotfiles/mocks"
)

const (
	mockUrl = "https://api.github.com/repos/user/repo/contents/directory"
)

var (
	mockResponse = []byte(`
        [
          {
            "name": "appearance"
          },
          {
            "name": "casks"
          },
          {
            "name": "cli"
          }
        ]
    `)
)

func TestRoles_getDirectoryNamesBody(t *testing.T) {
	mockClient := mocks.NewHttpClient(t)
	roles := New(mockClient)

	t.Run("should ", func(t *testing.T) {
		// Arrange
		mockClient.On("Get", mockUrl).Return(mockResponse, nil).Once()
		expectedBody := mockResponse

		// Act
		body, err := roles.getDirectoryNamesBody()

		// Assert
		assert.NoError(t, err)
		assert.Equal(t, expectedBody, body, "they should be equal")
	})
}
