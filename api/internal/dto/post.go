package dto

import "time"

type PostDTO struct {
	ID        string         `json:"id"`
	Text      string         `json:"text"`
	ImageURL  string         `json:"image_url"`
	Likes     int            `json:"likes"`
	LikedByMe bool           `json:"liked_by_me"`
	CreatedAt time.Time      `json:"created_at"`
	User      UserProfileDTO `json:"user"`
}

type CommentDTO struct {
	ID        string         `json:"id"`
	PostID    string         `json:"post_id"`
	Text      string         `json:"text"`
	Likes     int            `json:"likes"`
	LikedByMe bool           `json:"liked_by_me"`
	CreatedAt time.Time      `json:"created_at"`
	User      UserProfileDTO `json:"user"`
}
