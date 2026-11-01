# Example: a create-user endpoint

One endpoint through every layer, in the order of **Adding an endpoint**. It
compiles as shown (module `example.com/users`, MySQL, `net/http`). Use the
router, driver and logger the service already has; the shape is what matters.

## 1. Domain

`internal/domain/domain.go`

```go
package domain

import "errors"

var (
	ErrNotFound  = errors.New("not found")
	ErrDuplicate = errors.New("already exists")
)

type User struct {
	ID        int64
	Username  string
	FirstName string
	LastName  string
	Password  string
}
```

## 2. Port

`internal/application/service.go`

```go
package application

import (
	"context"

	"example.com/users/internal/domain"
)

type Repository interface {
	Save(ctx context.Context, u domain.User) (domain.User, error)
}

type Service struct {
	repo Repository
}

func New(repo Repository) *Service {
	return &Service{repo: repo}
}
```

## 3. Outbound adapter

`internal/infrastructure/repository/mysql/dto.go`

```go
package mysql

import "example.com/users/internal/domain"

type user struct {
	ID        int64  `db:"id"`
	Username  string `db:"username"`
	FirstName string `db:"first_name"`
	LastName  string `db:"last_name"`
	Password  string `db:"password"`
}

func (u user) toDomain() domain.User {
	return domain.User{
		ID:        u.ID,
		Username:  u.Username,
		FirstName: u.FirstName,
		LastName:  u.LastName,
		Password:  u.Password,
	}
}
```

`internal/infrastructure/repository/mysql/mappers.go`

```go
package mysql

import "example.com/users/internal/domain"

func mapUser(u domain.User) user {
	return user{
		ID:        u.ID,
		Username:  u.Username,
		FirstName: u.FirstName,
		LastName:  u.LastName,
		Password:  u.Password,
	}
}
```

`internal/infrastructure/repository/mysql/mysql.go`

```go
package mysql

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	driver "github.com/go-sql-driver/mysql"

	"example.com/users/internal/domain"
)

const errDuplicateEntry = 1062

type Repository struct {
	db *sql.DB
}

func New(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) Save(ctx context.Context, u domain.User) (domain.User, error) {
	row := mapUser(u)
	res, err := r.db.ExecContext(ctx,
		"INSERT INTO users (username, first_name, last_name, password) VALUES (?, ?, ?, ?)",
		row.Username, row.FirstName, row.LastName, row.Password)
	var mysqlErr *driver.MySQLError
	if errors.As(err, &mysqlErr) && mysqlErr.Number == errDuplicateEntry {
		return domain.User{}, domain.ErrDuplicate
	}
	if err != nil {
		return domain.User{}, fmt.Errorf("inserting user: %w", err)
	}

	row.ID, err = res.LastInsertId()
	if err != nil {
		return domain.User{}, fmt.Errorf("reading user id: %w", err)
	}

	saved := row.toDomain()
	saved.Password = ""
	return saved, nil
}
```

## 4. Use case

`internal/application/create_user.go`

```go
package application

import (
	"context"
	"fmt"
	"strings"

	"example.com/users/internal/domain"
)

func (s *Service) CreateUser(ctx context.Context, u domain.User) (domain.User, error) {
	u.Username = normalizeCreateUserUsername(u.Username)

	saved, err := s.repo.Save(ctx, u)
	if err != nil {
		return domain.User{}, fmt.Errorf("saving user %s: %w", u.Username, err)
	}
	return saved, nil
}

func normalizeCreateUserUsername(username string) string {
	return strings.ToLower(strings.TrimSpace(username))
}
```

## 5. Inbound adapter

`internal/infrastructure/api/rest/dto.go`

```go
package rest

import "example.com/users/internal/domain"

type CreateUserRequest struct {
	Username  string `json:"username"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Password  string `json:"password"`
}

func (r CreateUserRequest) toDomain() domain.User {
	return domain.User{
		Username:  r.Username,
		FirstName: r.FirstName,
		LastName:  r.LastName,
		Password:  r.Password,
	}
}

