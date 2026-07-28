package services

import (
	"errors"
	"flyxy-api/internal/auth"
	"flyxy-api/internal/dto"

	"golang.org/x/crypto/bcrypt"
)

func (s *DefaultUserService) Login(req dto.LoginDTO) (string, error) {
	user, exists := s.repo.GetUserByEmail(req.Email)
	if !exists {
		return "", errors.New("identifiants incorrects")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return "", errors.New("identifiants incorrects")
	}

	token, err := auth.GenerateToken(user.ID)
	if err != nil {
		return "", errors.New("erreur lors de la génération du token")
	}

	return token, nil
}
