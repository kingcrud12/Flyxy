package repositories

import (
	"flyxy-api/internal/models"
	"gorm.io/gorm"
)

// DeleteUser supprime un utilisateur et toutes ses données associées
func (r *SQLiteUserRepository) DeleteUser(id string) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// Delete user's comments likes
		if err := tx.Where("user_id = ?", id).Delete(&models.CommentLike{}).Error; err != nil {
			return err
		}
		// Delete user's post likes
		if err := tx.Where("user_id = ?", id).Delete(&models.PostLike{}).Error; err != nil {
			return err
		}
		// Delete user's comments
		if err := tx.Where("user_id = ?", id).Delete(&models.Comment{}).Error; err != nil {
			return err
		}
		// Delete user's posts
		if err := tx.Where("user_id = ?", id).Delete(&models.Post{}).Error; err != nil {
			return err
		}
		// Delete user's favorite places
		if err := tx.Where("user_id = ?", id).Delete(&models.FavoritePlace{}).Error; err != nil {
			return err
		}
		// Delete user's favorite routes
		if err := tx.Where("user_id = ?", id).Delete(&models.FavoriteRoute{}).Error; err != nil {
			return err
		}
		// Delete the user
		if err := tx.Where("id = ?", id).Delete(&models.User{}).Error; err != nil {
			return err
		}
		return nil
	})
}
