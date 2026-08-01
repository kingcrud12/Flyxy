package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"flyxy-api/internal/handlers"
	"flyxy-api/internal/middleware"
	"flyxy-api/internal/repositories"
	"flyxy-api/internal/services"
	"flyxy-api/internal/utils/db"
	"flyxy-api/internal/utils/prim"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()

	// 1. Initialisation de la BDD
	database := db.InitDB("flyxy.db")

	// 2. Injection de dépendances (Clean Architecture)
	userRepo := repositories.NewSQLiteUserRepository(database)
	userService := services.NewUserService(userRepo)
	userHandler := handlers.NewUserHandler(userService)

	transportRepo := repositories.NewPrimTransportRepository()
	transportService := services.NewTransportService(transportRepo)
	transportHandler := handlers.NewTransportHandler(transportService)

	favoritesRepo := repositories.NewFavoritesRepository(database)
	favoritesService := services.NewFavoritesService(favoritesRepo)
	favoritesHandler := handlers.NewFavoritesHandler(favoritesService)

	postRepo := repositories.NewPostRepository(database)
	postService := services.NewPostService(postRepo)
	postHandler := handlers.NewPostHandler(postService)

	chatService := services.NewChatService()
	chatHandler := handlers.NewChatHandler(chatService)

	router := gin.Default()

	allowedOriginsStr := os.Getenv("ALLOWED_ORIGINS")
	var allowedOrigins []string
	if allowedOriginsStr != "" {
		allowedOrigins = strings.Split(allowedOriginsStr, ",")
	} else {
		allowedOrigins = []string{"http://localhost:5173"}
	}

	router.Use(cors.New(cors.Config{
		AllowOrigins:     allowedOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	v1 := router.Group("/api/v1")
	{
		v1.GET("/ping", func(c *gin.Context) { c.JSON(200, gin.H{"message": "pong"}) })
		v1.POST("/auth/register", userHandler.Register)
		v1.POST("/auth/login", userHandler.Login)

		v1.GET("/test-prim", func(c *gin.Context) {
			res, err := prim.TestConnection()
			if err != nil {
				c.JSON(500, gin.H{"error": err.Error()})
				return
			}
			c.JSON(200, gin.H{"data": res})
		})

		v1.GET("/transports/places", transportHandler.SearchPlaces)
		v1.GET("/transports/journeys", transportHandler.GetJourneys)
		v1.GET("/transports/nearby", transportHandler.GetNearbyDepartures)
		v1.GET("/transports/map/nearby", transportHandler.GetNearbyMapStops)
		v1.GET("/transports/vehicle-journey/:id", transportHandler.GetVehicleJourney)
		v1.GET("/transports/disruptions", transportHandler.GetDisruptions)

		v1.POST("/chat", chatHandler.HandleChat)

		protected := v1.Group("/")
		protected.Use(middleware.AuthRequired())
		{
			protected.GET("/me", userHandler.GetMe)
			protected.DELETE("/users/me", userHandler.DeleteMe)
			protected.POST("/users/me/avatar", userHandler.UploadAvatar)

			protected.POST("/favorites/places", favoritesHandler.AddFavoritePlace)
			protected.GET("/favorites/places", favoritesHandler.GetFavoritePlaces)
			protected.DELETE("/favorites/places/:id", favoritesHandler.DeleteFavoritePlace)
			protected.POST("/favorites/routes", favoritesHandler.AddFavoriteRoute)
			protected.GET("/favorites/routes", favoritesHandler.GetFavoriteRoutes)
			protected.DELETE("/favorites/routes/:id", favoritesHandler.DeleteFavoriteRoute)

			// Feed & Social
			protected.POST("/posts", postHandler.CreatePost)
			protected.PUT("/posts/:id", postHandler.UpdatePost)
			protected.DELETE("/posts/:id", postHandler.DeletePost)
			protected.POST("/posts/:id/like", postHandler.TogglePostLike)
			protected.POST("/posts/:id/comments", postHandler.CreateComment)
			protected.POST("/comments/:id/like", postHandler.ToggleCommentLike)
		}

		optional := v1.Group("/")
		optional.Use(middleware.AuthOptional())
		{
			optional.GET("/posts", postHandler.GetPosts)
			optional.GET("/posts/:id/comments", postHandler.GetComments)
		}
	}

	fmt.Println(" Serveur démarré sur http://localhost:8083")
	if err := router.Run(":8083"); err != nil {
		log.Fatalf("Erreur fatale : %v", err)
	}
}
