package prim

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

const BaseURL = "https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia"

func TestConnection() (string, error) {
	token := os.Getenv("token_prim")
	if token == "" {
		return "", fmt.Errorf("token PRIM non trouvé")
	}

	url := fmt.Sprintf("%s/places?q=chatelet", BaseURL)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}

	req.Header.Set("apikey", token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("erreur API PRIM: statut %d", resp.StatusCode)
	}

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	responseStr := string(bodyBytes)
	if len(responseStr) > 200 {
		responseStr = responseStr[:200] + "..."
	}

	return responseStr, nil
}
