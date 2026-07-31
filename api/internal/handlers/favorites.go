package handlers

import (
	"net/http"

	"flyxy-api/internal/models"
	"flyxy-api/internal/services"

	"github.com/gin-gonic/gin"
)

type FavoritesHandler struct {
	favoritesService services.FavoritesService
}

func NewFavoritesHandler(favoritesService services.FavoritesService) *FavoritesHandler {
	return &FavoritesHandler{favoritesService: favoritesService}
}

func (h *FavoritesHandler) AddFavoritePlace(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	var place models.FavoritePlace
	if err := c.ShouldBindJSON(&place); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	place.UserID = userID.(string)

	if err := h.favoritesService.AddFavoritePlace(&place); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": place})
}

func (h *FavoritesHandler) GetFavoritePlaces(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	places, err := h.favoritesService.GetFavoritePlaces(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": places})
}

func (h *FavoritesHandler) DeleteFavoritePlace(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	id := c.Param("id")
	if err := h.favoritesService.DeleteFavoritePlace(id, userID.(string)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Favori supprimé"})
}

func (h *FavoritesHandler) AddFavoriteRoute(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	var route models.FavoriteRoute
	if err := c.ShouldBindJSON(&route); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Données invalides"})
		return
	}

	route.UserID = userID.(string)

	if err := h.favoritesService.AddFavoriteRoute(&route); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": route})
}

func (h *FavoritesHandler) GetFavoriteRoutes(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	routes, err := h.favoritesService.GetFavoriteRoutes(userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": routes})
}

func (h *FavoritesHandler) DeleteFavoriteRoute(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Non autorisé"})
		return
	}

	id := c.Param("id")
	if err := h.favoritesService.DeleteFavoriteRoute(id, userID.(string)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Itinéraire favori supprimé"})
}
