package services

import (
	"flyxy-api/internal/models"
	"flyxy-api/internal/repositories"
)

type FavoritesService interface {
	AddFavoritePlace(place *models.FavoritePlace) error
	GetFavoritePlaces(userID string) ([]models.FavoritePlace, error)
	DeleteFavoritePlace(id string, userID string) error

	AddFavoriteRoute(route *models.FavoriteRoute) error
	GetFavoriteRoutes(userID string) ([]models.FavoriteRoute, error)
	DeleteFavoriteRoute(id string, userID string) error
}

type favoritesService struct {
	repo repositories.FavoritesRepository
}

func NewFavoritesService(repo repositories.FavoritesRepository) FavoritesService {
	return &favoritesService{repo: repo}
}

func (s *favoritesService) AddFavoritePlace(place *models.FavoritePlace) error {
	return s.repo.AddFavoritePlace(place)
}

func (s *favoritesService) GetFavoritePlaces(userID string) ([]models.FavoritePlace, error) {
	return s.repo.GetFavoritePlaces(userID)
}

func (s *favoritesService) DeleteFavoritePlace(id string, userID string) error {
	return s.repo.DeleteFavoritePlace(id, userID)
}

func (s *favoritesService) AddFavoriteRoute(route *models.FavoriteRoute) error {
	return s.repo.AddFavoriteRoute(route)
}

func (s *favoritesService) GetFavoriteRoutes(userID string) ([]models.FavoriteRoute, error) {
	return s.repo.GetFavoriteRoutes(userID)
}

func (s *favoritesService) DeleteFavoriteRoute(id string, userID string) error {
	return s.repo.DeleteFavoriteRoute(id, userID)
}
