package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

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
