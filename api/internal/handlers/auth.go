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
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
	Email     string `json:"email" binding:"required,email"`
	Password  string `json:"password" binding:"required,min=6"`
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
		// FAILLE DE SÉCURITÉ CORRIGÉE (Anti-Énumération) :
		// On ne dit plus "Cet email est déjà utilisé". On simule une réponse générique 
		// pour tromper un attaquant qui essaierait de tester des listes d'emails.
		c.JSON(http.StatusOK, gin.H{"message": "Si l'email est valide, votre compte a bien été créé."})
		return
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	user := models.User{
		FirstName:    req.FirstName,
		LastName:     req.LastName,
		Email:        req.Email,
		PasswordHash: string(hashed),
	}

	if err := db.GlobalStore.SaveUser(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur interne du serveur"})
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

	// Définition du Cookie sécurisé (HttpOnly=true empêche le JS client de lire le cookie)
	// c.SetCookie(nom, valeur, maxAge (en s), chemin, domaine, secure (https), httpOnly)
	// 604800 secondes = 7 jours
	c.SetCookie("flyxy_jwt", token, 604800, "/", "", false, true)

	c.JSON(http.StatusOK, gin.H{"message": "Connexion réussie"})
}
