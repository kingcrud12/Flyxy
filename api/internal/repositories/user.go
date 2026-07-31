package repositories

import (
	"flyxy-api/internal/models"
	"gorm.io/gorm"
)

// UserRepository definit les contrats d'accès aux données utilisateur
type UserRepository interface {
	CreateUser(user *models.User) error
	GetUserByEmail(email string) (*models.User, bool)
	GetUserByID(id string) (*models.User, bool)
	UpdateUser(user *models.User) error
}

// SQLiteUserRepository implémente UserRepository pour SQLite via GORM
type SQLiteUserRepository struct {
	db *gorm.DB
}

func NewSQLiteUserRepository(db *gorm.DB) UserRepository {
	return &SQLiteUserRepository{db: db}
}
