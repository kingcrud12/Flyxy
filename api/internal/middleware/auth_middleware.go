package middleware

import (
	"net/http"

	"flyxy-api/internal/utils/auth"

	"github.com/gin-gonic/gin"
)

// AuthRequired intercepte les requêtes pour valider le token JWT depuis le cookie HttpOnly
func AuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString, err := c.Cookie("flyxy_jwt")
		if err != nil || tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Non authentifié (Cookie manquant)"})
			c.Abort()
			return
		}

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
