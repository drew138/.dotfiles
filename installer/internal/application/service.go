package application

type service struct {
	Service
	provider    Provider
	provisioner Provisioner
}

func New(provider Provider, provisioner Provisioner) *service {
	return &service{
		provider:    provider,
		provisioner: provisioner,
	}
}

func (s *service) GetRoles() ([]string, error) {
	return s.provider.GetRoles()
}

func (s *service) Pull(roles []string, debug bool) error {
	return s.provisioner.Pull(roles, debug)
}
