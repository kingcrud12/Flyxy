package repositories

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"sync"
	"time"

	"flyxy-api/internal/dto"
)

type TransportRepository interface {
	GetNearbyDepartures(lat, lon float64) (*dto.NavitiaDeparturesResponse, error)
	GetVehicleJourney(id string) (*dto.NavitiaVehicleJourneysResponse, error)
	SearchPlaces(query string) (*dto.NavitiaPlacesResponse, error)
	GetJourneys(from, to string) (*dto.NavitiaJourneysResponse, error)
	GetDisruptions(lat, lon float64) (*dto.NavitiaDisruptionsResponse, error)
}

type cacheItem struct {
	data      interface{}
	expiresAt time.Time
}

type PrimTransportRepository struct {
	BaseURL string
	Token   string
	cache   map[string]cacheItem
	mu      sync.RWMutex
}

func NewPrimTransportRepository() *PrimTransportRepository {
	baseURL := os.Getenv("PRIM_BASE_URL")
	if baseURL == "" {
		baseURL = "https://prim.iledefrance-mobilites.fr/marketplace/v2/navitia"
	}
	return &PrimTransportRepository{
		BaseURL: baseURL,
		Token:   os.Getenv("token_prim"),
		cache:   make(map[string]cacheItem),
	}
}

func (r *PrimTransportRepository) getFromCache(key string) interface{} {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if item, found := r.cache[key]; found {
		if time.Now().Before(item.expiresAt) {
			return item.data
		}
	}
	return nil
}

func (r *PrimTransportRepository) setToCache(key string, data interface{}, duration time.Duration) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.cache[key] = cacheItem{
		data:      data,
		expiresAt: time.Now().Add(duration),
	}
}

func (r *PrimTransportRepository) GetNearbyDepartures(lat, lon float64) (*dto.NavitiaDeparturesResponse, error) {
	if r.Token == "" {
		return nil, fmt.Errorf("token PRIM non trouvé")
	}

	// On arrondit à 3 décimales (~100 mètres) pour mutualiser le cache
	// entre les utilisateurs très proches.
	cacheKey := fmt.Sprintf("dep_%.3f_%.3f", lat, lon)
	if cached := r.getFromCache(cacheKey); cached != nil {
		return cached.(*dto.NavitiaDeparturesResponse), nil
	}

	url := fmt.Sprintf("%s/coords/%f;%f/departures?count=50&distance=1000", r.BaseURL, lon, lat)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("apikey", r.Token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return &dto.NavitiaDeparturesResponse{}, nil
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erreur API PRIM: statut %d", resp.StatusCode)
	}

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data dto.NavitiaDeparturesResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return nil, err
	}

	r.setToCache(cacheKey, &data, 30*time.Second)

	return &data, nil
}
func (r *PrimTransportRepository) GetVehicleJourney(id string) (*dto.NavitiaVehicleJourneysResponse, error) {
	if r.Token == "" {
		return nil, fmt.Errorf("token PRIM non trouvé")
	}

	url := fmt.Sprintf("%s/vehicle_journeys/%s", r.BaseURL, id)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("apikey", r.Token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erreur API PRIM: statut %d", resp.StatusCode)
	}

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data dto.NavitiaVehicleJourneysResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *PrimTransportRepository) SearchPlaces(query string) (*dto.NavitiaPlacesResponse, error) {
	if r.Token == "" {
		return nil, fmt.Errorf("token PRIM non trouvé")
	}

	encodedQuery := url.QueryEscape(query)
	apiURL := fmt.Sprintf("%s/places?q=%s", r.BaseURL, encodedQuery)

	req, err := http.NewRequest("GET", apiURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("apikey", r.Token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erreur API PRIM (places): statut %d", resp.StatusCode)
	}

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data dto.NavitiaPlacesResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *PrimTransportRepository) GetJourneys(from, to string) (*dto.NavitiaJourneysResponse, error) {
	if r.Token == "" {
		return nil, fmt.Errorf("token PRIM non trouvé")
	}

	encodedFrom := url.QueryEscape(from)
	encodedTo := url.QueryEscape(to)
	apiURL := fmt.Sprintf("%s/journeys?from=%s&to=%s", r.BaseURL, encodedFrom, encodedTo)

	req, err := http.NewRequest("GET", apiURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("apikey", r.Token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erreur API PRIM: statut %d", resp.StatusCode)
	}

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data dto.NavitiaJourneysResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return nil, err
	}

	return &data, nil
}

func (r *PrimTransportRepository) GetDisruptions(lat, lon float64) (*dto.NavitiaDisruptionsResponse, error) {
	if r.Token == "" {
		return nil, fmt.Errorf("token PRIM non trouvé")
	}

	cacheKey := fmt.Sprintf("disrup_%f_%f", lat, lon)
	if cached := r.getFromCache(cacheKey); cached != nil {
		return cached.(*dto.NavitiaDisruptionsResponse), nil
	}

	// L'API PRIM/Navitia ne supporte pas /coords/.../disruptions directement.
	// On requête donc la région globale avec count=10 pour satisfaire le besoin sans erreur 400/404.
	url := fmt.Sprintf("%s/disruptions?count=10", r.BaseURL)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("apikey", r.Token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erreur API PRIM: statut %d", resp.StatusCode)
	}

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var data dto.NavitiaDisruptionsResponse
	if err := json.Unmarshal(bodyBytes, &data); err != nil {
		return nil, err
	}

	r.setToCache(cacheKey, &data, 5*time.Minute)

	return &data, nil
}

