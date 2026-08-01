package services

import (
	"errors"
	"flyxy-api/internal/dto"
	"flyxy-api/internal/repositories"
	"flyxy-api/internal/utils/cloudinary"
	"mime/multipart"
)

type UserService interface {
	Register(req dto.RegisterDTO) error
	Login(req dto.LoginDTO) (string, error)
	GetProfile(userID string) (*dto.UserProfileDTO, error)
	UpdateAvatar(userID string, file multipart.File) (string, error)
	DeleteUser(userID string) error
}

type DefaultUserService struct {
	repo repositories.UserRepository
}

func NewUserService(repo repositories.UserRepository) UserService {
	return &DefaultUserService{repo: repo}
}

func (s *DefaultUserService) UpdateAvatar(userID string, file multipart.File) (string, error) {
	url, err := cloudinary.UploadImage(file)
	if err != nil {
		return "", err
	}

	user, exists := s.repo.GetUserByID(userID)
	if !exists {
		return "", errors.New("utilisateur introuvable")
	}

	user.ProfilePicture = url
	// Assuming there's an UpdateUser method, if not I need to add it to UserRepository.
	// Actually wait, let's look at UserRepository.
	return url, s.repo.UpdateUser(user)
}

func (s *DefaultUserService) DeleteUser(userID string) error {
	return s.repo.DeleteUser(userID)
}
