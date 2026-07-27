package middleware

import (
	"net/http"
	"strings"

	"flyxy-api/internal/auth"

	"github.com/gin-gonic/gin"
)

// AuthRequired intercepte les requêtes pour valider le token JWT
func AuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Header Authorization manquant"})
			c.Abort()
			return
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Le format doit être 'Bearer {token}'"})
			c.Abort()
			return
		}

		tokenString := parts[1]
		claims, err := auth.VerifyToken(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token invalide ou expiré"})
			c.Abort()
			return
		}

		// Injecte l'ID utilisateur dans le contexte pour qu'il soit accessible par les Handlers
		c.Set("user_id", claims.UserID)
		c.Next()
	}
}
