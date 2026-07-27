package models

import (
	"time"

	"gorm.io/gorm"
)

// User représente un compte voyageur dans la base de données
type User struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	Email        string         `gorm:"uniqueIndex;not null" json:"email"`
	PasswordHash string         `gorm:"not null" json:"-"` // Le "-" empêche d'exposer le hash en JSON
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

// FavoritePlace représente une station mise en favori par l'utilisateur
type FavoritePlace struct {
	ID         uint           `gorm:"primaryKey" json:"id"`
	UserID     uint           `gorm:"index;not null" json:"user_id"`
	Name       string         `gorm:"not null" json:"name"`         // ex: "Maison"
	StopAreaID string         `gorm:"not null" json:"stop_area_id"` // ex: "stop_area:IDFM:71556"
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

// FavoriteRoute représente un trajet habituel mis en favori
type FavoriteRoute struct {
	ID         uint           `gorm:"primaryKey" json:"id"`
	UserID     uint           `gorm:"index;not null" json:"user_id"`
	Name       string         `gorm:"not null" json:"name"` // ex: "Maison -> Travail"
	FromStopID string         `gorm:"not null" json:"from_stop_id"`
	ToStopID   string         `gorm:"not null" json:"to_stop_id"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}
