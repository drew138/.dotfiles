package application

type Provider interface {
	GetRoles() ([]string, error)
}

type Provisioner interface {
	Pull(roles []string, debug bool) error
}

type Service interface {
	GetRoles() ([]string, error)
	Pull(roles []string, debug bool) error
}
