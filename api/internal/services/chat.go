package services

import (
	"context"
	"fmt"
	"os"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

type ChatService interface {
	GenerateResponse(userMessage string) (string, error)
}

type chatServiceImpl struct{}

func NewChatService() ChatService {
	return &chatServiceImpl{}
}

func (s *chatServiceImpl) GenerateResponse(userMessage string) (string, error) {
	ctx := context.Background()
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return "", fmt.Errorf("GEMINI_API_KEY non configurée dans le backend")
	}

	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return "", fmt.Errorf("erreur initialisation client Gemini: %v", err)
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-3.5-flash")
	
	// Personnalisation du comportement du bot (Context)
	model.SystemInstruction = &genai.Content{
		Parts: []genai.Part{
			genai.Text("Tu es Flyxy, un assistant virtuel bienveillant intégré dans une application d'aide aux transports en commun en Île-de-France. Ton but est de répondre aux questions de l'utilisateur de manière concise, précise et sympathique."),
		},
	}

	resp, err := model.GenerateContent(ctx, genai.Text(userMessage))
	if err != nil {
		return "", fmt.Errorf("erreur génération réponse Gemini: %v", err)
	}

	if len(resp.Candidates) > 0 && len(resp.Candidates[0].Content.Parts) > 0 {
		if textPart, ok := resp.Candidates[0].Content.Parts[0].(genai.Text); ok {
			return string(textPart), nil
		}
	}

	return "", fmt.Errorf("réponse vide ou invalide de Gemini")
}
