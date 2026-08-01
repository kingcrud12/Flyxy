package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func (h *UserHandler) DeleteMe(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	idStr, ok := userID.(string)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "ID utilisateur invalide"})
		return
	}

	if err := h.userService.DeleteUser(idStr); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Échec de la suppression du compte"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Compte supprimé avec succès"})
}
