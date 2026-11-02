# gRPC adapter

The inbound adapter for gRPC, at `internal/infrastructure/api/grpc/`. It mirrors the
REST adapter (`rest.md`) file for file, so a use case exposed on both looks the same
in both.

## Files

| Path | Holds |
|---|---|
| `api/proto/<service>/v1/<entity>.proto` | the contract, at the repository root |
| `grpc/server.go` | `Application` interface, `Server`, `New`, shared private methods, validator setup, `//go:generate` |
| `grpc/<rpc_name>.go` | one RPC per file: `CreateUser` lives in `create_user.go` |
| `grpc/dto.go` | request structs with `validate` tags and `toDomain()` |
| `grpc/mappers.go` | `map<Target>` functions both ways, the error tables, `mapStatus` |
| `grpc/pb/` | generated; never edited, never checked |

## Server and New

```go
type Server struct {
	pb.UnimplementedUserServiceServer
	app      Application
	validate *validator.Validate
}

func New(server *grpc.Server, app Application) *Server {
	s := &Server{app: app, validate: newValidator()}
	pb.RegisterUserServiceServer(server, s)
	return s
}
```

Same contract as REST's `New(router, app)`: build, register, return. The adapter
package is named `grpc`; import it as `grpcapi` in `main.go` so
`google.golang.org/grpc` stays readable.

## Validation: same validator, own DTOs

Generated messages cannot carry tags, and methods cannot be added to them. So the
adapter maps each request message into its own tagged struct and validates that,
with the same validator setup as REST (`validation.md`):

`dto.go`:

```go
type CreateUserRequest struct {
	Username string `validate:"required,max=32"`
	Email    string `validate:"required,email,max=254"`
	Role     string `validate:"required,enum=role"`
}

func (r CreateUserRequest) toDomain() domain.User { … }
```

`create_user.go`:

```go
func (s *Server) CreateUser(ctx context.Context, msg *pb.CreateUserRequest) (*pb.User, error) {
	req := mapCreateUserRequest(msg)
	if err := s.validate.Struct(req); err != nil {
		return nil, mapStatus(err)
	}

	user, err := s.app.CreateUser(ctx, req.toDomain())
	if err != nil {
		return nil, mapStatus(err)
	}
	return mapUserMessage(user), nil
}
```

The DTO has no `json` tags, so the validator would report Go field names
(`Username`). Register a tag-name function that converts them to the proto's
snake_case, so errors name `username` and `role`, the fields the client sent.

## Mappers

- `mapCreateUserRequest(msg *pb.CreateUserRequest) CreateUserRequest`: generated
  message → DTO.
- `mapUserMessage(user domain.User) *pb.User`: domain → generated response. No secret
  fields in response messages.
- Proto enums map to domain enum strings here, both ways.
- `int` in the domain is `int64` in proto. Time is `google.protobuf.Timestamp`
  (`timestamppb.New`, `.AsTime()`).

## Errors

`mapStatus(err)` uses the same two-table approach as REST (`errors.md`): validator
errors first, then specific domain errors (each adds a field violation), then
generic kinds. Kinds become codes:

| Kind | Code |
|---|---|
| validator failure, `ErrInvalid` | `InvalidArgument` |
| `ErrNotFound` | `NotFound` |
| `ErrConflict` | `AlreadyExists` |
| `ErrUnavailable`, `context.DeadlineExceeded` | `Unavailable` |
| `context.Canceled` | `Canceled` |
| `ErrInternal`, anything else | `Internal` |

Field-level detail goes in `errdetails.BadRequest` field violations attached with
`status.WithDetails`, so gRPC clients get the same detail as REST clients.

Like REST, every RPC produces one log line when it finishes (`logging.md`): a unary
server interceptor, registered once when the server is built, logs the method, the
code and the duration, and the error when the code is `Internal`, `Unknown` or
`Unavailable`.

## The proto

- At the repository root: `api/proto/<service>/v1/`. A breaking change is a new `v2`.
- Response messages omit secret fields; request messages carry them.
- Field numbers are forever. Never reuse a removed one; mark it `reserved`.

## Generating

Run `protoc` with `protoc-gen-go` and `protoc-gen-go-grpc` from a `//go:generate`
line in `server.go`, writing into `grpc/pb/` (`go_package` pointing there). Run
`go generate` before `go mod tidy`, since `tidy` needs the `pb` package to exist.
Commit the generated files.

## Serving

`cmd/grpc/main.go` listens on `GRPC_ADDR`, serves, and calls `GracefulStop` on
shutdown (`wiring.md`).
