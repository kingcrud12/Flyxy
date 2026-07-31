package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User représente un compte voyageur dans la base de données
type User struct {
	ID             string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Email          string         `gorm:"uniqueIndex;not null" json:"email"`
	FirstName      string         `gorm:"not null" json:"first_name"`
	LastName       string         `gorm:"not null" json:"last_name"`
	PasswordHash   string         `gorm:"not null" json:"-"` // Le "-" empêche d'exposer le hash en JSON
	ProfilePicture string         `gorm:"type:text" json:"profile_picture"`
	CreatedAt      time.Time      `json:"created_at"`
	UpdatedAt      time.Time      `json:"updated_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"-"`
}

// BeforeCreate est un hook GORM appelé avant l'insertion en base
func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == "" {
		u.ID = uuid.New().String()
	}
	return
}

