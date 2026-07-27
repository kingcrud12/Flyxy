package db

import (
	"log"

	"flyxy-api/internal/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Store struct {
	DB *gorm.DB
}

var GlobalStore *Store

// InitDB initialise la connexion SQLite et lance l'auto-migration
func InitDB(dsn string) {
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
	)
	if err != nil {
		log.Fatalf("Échec de l'auto-migration : %v", err)
	}

	log.Println("✅ Tables GORM migrées avec succès.")
	GlobalStore = &Store{DB: db}
}

// ----------------------------------------------------
// METHODES DU STORE (Repository Pattern)
// ----------------------------------------------------

func (s *Store) SaveUser(user *models.User) error {
	return s.DB.Save(user).Error
}

func (s *Store) GetUserByEmail(email string) (models.User, bool) {
	var user models.User
	result := s.DB.Where("email = ?", email).First(&user)
	return user, result.Error == nil
}
