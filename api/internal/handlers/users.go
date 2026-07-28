package handlers

import (
	"net/http"

	"flyxy-api/internal/db"
	"flyxy-api/internal/models"

	"github.com/gin-gonic/gin"
)

// GetMe renvoie le profil de l'utilisateur connecté
func GetMe(c *gin.Context) {
	// Récupère l'ID injecté par le middleware AuthRequired
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	// Récupère l'utilisateur depuis le Store
	var user models.User
	result := db.GlobalStore.DB.First(&user, "id = ?", userID)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Utilisateur introuvable"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Profil récupéré avec succès",
		"id":         user.ID,
		"email":      user.Email,
		"first_name": user.FirstName,
		"last_name":  user.LastName,
	})
}
