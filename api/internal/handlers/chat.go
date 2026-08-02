package handlers

import (
	"net/http"

	"flyxy-api/internal/services"

	"github.com/gin-gonic/gin"
	"github.com/google/generative-ai-go/genai"
)

type ChatMessagePart struct {
	Text string `json:"text"`
}

type ChatMessage struct {
	Role  string            `json:"role"`
	Parts []ChatMessagePart `json:"parts"`
}

type ChatRequest struct {
	Message string        `json:"message" binding:"required"`
	History []ChatMessage `json:"history"`
	Lat     float64       `json:"lat"`
	Lon     float64       `json:"lon"`
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

	var genaiHistory []*genai.Content
	for _, msg := range req.History {
		if msg.Role == "user" || msg.Role == "model" {
			var parts []genai.Part
			for _, p := range msg.Parts {
				parts = append(parts, genai.Text(p.Text))
			}
			genaiHistory = append(genaiHistory, &genai.Content{
				Role:  msg.Role,
				Parts: parts,
			})
		}
	}

	response, err := h.chatService.GenerateResponse(req.Message, genaiHistory, req.Lat, req.Lon)
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
