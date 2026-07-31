package services

import (
	"flyxy-api/internal/dto"
	"flyxy-api/internal/models"
	"flyxy-api/internal/repositories"
	"mime/multipart"

	"flyxy-api/internal/utils/cloudinary"

	"github.com/google/uuid"
)

type PostService interface {
	CreatePost(userID, text string, imageFile multipart.File) (*dto.PostDTO, error)
	GetPosts(currentUserID string) ([]dto.PostDTO, error)
	UpdatePost(postID, userID, text string) (*dto.PostDTO, error)
	DeletePost(postID, currentUserID string) error
	CreateComment(userID, postID, text string) (*dto.CommentDTO, error)
	GetComments(postID, currentUserID string) ([]dto.CommentDTO, error)
	TogglePostLike(postID, userID string) (bool, error)
	ToggleCommentLike(commentID, userID string) (bool, error)
}

type DefaultPostService struct {
	repo repositories.PostRepository
}

func NewPostService(repo repositories.PostRepository) PostService {
	return &DefaultPostService{repo: repo}
}

func (s *DefaultPostService) CreatePost(userID, text string, imageFile multipart.File) (*dto.PostDTO, error) {
	var imageURL string
	var err error
	if imageFile != nil {
		imageURL, err = cloudinary.UploadImage(imageFile)
		if err != nil {
			return nil, err
		}
	}

	post := models.Post{
		ID:       uuid.NewString(),
		UserID:   userID,
		Text:     text,
		ImageURL: imageURL,
	}

	if err := s.repo.CreatePost(&post); err != nil {
		return nil, err
	}

	return s.mapPostToDTO(post, false), nil
}

func (s *DefaultPostService) GetPosts(currentUserID string) ([]dto.PostDTO, error) {
	posts, err := s.repo.GetPosts()
	if err != nil {
		return nil, err
	}

	likedMap := make(map[string]bool)
	if currentUserID != "" {
		likedMap, _ = s.repo.GetUserLikedPostIDs(currentUserID)
	}

	var results []dto.PostDTO
	for _, p := range posts {
		results = append(results, *s.mapPostToDTO(p, likedMap[p.ID]))
	}
	return results, nil
}

func (s *DefaultPostService) UpdatePost(postID, userID, text string) (*dto.PostDTO, error) {
	if err := s.repo.UpdatePostText(postID, userID, text); err != nil {
		return nil, err
	}
	// Fetch the updated post to return it
	post, err := s.repo.GetPostByID(postID)
	if err != nil {
		return nil, err
	}
	
	likedMap := make(map[string]bool)
	likedMap, _ = s.repo.GetUserLikedPostIDs(userID)

	return s.mapPostToDTO(*post, likedMap[postID]), nil
}

func (s *DefaultPostService) DeletePost(postID, currentUserID string) error {
	return s.repo.DeletePost(postID, currentUserID)
}

func (s *DefaultPostService) CreateComment(userID, postID, text string) (*dto.CommentDTO, error) {
	comment := models.Comment{
		ID:     uuid.NewString(),
		PostID: postID,
		UserID: userID,
		Text:   text,
	}
	if err := s.repo.CreateComment(&comment); err != nil {
		return nil, err
	}
	return s.mapCommentToDTO(comment, false), nil
}

func (s *DefaultPostService) GetComments(postID, currentUserID string) ([]dto.CommentDTO, error) {
	comments, err := s.repo.GetCommentsByPostID(postID)
	if err != nil {
		return nil, err
	}
	likedMap := make(map[string]bool)
	if currentUserID != "" {
		likedMap, _ = s.repo.GetUserLikedCommentIDs(currentUserID)
	}

	var results []dto.CommentDTO
	for _, c := range comments {
		results = append(results, *s.mapCommentToDTO(c, likedMap[c.ID]))
	}
	return results, nil
}

func (s *DefaultPostService) TogglePostLike(postID, userID string) (bool, error) {
	return s.repo.TogglePostLike(postID, userID)
}

func (s *DefaultPostService) ToggleCommentLike(commentID, userID string) (bool, error) {
	return s.repo.ToggleCommentLike(commentID, userID)
}

func (s *DefaultPostService) mapPostToDTO(p models.Post, likedByMe bool) *dto.PostDTO {
	return &dto.PostDTO{
		ID:        p.ID,
		Text:      p.Text,
		ImageURL:  p.ImageURL,
		Likes:     p.Likes,
		LikedByMe: likedByMe,
		CreatedAt: p.CreatedAt,
		User: dto.UserProfileDTO{
			ID:             p.User.ID,
			FirstName:      p.User.FirstName,
			LastName:       p.User.LastName,
			ProfilePicture: p.User.ProfilePicture,
		},
	}
}

func (s *DefaultPostService) mapCommentToDTO(c models.Comment, likedByMe bool) *dto.CommentDTO {
	return &dto.CommentDTO{
		ID:        c.ID,
		PostID:    c.PostID,
		Text:      c.Text,
		Likes:     c.Likes,
		LikedByMe: likedByMe,
		CreatedAt: c.CreatedAt,
		User: dto.UserProfileDTO{
			ID:             c.User.ID,
			FirstName:      c.User.FirstName,
			LastName:       c.User.LastName,
			ProfilePicture: c.User.ProfilePicture,
		},
	}
}
