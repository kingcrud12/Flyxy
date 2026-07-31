package repositories

import (
	"flyxy-api/internal/models"
	"gorm.io/gorm"
)

type FavoritesRepository interface {
	AddFavoritePlace(place *models.FavoritePlace) error
	GetFavoritePlaces(userID string) ([]models.FavoritePlace, error)
	DeleteFavoritePlace(id string, userID string) error

	AddFavoriteRoute(route *models.FavoriteRoute) error
	GetFavoriteRoutes(userID string) ([]models.FavoriteRoute, error)
	DeleteFavoriteRoute(id string, userID string) error
}

type favoritesRepository struct {
	db *gorm.DB
}

func NewFavoritesRepository(db *gorm.DB) FavoritesRepository {
	return &favoritesRepository{db: db}
}

func (r *favoritesRepository) AddFavoritePlace(place *models.FavoritePlace) error {
	return r.db.Create(place).Error
}

func (r *favoritesRepository) GetFavoritePlaces(userID string) ([]models.FavoritePlace, error) {
	var places []models.FavoritePlace
	err := r.db.Where("user_id = ?", userID).Find(&places).Error
	return places, err
}

func (r *favoritesRepository) DeleteFavoritePlace(id string, userID string) error {
	return r.db.Where("id = ? AND user_id = ?", id, userID).Delete(&models.FavoritePlace{}).Error
}

func (r *favoritesRepository) AddFavoriteRoute(route *models.FavoriteRoute) error {
	return r.db.Create(route).Error
}

func (r *favoritesRepository) GetFavoriteRoutes(userID string) ([]models.FavoriteRoute, error) {
	var routes []models.FavoriteRoute
	err := r.db.Where("user_id = ?", userID).Find(&routes).Error
	return routes, err
}

func (r *favoritesRepository) DeleteFavoriteRoute(id string, userID string) error {
	return r.db.Where("id = ? AND user_id = ?", id, userID).Delete(&models.FavoriteRoute{}).Error
}
