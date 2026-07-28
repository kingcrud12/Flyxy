package services

import (
	"errors"
	"flyxy-api/internal/dto"
)

func (s *DefaultUserService) GetProfile(userID string) (*dto.UserProfileDTO, error) {
	user, exists := s.repo.GetUserByID(userID)
	if !exists {
		return nil, errors.New("utilisateur introuvable")
	}
	
	// Mapping du Model vers le DTO (Data Transfer Object)
	result := &dto.UserProfileDTO{
		ID:        user.ID,
		Email:     user.Email,
		FirstName: user.FirstName,
		LastName:  user.LastName,
	}
	
	return result, nil
}
