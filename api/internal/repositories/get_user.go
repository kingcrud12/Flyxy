package repositories

import "flyxy-api/internal/models"

func (r *SQLiteUserRepository) GetUserByEmail(email string) (*models.User, bool) {
	var user models.User
	result := r.db.Where("email = ?", email).First(&user)
	if result.Error != nil {
		return nil, false
	}
	return &user, true
}

func (r *SQLiteUserRepository) GetUserByID(id string) (*models.User, bool) {
	var user models.User
	result := r.db.First(&user, "id = ?", id)
	if result.Error != nil {
		return nil, false
	}
	return &user, true
}
