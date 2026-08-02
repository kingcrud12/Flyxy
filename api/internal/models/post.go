package models

import (
	"time"

	"gorm.io/gorm"
)

type Post struct {
	ID        string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	UserID    string         `gorm:"type:varchar(36);not null;index" json:"user_id"`
	User      User           `gorm:"foreignKey:UserID" json:"user"`
	Text      string         `gorm:"type:text" json:"text"`
	ImageURL  string         `gorm:"type:text" json:"image_url"`
	Likes     int            `gorm:"default:0" json:"likes"`
	Comments  []Comment      `gorm:"foreignKey:PostID;constraint:OnDelete:CASCADE;" json:"comments"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type PostLike struct {
	ID        string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	PostID    string    `gorm:"type:varchar(36);not null;index:idx_post_user,unique" json:"post_id"`
	UserID    string    `gorm:"type:varchar(36);not null;index:idx_post_user,unique" json:"user_id"`
	CreatedAt time.Time `json:"created_at"`
}
