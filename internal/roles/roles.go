package roles

import (
	"encoding/json"
	"io"
	"net/http"
)

const url = "https://api.github.com/repos/drew138/.dotfiles/contents/roles"

func New(client HttpClient) *Roles {
	return &Roles{
		httpClient: client,
	}
}

type role struct {
	Name string `json:"name"`
}

type Roles struct {
	httpClient HttpClient
}

type HttpClient interface {
	Get(string) (*http.Response, error)
}

func (r *Roles) getDirectoryNamesBody() ([]byte, error) {
	response, err := r.httpClient.Get(url)
	if err != nil {
		return nil, err
	}
	defer response.Body.Close()

	return io.ReadAll(response.Body)
}

func (r *Roles) parseResponseBody(body []byte) ([]string, error) {
	var items []role
	err := json.Unmarshal(body, &items)
	if err != nil {
		return nil, err
	}

	var names []string
	for _, item := range items {
		names = append(names, item.Name)
	}
	return names, nil
}

func (r *Roles) GetRoles() ([]string, error) {
	body, err := r.getDirectoryNamesBody()
	if err != nil {
		return nil, err
	}
	return r.parseResponseBody(body)
}
