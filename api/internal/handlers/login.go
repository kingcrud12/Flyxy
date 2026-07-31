package handlers

import (
	"net/http"

	"flyxy-api/internal/dto"
	"flyxy-api/internal/utils/auth"

	"github.com/gin-gonic/gin"
)

func (h *UserHandler) Login(c *gin.Context) {
	var req dto.LoginDTO
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	token, err := h.userService.Login(req)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.SetCookie(auth.CookieName, token, 604800, "/", "", false, true)

	c.JSON(http.StatusOK, gin.H{"message": "Connexion réussie"})
}
