package auth

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// jwtKey est la clé secrète pour signer les tokens (Idéalement dans .env)
var jwtKey = []byte(os.Getenv("JWT_SECRET"))

// Claims représente le contenu du Payload du JWT
type Claims struct {
	UserID uint `json:"user_id"`
	jwt.RegisteredClaims
}

// GenerateToken crée un token JWT pour un ID utilisateur donné
func GenerateToken(userID uint) (string, error) {
	if len(jwtKey) == 0 {
		jwtKey = []byte("super_secret_key_change_me") // Fallback de dev
	}

	expirationTime := time.Now().Add(24 * time.Hour * 7) // Valide 7 jours
	claims := &Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}

// VerifyToken vérifie la validité du token et retourne les claims (dont l'ID utilisateur)
func VerifyToken(tokenString string) (*Claims, error) {
	if len(jwtKey) == 0 {
		jwtKey = []byte("super_secret_key_change_me")
	}

	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})

	if err != nil || !token.Valid {
		return nil, err
	}
	return claims, nil
}
