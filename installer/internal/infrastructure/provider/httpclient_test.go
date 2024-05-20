package provider

import (
	"bytes"
	"errors"
	"io"
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/drew138/.dotfiles/installer/mocks"
)

type mockReader struct{}

func (m *mockReader) Read(p []byte) (n int, err error) {
	return 0, io.ErrUnexpectedEOF
}

func TestRepository_GetRoles(t *testing.T) {

	mockClient := mocks.NewHttpClient(t)
	r := New(mockClient)

	t.Run("should return a list of roles", func(t *testing.T) {
		// Arrange
		response := &http.Response{
			Body: io.NopCloser(
				bytes.NewBufferString(`[{"name": "role1"}, {"name": "role2"}]`),
			),
		}

		mockClient.On("Get", url).Return(response, nil).Once()
		expectedRoles := []string{"role1", "role2"}

		// Act
		roles, err := r.GetRoles()

		// Assert
		assert.NoError(t, err)
		assert.Equal(t, expectedRoles, roles, "they should be equal")
	})

	t.Run("should return a list of roles", func(t *testing.T) {
		// Arrange
		response := &http.Response{
			Body: io.NopCloser(
				bytes.NewBufferString(`}`),
			),
		}

		mockClient.On("Get", url).Return(response, nil).Once()

		// Act
		_, err := r.GetRoles()

		// Assert
		assert.Error(t, err)
	})

	t.Run("should return an error if client fails", func(t *testing.T) {
		// Arrange
		mockClient.On("Get", url).Return(nil, errors.New("client error")).Once()

		// Act
		roles, err := r.GetRoles()

		// Assert
		assert.Error(t, err)
		assert.Nil(t, roles)
	})
}
