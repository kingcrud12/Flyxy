package services

import (
	"flyxy-api/internal/dto"
	"flyxy-api/internal/repositories"
)

type UserService interface {
	Register(req dto.RegisterDTO) error
	Login(req dto.LoginDTO) (string, error)
	GetProfile(userID string) (*dto.UserProfileDTO, error)
}

type DefaultUserService struct {
	repo repositories.UserRepository
}

func NewUserService(repo repositories.UserRepository) UserService {
	return &DefaultUserService{repo: repo}
}
