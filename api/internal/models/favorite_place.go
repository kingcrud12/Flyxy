package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

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