type UserResponse struct {
	ID        int64  `json:"id"`
	Username  string `json:"username"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
}
```

`internal/infrastructure/api/rest/mappers.go`

```go
package rest

import "example.com/users/internal/domain"

func mapUserResponse(u domain.User) UserResponse {
	return UserResponse{
		ID:        u.ID,
		Username:  u.Username,
		FirstName: u.FirstName,
		LastName:  u.LastName,
	}
}
```

`internal/infrastructure/api/rest/rest.go`

```go
package rest

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"

	"example.com/users/internal/domain"
)

type Service interface {
	CreateUser(ctx context.Context, u domain.User) (domain.User, error)
}

type Handler struct {
	svc Service
	log *slog.Logger
}

func New(svc Service, log *slog.Logger) *Handler {
	return &Handler{svc: svc, log: log}
}

func (h *Handler) Register(mux *http.ServeMux) {
	mux.HandleFunc("POST /users", h.createUser)
}

func (h *Handler) createUser(w http.ResponseWriter, r *http.Request) {
	var req CreateUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	u, err := h.svc.CreateUser(r.Context(), req.toDomain())
	if err != nil {
		h.writeError(w, r, err)
		return
	}
	h.writeJSON(w, r, http.StatusCreated, mapUserResponse(u))
}

func (h *Handler) writeError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrNotFound):
		http.Error(w, "not found", http.StatusNotFound)
	case errors.Is(err, domain.ErrDuplicate):
		http.Error(w, "already exists", http.StatusConflict)
	default:
		h.log.ErrorContext(r.Context(), "handling request", "path", r.URL.Path, "error", err)
		http.Error(w, "internal error", http.StatusInternalServerError)
	}
}

func (h *Handler) writeJSON(w http.ResponseWriter, r *http.Request, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(body); err != nil {
		h.log.ErrorContext(r.Context(), "writing response", "path", r.URL.Path, "error", err)
	}
}
```

## 6. Wiring

`internal/config/config.go`

```go
package config

import (
	"errors"
	"os"
)

type Config struct {
	Addr     string
	MySQLDSN string
}

func Load() (Config, error) {
	cfg := Config{
		Addr:     os.Getenv("ADDR"),
		MySQLDSN: os.Getenv("MYSQL_DSN"),
	}
	if cfg.Addr == "" {
		cfg.Addr = ":8080"
	}
	if cfg.MySQLDSN == "" {
		return Config{}, errors.New("MYSQL_DSN is required")
	}
	return cfg, nil
}
```

`cmd/service/main.go`

```go
package main

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "github.com/go-sql-driver/mysql"

	"example.com/users/internal/application"
	"example.com/users/internal/config"
	"example.com/users/internal/infrastructure/api/rest"
	"example.com/users/internal/infrastructure/repository/mysql"
)

func main() {
	log := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	if err := run(log); err != nil {
		log.Error("service stopped", "error", err)
		os.Exit(1)
	}
}

func run(log *slog.Logger) error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	db, err := sql.Open("mysql", cfg.MySQLDSN)
	if err != nil {
		return fmt.Errorf("opening mysql: %w", err)
	}
	defer db.Close()

	repo := mysql.New(db)
	svc := application.New(repo)

	mux := http.NewServeMux()
	rest.New(svc, log).Register(mux)

	srv := &http.Server{Addr: cfg.Addr, Handler: mux, ReadHeaderTimeout: 10 * time.Second}
	errCh := make(chan error, 1)
	go func() { errCh <- srv.ListenAndServe() }()

	select {
	case err := <-errCh:
		return fmt.Errorf("serving http: %w", err)
	case <-ctx.Done():
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return fmt.Errorf("shutting down: %w", err)
	}
	return nil
}
```

## Notes

- `UserResponse` has no `Password` field, and the repository clears `Password`
  on the saved user, so the hash never travels past the adapter.
- The MySQL driver is imported as `driver` because the adapter package is also
  called `mysql`.
- `writeError` logs only unexpected errors, at the point they stop propagating.
  Known sentinels become status codes without a log line.
