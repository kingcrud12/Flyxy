package repositories

import (
	"flyxy-api/internal/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PostRepository interface {
	CreatePost(post *models.Post) error
	GetPosts() ([]models.Post, error)
	GetPostByID(id string) (*models.Post, error)
	UpdatePostText(id string, userID string, text string) error
	DeletePost(id string, userID string) error
	CreateComment(comment *models.Comment) error
	GetCommentsByPostID(postID string) ([]models.Comment, error)
	TogglePostLike(postID, userID string) (bool, error)
	ToggleCommentLike(commentID, userID string) (bool, error)
	GetUserLikedPostIDs(userID string) (map[string]bool, error)
	GetUserLikedCommentIDs(userID string) (map[string]bool, error)
}

type SQLitePostRepository struct {
	db *gorm.DB
}

func NewPostRepository(db *gorm.DB) PostRepository {
	return &SQLitePostRepository{db: db}
}

func (r *SQLitePostRepository) DeletePost(id string, userID string) error {
	result := r.db.Where("id = ? AND user_id = ?", id, userID).Delete(&models.Post{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *SQLitePostRepository) UpdatePostText(id string, userID string, text string) error {
	result := r.db.Model(&models.Post{}).Where("id = ? AND user_id = ?", id, userID).Update("text", text)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}

func (r *SQLitePostRepository) CreatePost(post *models.Post) error {
	return r.db.Create(post).Error
}

func (r *SQLitePostRepository) GetPosts() ([]models.Post, error) {
	var posts []models.Post
	err := r.db.Preload("User").Order("created_at desc").Find(&posts).Error
	return posts, err
}

func (r *SQLitePostRepository) GetPostByID(id string) (*models.Post, error) {
	var post models.Post
	err := r.db.Preload("User").First(&post, "id = ?", id).Error
	return &post, err
}

func (r *SQLitePostRepository) CreateComment(comment *models.Comment) error {
	return r.db.Create(comment).Error
}

func (r *SQLitePostRepository) GetCommentsByPostID(postID string) ([]models.Comment, error) {
	var comments []models.Comment
	err := r.db.Preload("User").Where("post_id = ?", postID).Order("created_at asc").Find(&comments).Error
	return comments, err
}

func (r *SQLitePostRepository) TogglePostLike(postID, userID string) (bool, error) {
	var existingLike models.PostLike
	err := r.db.Where("post_id = ? AND user_id = ?", postID, userID).First(&existingLike).Error

	if err == gorm.ErrRecordNotFound {
		// Pas encore liké, on ajoute le like
		like := models.PostLike{ID: uuid.NewString(), PostID: postID, UserID: userID}
		if err := r.db.Create(&like).Error; err != nil {
			return false, err
		}
		r.db.Model(&models.Post{}).Where("id = ?", postID).Update("likes", gorm.Expr("likes + 1"))
		return true, nil
	} else if err != nil {
		return false, err
	}

	// Déjà liké, on supprime le like
	r.db.Delete(&existingLike)
	r.db.Model(&models.Post{}).Where("id = ?", postID).Update("likes", gorm.Expr("likes - 1"))
	return false, nil
}

func (r *SQLitePostRepository) ToggleCommentLike(commentID, userID string) (bool, error) {
	var existingLike models.CommentLike
	err := r.db.Where("comment_id = ? AND user_id = ?", commentID, userID).First(&existingLike).Error

	if err == gorm.ErrRecordNotFound {
		like := models.CommentLike{ID: uuid.NewString(), CommentID: commentID, UserID: userID}
		if err := r.db.Create(&like).Error; err != nil {
			return false, err
		}
		r.db.Model(&models.Comment{}).Where("id = ?", commentID).Update("likes", gorm.Expr("likes + 1"))
		return true, nil
	} else if err != nil {
		return false, err
	}

	r.db.Delete(&existingLike)
	r.db.Model(&models.Comment{}).Where("id = ?", commentID).Update("likes", gorm.Expr("likes - 1"))
	return false, nil
}

func (r *SQLitePostRepository) GetUserLikedPostIDs(userID string) (map[string]bool, error) {
	var likes []models.PostLike
	if err := r.db.Where("user_id = ?", userID).Find(&likes).Error; err != nil {
		return nil, err
	}
	likedMap := make(map[string]bool)
	for _, l := range likes {
		likedMap[l.PostID] = true
	}
	return likedMap, nil
}

func (r *SQLitePostRepository) GetUserLikedCommentIDs(userID string) (map[string]bool, error) {
	var likes []models.CommentLike
	if err := r.db.Where("user_id = ?", userID).Find(&likes).Error; err != nil {
		return nil, err
	}
	likedMap := make(map[string]bool)
	for _, l := range likes {
		likedMap[l.CommentID] = true
	}
	return likedMap, nil
}

