package handlers

import (
	"net/http"

	"flyxy-api/internal/services"

	"github.com/gin-gonic/gin"
)

type ChatRequest struct {
	Message string `json:"message" binding:"required"`
}

type ChatHandler struct {
	chatService services.ChatService
}

func NewChatHandler(chatService services.ChatService) *ChatHandler {
	return &ChatHandler{chatService: chatService}
}

func (h *ChatHandler) HandleChat(c *gin.Context) {
	var req ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Message invalide"})
		return
	}

	response, err := h.chatService.GenerateResponse(req.Message)
	if err != nil {
		// On ne renvoie pas l'erreur brute si c'est la clé API manquante, on envoie un message clair
		if err.Error() == "GEMINI_API_KEY non configurée dans le backend" {
			c.JSON(http.StatusServiceUnavailable, gin.H{"error": "L'assistant IA est en cours de configuration. Veuillez ajouter votre clé API Gemini."})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"response": response})
}
