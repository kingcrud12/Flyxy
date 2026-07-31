package models

import (
	"time"

	"gorm.io/gorm"
)

type Comment struct {
	ID        string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	PostID    string         `gorm:"type:varchar(36);not null;index" json:"post_id"`
	UserID    string         `gorm:"type:varchar(36);not null;index" json:"user_id"`
	User      User           `gorm:"foreignKey:UserID" json:"user"`
	Text      string         `gorm:"type:text;not null" json:"text"`
	Likes     int            `gorm:"default:0" json:"likes"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

type CommentLike struct {
	ID        string    `gorm:"primaryKey;type:varchar(36)" json:"id"`
	CommentID string    `gorm:"type:varchar(36);not null;index:idx_comment_user,unique" json:"comment_id"`
	UserID    string    `gorm:"type:varchar(36);not null;index:idx_comment_user,unique" json:"user_id"`
	CreatedAt time.Time `json:"created_at"`
}
