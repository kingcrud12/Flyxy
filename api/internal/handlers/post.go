package handlers

import (
	"net/http"
	"flyxy-api/internal/services"

	"github.com/gin-gonic/gin"
)

type PostHandler struct {
	postService services.PostService
}

func NewPostHandler(postService services.PostService) *PostHandler {
	return &PostHandler{postService: postService}
}

func (h *PostHandler) CreatePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	text := c.PostForm("text")

	file, _, err := c.Request.FormFile("image")
	if err != nil && err != http.ErrMissingFile {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Erreur lors de la lecture du fichier image"})
		return
	}
	if file != nil {
		defer file.Close()
	}

	post, err := h.postService.CreatePost(userID.(string), text, file)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, post)
}

func (h *PostHandler) GetPosts(c *gin.Context) {
	userID, _ := c.Get("user_id")
	var currentUserID string
	if userID != nil {
		currentUserID = userID.(string)
	}

	posts, err := h.postService.GetPosts(currentUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": posts})
}

func (h *PostHandler) DeletePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	err := h.postService.DeletePost(postID, userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Post deleted successfully"})
}

func (h *PostHandler) UpdatePost(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	var req struct {
		Text string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	post, err := h.postService.UpdatePost(postID, userID.(string), req.Text)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, post)
}

func (h *PostHandler) CreateComment(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")
	
	var req struct {
		Text string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	comment, err := h.postService.CreateComment(userID.(string), postID, req.Text)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, comment)
}

func (h *PostHandler) GetComments(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	var currentUserID string
	if userID != nil {
		currentUserID = userID.(string)
	}

	comments, err := h.postService.GetComments(postID, currentUserID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": comments})
}

func (h *PostHandler) TogglePostLike(c *gin.Context) {
	userID, _ := c.Get("user_id")
	postID := c.Param("id")

	liked, err := h.postService.TogglePostLike(postID, userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"liked": liked})
}

func (h *PostHandler) ToggleCommentLike(c *gin.Context) {
	userID, _ := c.Get("user_id")
	commentID := c.Param("id")

	liked, err := h.postService.ToggleCommentLike(commentID, userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"liked": liked})
}
