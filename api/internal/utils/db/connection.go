package db

import (
	"log"

	"flyxy-api/internal/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// InitDB initialise la connexion SQLite, lance l'auto-migration et retourne l'instance DB
func InitDB(dsn string) *gorm.DB {
	db, err := gorm.Open(sqlite.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Échec de la connexion à la base de données : %v", err)
	}

	log.Println("✅ Connecté à SQLite avec succès.")

	// Auto Migrate
	err = db.AutoMigrate(
		&models.User{},
		&models.FavoritePlace{},
		&models.FavoriteRoute{},
		&models.Post{},
		&models.Comment{},
		&models.PostLike{},
		&models.CommentLike{},
	)
	if err != nil {
		log.Fatalf("Échec de l'auto-migration : %v", err)
	}

	log.Println("✅  Vérification du schéma GORM terminée avec succès.")
	return db
}
