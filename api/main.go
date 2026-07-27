package main

import (
	"fmt"
	"log"

	"flyxy-api/internal/db"
	"flyxy-api/internal/handlers"
	"flyxy-api/internal/middleware"
	"flyxy-api/internal/prim"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()

	db.InitDB("flyxy.db")

	router := gin.Default()

	v1 := router.Group("/api/v1")
	{
		v1.GET("/ping", func(c *gin.Context) { c.JSON(200, gin.H{"message": "pong"}) })

		authGroup := v1.Group("/auth")
		{
			authGroup.POST("/register", handlers.Register)
			authGroup.POST("/login", handlers.Login)
		}

		v1.GET("/test-prim", func(c *gin.Context) {
			res, err := prim.TestConnection()
			if err != nil {
				c.JSON(500, gin.H{"error": err.Error()})
				return
			}
			c.JSON(200, gin.H{"data": res})
		})
	}

	protected := v1.Group("/")
	protected.Use(middleware.AuthRequired())
	{
		protected.GET("/me", handlers.GetMe)
		// protected.PATCH("/me", handlers.UpdateMe)
		// protected.GET("/me/favorites", handlers.GetFavorites)
		// protected.GET("/me/favorites/routes", handlers.GetFavoriteRoutes)
	}

	// 4. Lancer le serveur
	fmt.Println("🚀 Serveur démarré sur http://localhost:8081")
	if err := router.Run(":8081"); err != nil {
		log.Fatalf("Erreur fatale : %v", err)
	}
}
