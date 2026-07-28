package services

import (
	"flyxy-api/internal/dto"
	"flyxy-api/internal/models"

	"golang.org/x/crypto/bcrypt"
)

func (s *DefaultUserService) Register(req dto.RegisterDTO) error {
	// Vérification de l'existence
	_, exists := s.repo.GetUserByEmail(req.Email)
	if exists {
		// Par sécurité anti-énumération, on simule que tout s'est bien passé
		return nil
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	user := models.User{
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		Email:        req.Email,
		PasswordHash: string(hashed),
	}

	return s.repo.CreateUser(&user)
}
