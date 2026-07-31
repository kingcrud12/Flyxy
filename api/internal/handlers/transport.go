package handlers

import (
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"flyxy-api/internal/services"

	"github.com/gin-gonic/gin"
)

type TransportHandler struct {
	transportService services.TransportService
}

func NewTransportHandler(transportService services.TransportService) *TransportHandler {
	return &TransportHandler{transportService: transportService}
}

func (h *TransportHandler) GetNearbyDepartures(c *gin.Context) {
	latStr := c.Query("lat")
	lonStr := c.Query("lon")

	lat, errLat := strconv.ParseFloat(latStr, 64)
	lon, errLon := strconv.ParseFloat(lonStr, 64)

	if errLat != nil || errLon != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Paramètres lat et lon invalides ou manquants"})
		return
	}

	departures, err := h.transportService.GetNearbyDepartures(lat, lon)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": departures})
}

func (h *TransportHandler) GetNearbyMapStops(c *gin.Context) {
	latStr := c.Query("lat")
	lonStr := c.Query("lon")

	lat, errLat := strconv.ParseFloat(latStr, 64)
	lon, errLon := strconv.ParseFloat(lonStr, 64)

	if errLat != nil || errLon != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Paramètres lat et lon invalides ou manquants"})
		return
	}

	stops, err := h.transportService.GetNearbyMapStops(lat, lon)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": stops,
	})
}

// GetVehicleJourney récupère le détail d'une ligne
func (h *TransportHandler) GetVehicleJourney(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID manquant"})
		return
	}

	details, err := h.transportService.GetVehicleJourney(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": details,
	})
}

// SearchPlaces recherche des lieux (autocomplétion)
func (h *TransportHandler) SearchPlaces(c *gin.Context) {
	q := c.Query("q")
	if q == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Paramètre 'q' manquant"})
		return
	}

	places, err := h.transportService.SearchPlaces(q)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": places,
	})
}

// GetJourneys calcule un itinéraire
func (h *TransportHandler) GetJourneys(c *gin.Context) {
	from := c.Query("from")
	to := c.Query("to")

	if from == "" || to == "" {
		// Go 1.17+ rejects semicolons in query string. We must parse RawQuery manually.
		rawQuery := c.Request.URL.RawQuery
		// Manual parsing for from and to
		parsed, _ := url.ParseQuery(strings.ReplaceAll(rawQuery, ";", "%3B"))
		from = parsed.Get("from")
		to = parsed.Get("to")
	}

	if from == "" || to == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Paramètres 'from' et 'to' manquants"})
		return
	}

	journeys, err := h.transportService.GetJourneys(from, to)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": journeys,
	})
}

// GetDisruptions récupère les perturbations
func (h *TransportHandler) GetDisruptions(c *gin.Context) {
	latStr := c.Query("lat")
	lonStr := c.Query("lon")

	lat, _ := strconv.ParseFloat(latStr, 64)
	lon, _ := strconv.ParseFloat(lonStr, 64)

	disruptions, err := h.transportService.GetDisruptions(lat, lon)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": disruptions,
	})
}
