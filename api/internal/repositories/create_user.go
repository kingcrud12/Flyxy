package repositories

import "flyxy-api/internal/models"

func (r *SQLiteUserRepository) CreateUser(user *models.User) error {
	return r.db.Create(user).Error
}
