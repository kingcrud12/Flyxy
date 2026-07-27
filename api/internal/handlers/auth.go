package handlers

import (
	"net/http"

	"flyxy-api/internal/auth"
	"flyxy-api/internal/db"
	"flyxy-api/internal/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type RegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

func Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides : " + err.Error()})
		return
	}

	_, exists := db.GlobalStore.GetUserByEmail(req.Email)
	if exists {
		c.JSON(http.StatusConflict, gin.H{"error": "Cet email est déjà utilisé"})
		return
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	user := models.User{
		Email:        req.Email,
		PasswordHash: string(hashed),
	}

	if err := db.GlobalStore.SaveUser(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Impossible de créer l'utilisateur"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Compte créé avec succès"})
}

func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	user, exists := db.GlobalStore.GetUserByEmail(req.Email)
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Identifiants incorrects"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Identifiants incorrects"})
		return
	}

	token, err := auth.GenerateToken(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la génération du token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}
