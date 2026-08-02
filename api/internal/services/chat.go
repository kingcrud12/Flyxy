package services

import (
	"context"
	"fmt"
	"os"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

type ChatService interface {
	GenerateResponse(userMessage string, history []*genai.Content, lat, lon float64) (string, error)
}

type chatServiceImpl struct {
	transportService TransportService
}

func NewChatService(ts TransportService) ChatService {
	return &chatServiceImpl{transportService: ts}
}

func (s *chatServiceImpl) GenerateResponse(userMessage string, history []*genai.Content, lat, lon float64) (string, error) {
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
	systemPrompt := "Tu es Flyxy, un assistant virtuel bienveillant intégré dans une application d'aide aux transports en commun en Île-de-France. Ton but est de répondre aux questions de l'utilisateur de manière concise, précise et sympathique.\n\n"
	
	if lat != 0 && lon != 0 && s.transportService != nil {
		systemPrompt += "--- CONTEXTE SYSTÈME INVISIBLE (NE PAS MENTIONNER NI ÉNUMÉRER DIRECTEMENT CES INFORMATIONS À L'UTILISATEUR SAUF S'IL TE POSE UNE QUESTION SUR LE TRAFIC) ---\n"
		systemPrompt += "Voici les données en temps réel autour de la position actuelle de l'utilisateur :\n"
		
		// Lignes à proximité
		departures, err := s.transportService.GetNearbyDepartures(lat, lon)
		if err == nil && len(departures) > 0 {
			systemPrompt += "Lignes à proximité (dans un rayon de 1km) :\n"
			for i, d := range departures {
				if i > 15 { // Limiter pour ne pas surcharger le prompt
					break
				}
				var dests string
				for j, dir := range d.Directions {
					if j > 0 {
						dests += " et "
					}
					dests += dir.Name
				}
				systemPrompt += fmt.Sprintf("- %s %s (vers %s)\n", d.Type, d.Line, dests)
			}
		}

		// Perturbations actives
		disruptions, err := s.transportService.GetDisruptions(lat, lon)
		if err == nil && len(disruptions) > 0 {
			systemPrompt += "\nInfo Trafic (Perturbations actives) :\n"
			hasDisruptions := false
			for _, d := range disruptions {
				hasDisruptions = true
				var msg string
				if len(d.Messages) > 0 {
					msg = d.Messages[0].Text
				}
				systemPrompt += fmt.Sprintf("- Gravité: %s. Message: %s\n", d.Severity.Name, msg)
			}
			if !hasDisruptions {
				systemPrompt += "Aucune perturbation active signalée pour le moment.\n"
			}
		} else {
			systemPrompt += "\nAucune perturbation active signalée pour le moment.\n"
		}
		
		systemPrompt += "\nRÈGLE STRICTE : N'énumère JAMAIS ces lignes ou ces travaux de ta propre initiative. Si l'utilisateur pose une question précise (ex: 'Y a-t-il des problèmes sur le bus 206 ?'), utilise ces données pour lui répondre (ex: 'Aucune perturbation n'est signalée sur le bus 206 actuellement').\n--------------------------------\n"
	}

	model.SystemInstruction = &genai.Content{
		Parts: []genai.Part{
			genai.Text(systemPrompt),
		},
	}

	chat := model.StartChat()
	chat.History = history

	resp, err := chat.SendMessage(ctx, genai.Text(userMessage))
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
