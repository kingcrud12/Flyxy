package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User représente un compte voyageur dans la base de données
type User struct {
	ID           string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Email        string         `gorm:"uniqueIndex;not null" json:"email"`
	FirstName    string         `gorm:"not null" json:"first_name"`
	LastName     string         `gorm:"not null" json:"last_name"`
	PasswordHash string         `gorm:"not null" json:"-"` // Le "-" empêche d'exposer le hash en JSON
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

// BeforeCreate est un hook GORM appelé avant l'insertion en base
func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == "" {
		u.ID = uuid.New().String()
	}
	return
}

// FavoritePlace représente une station mise en favori par l'utilisateur
type FavoritePlace struct {
	ID         string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	UserID     string         `gorm:"index;not null;type:varchar(36)" json:"user_id"`
	Name       string         `gorm:"not null" json:"name"`         // ex: "Maison"
	StopAreaID string         `gorm:"not null" json:"stop_area_id"` // ex: "stop_area:IDFM:71556"
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (f *FavoritePlace) BeforeCreate(tx *gorm.DB) (err error) {
	if f.ID == "" {
		f.ID = uuid.New().String()
	}
	return
}

// FavoriteRoute représente un trajet habituel mis en favori
type FavoriteRoute struct {
	ID         string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	UserID     string         `gorm:"index;not null;type:varchar(36)" json:"user_id"`
	Name       string         `gorm:"not null" json:"name"` // ex: "Maison -> Travail"
	FromStopID string         `gorm:"not null" json:"from_stop_id"`
	ToStopID   string         `gorm:"not null" json:"to_stop_id"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (f *FavoriteRoute) BeforeCreate(tx *gorm.DB) (err error) {
	if f.ID == "" {
		f.ID = uuid.New().String()
	}
	return
}
