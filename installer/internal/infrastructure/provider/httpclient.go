package provider

import (
	"encoding/json"
	"io"
	"net/http"

	"github.com/drew138/.dotfiles/installer/internal/application"
)

const url = "https://api.github.com/repos/drew138/.dotfiles/contents/roles"

type repository struct {
	application.Provider
	httpClient HttpClient
}

type HttpClient interface {
	Get(string) (*http.Response, error)
}

func New(client HttpClient) *repository {
	return &repository{httpClient: client}
}

type role struct {
	Name string `json:"name"`
}

func (r *repository) GetRoles() ([]string, error) {
	response, err := r.httpClient.Get(url)

	if err != nil {
		return nil, err
	}

	defer response.Body.Close()

	body, err := io.ReadAll(response.Body)

	if err != nil {
		return nil, err
	}

	var items []role

	err = json.Unmarshal(body, &items)

	if err != nil {
		return nil, err
	}

	var names []string

	for _, item := range items {
		names = append(names, item.Name)
	}

	return names, nil
}
