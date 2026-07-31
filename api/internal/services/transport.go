package services

import (
	"fmt"
	"sort"
	"strconv"
	"time"

	"flyxy-api/internal/dto"
	"flyxy-api/internal/repositories"
)

type TransportService interface {
	GetNearbyDepartures(lat, lon float64) ([]dto.DepartureDTO, error)
	GetNearbyMapStops(lat, lon float64) ([]dto.MapStopDTO, error)
	GetVehicleJourney(id string) (*dto.VehicleJourneyDTO, error)
	SearchPlaces(query string) ([]dto.PlaceDTO, error)
	GetJourneys(from, to string) ([]dto.JourneyDTO, error)
	GetDisruptions(lat, lon float64) ([]dto.NavitiaDisruption, error)
}

type DefaultTransportService struct {
	repo repositories.TransportRepository
}

func NewTransportService(repo repositories.TransportRepository) TransportService {
	return &DefaultTransportService{repo: repo}
}

func (s *DefaultTransportService) GetNearbyDepartures(lat, lon float64) ([]dto.DepartureDTO, error) {
	navitiaResp, err := s.repo.GetNearbyDepartures(lat, lon)
	if err != nil {
		return nil, err
	}

	loc, err := time.LoadLocation("Europe/Paris")
	if err != nil {
		loc = time.Local
	}
	now := time.Now().In(loc)

	// Group by "LineCode_Mode"
	grouped := make(map[string]*dto.DepartureDTO)

	for _, dep := range navitiaResp.Departures {
		// Parsing de l'heure
		t, err := time.ParseInLocation("20060102T150405", dep.StopDateTime.DepartureDateTime, loc)
		var timeStr string
		if err == nil {
			diffMins := int(t.Sub(now).Minutes())
			if diffMins < 0 {
				continue // Déjà passé
			} else if diffMins == 0 {
				timeStr = "0 min"
			} else if diffMins < 60 {
				timeStr = fmt.Sprintf("%d min", diffMins)
			} else {
				timeStr = t.Format("15:04")
			}
		} else {
			timeStr = dep.StopDateTime.DepartureDateTime
		}

		modeName := dep.Route.Line.CommercialMode.Name
		if modeName == "" {
			modeName = "Transport"
		}
		
		normalizedMode := modeName
		switch normalizedMode {
		case "RapidTransit", "Train", "LocalTrain":
			normalizedMode = "RER"
		case "Metro", "Métro", "Subway":
			normalizedMode = "Metro"
		case "Bus":
			normalizedMode = "Bus"
		case "Tramway", "Tram":
			normalizedMode = "Tramway"
		}

		key := fmt.Sprintf("%s_%s", dep.DisplayInformations.Code, normalizedMode)
		to := dep.DisplayInformations.Direction
		if to == "" {
			to = dep.StopPoint.Name
		}

		if existing, ok := grouped[key]; ok {
			dirFound := false
			for i, dir := range existing.Directions {
				if dir.Name == to {
					dirFound = true
					if len(dir.Times) < 1 {
						isDup := false
						for _, t := range dir.Times {
							if t == timeStr {
								isDup = true
								break
							}
						}
						if !isDup {
							existing.Directions[i].Times = append(existing.Directions[i].Times, timeStr)
						}
					}
					break
				}
			}
			if !dirFound {
				existing.Directions = append(existing.Directions, dto.DirectionDTO{
					Name:  to,
					Times: []string{timeStr},
				})
			}
		} else {
			color := dep.DisplayInformations.Color
			if color != "" && len(color) == 6 {
				color = "FF" + color // Add alpha channel for Flutter (ARGB)
			}

			textColor := dep.DisplayInformations.TextColor
			if textColor != "" && len(textColor) == 6 {
				textColor = "FF" + textColor
			}
			
			latF, _ := strconv.ParseFloat(dep.StopPoint.Coord.Lat, 64)
			lonF, _ := strconv.ParseFloat(dep.StopPoint.Coord.Lon, 64)

			grouped[key] = &dto.DepartureDTO{
				Line:      dep.DisplayInformations.Code,
				Type:      normalizedMode,
				Color:     color,
				TextColor: textColor,
				StopId:    dep.StopPoint.Name,
				Lat:       latF,
				Lon:       lonF,
				Directions: []dto.DirectionDTO{
					{Name: to, Times: []string{timeStr}},
				},
			}
		}
	}

	var results []dto.DepartureDTO

	// Parcourir et normaliser les modes
	for _, val := range grouped {
		mode := val.Type
		// Garder tous les transports valides
		if mode == "Bus" || mode == "Metro" || mode == "RER" || mode == "Tramway" {
			results = append(results, *val)
		}
	}

	// Tri par mode pour toujours afficher dans un ordre prévisible
	sort.Slice(results, func(i, j int) bool {
		return results[i].Type < results[j].Type
	})

	return results, nil
}

func (s *DefaultTransportService) GetNearbyMapStops(lat, lon float64) ([]dto.MapStopDTO, error) {
	navitiaResp, err := s.repo.GetNearbyDepartures(lat, lon)
	if err != nil {
		return nil, err
	}

	loc, err := time.LoadLocation("Europe/Paris")
	if err != nil {
		loc = time.Local
	}
	now := time.Now().In(loc)

	// Group by StopArea Id
	stopMap := make(map[string]*dto.MapStopDTO)

	for _, dep := range navitiaResp.Departures {
		// Parsing de l'heure
		t, err := time.ParseInLocation("20060102T150405", dep.StopDateTime.DepartureDateTime, loc)
		var timeStr string
		if err == nil {
			diffMins := int(t.Sub(now).Minutes())
			if diffMins < 0 {
				continue // Déjà passé
			} else if diffMins == 0 {
				timeStr = "0 min"
			} else if diffMins < 60 {
				timeStr = fmt.Sprintf("%d min", diffMins)
			} else {
				timeStr = t.Format("15:04")
			}
		} else {
			timeStr = dep.StopDateTime.DepartureDateTime
		}

		modeName := dep.Route.Line.CommercialMode.Name
		if modeName == "" {
			modeName = "Transport"
		}
		
		normalizedMode := modeName
		switch normalizedMode {
		case "RapidTransit", "Train", "LocalTrain":
			normalizedMode = "RER"
		case "Metro", "Métro", "Subway":
			normalizedMode = "Metro"
		case "Bus":
			normalizedMode = "Bus"
		case "Tramway", "Tram":
			normalizedMode = "Tramway"
		}

        // Garder tous les transports valides
		if normalizedMode != "Bus" && normalizedMode != "Metro" && normalizedMode != "RER" && normalizedMode != "Tramway" {
			continue
		}

		stopAreaId := dep.StopPoint.Name

		if _, ok := stopMap[stopAreaId]; !ok {
			latF, _ := strconv.ParseFloat(dep.StopPoint.Coord.Lat, 64)
			lonF, _ := strconv.ParseFloat(dep.StopPoint.Coord.Lon, 64)
			stopMap[stopAreaId] = &dto.MapStopDTO{
				Id:         stopAreaId,
				Name:       dep.StopPoint.Name,
				Lat:        latF,
				Lon:        lonF,
				Departures: []dto.DepartureDTO{},
			}
		}

		stop := stopMap[stopAreaId]

		lineKey := fmt.Sprintf("%s_%s", dep.DisplayInformations.Code, normalizedMode)
		to := dep.DisplayInformations.Direction
		if to == "" {
			to = dep.StopPoint.Name
		}

		var targetDep *dto.DepartureDTO
		for i := range stop.Departures {
			key := fmt.Sprintf("%s_%s", stop.Departures[i].Line, stop.Departures[i].Type)
			if key == lineKey {
				targetDep = &stop.Departures[i]
				break
			}
		}

		var vjID string
		for _, link := range dep.Links {
			if link.Type == "vehicle_journey" {
				vjID = link.Id
				break
			}
		}

		if targetDep == nil {
			color := dep.DisplayInformations.Color
			if color != "" && len(color) == 6 {
				color = "FF" + color
			}
			textColor := dep.DisplayInformations.TextColor
			if textColor != "" && len(textColor) == 6 {
				textColor = "FF" + textColor
			}
			stop.Departures = append(stop.Departures, dto.DepartureDTO{
				Line:      dep.DisplayInformations.Code,
				Type:      normalizedMode,
				Color:     color,
				TextColor: textColor,
				Directions: []dto.DirectionDTO{
					{Name: to, Times: []string{timeStr}, VehicleJourneyId: vjID},
				},
			})
		} else {
			dirFound := false
			for i, dir := range targetDep.Directions {
				if dir.Name == to {
					dirFound = true
					if len(dir.Times) < 1 { // On limite à 1 passage max
						isDup := false
						for _, ex := range dir.Times {
							if ex == timeStr {
								isDup = true
							}
						}
						if !isDup {
							targetDep.Directions[i].Times = append(targetDep.Directions[i].Times, timeStr)
							if targetDep.Directions[i].VehicleJourneyId == "" {
								targetDep.Directions[i].VehicleJourneyId = vjID
							}
						}
					}
					break
				}
			}
			if !dirFound {
				targetDep.Directions = append(targetDep.Directions, dto.DirectionDTO{
					Name: to, Times: []string{timeStr}, VehicleJourneyId: vjID,
				})
			}
		}
	}

	var results []dto.MapStopDTO
	for _, val := range stopMap {
        if val.Name == "" {
            val.Name = "Arrêt inconnu"
        }
		results = append(results, *val)
	}

	return results, nil
}

func (s *DefaultTransportService) GetVehicleJourney(id string) (*dto.VehicleJourneyDTO, error) {
	resp, err := s.repo.GetVehicleJourney(id)
	if err != nil {
		return nil, err
	}
	if len(resp.VehicleJourneys) == 0 {
		return nil, fmt.Errorf("vehicle_journey not found")
	}

	vj := resp.VehicleJourneys[0]
	var stopTimes []dto.StopTimeDTO
	for _, st := range vj.StopTimes {
		timeStr := st.ArrivalTime
		if len(timeStr) == 15 { // Format: YYYYMMDDTHHMMSS
			timeStr = timeStr[9:11] + ":" + timeStr[11:13]
		}
		lat, _ := strconv.ParseFloat(st.StopPoint.Coord.Lat, 64)
		lon, _ := strconv.ParseFloat(st.StopPoint.Coord.Lon, 64)
		
		stopTimes = append(stopTimes, dto.StopTimeDTO{
			StopName: st.StopPoint.Name,
			Time:     timeStr,
			Lat:      lat,
			Lon:      lon,
		})
	}

	return &dto.VehicleJourneyDTO{
		Id:        vj.Id,
		StopTimes: stopTimes,
	}, nil
}

func (s *DefaultTransportService) SearchPlaces(query string) ([]dto.PlaceDTO, error) {
	resp, err := s.repo.SearchPlaces(query)
	if err != nil {
		return nil, err
	}

	var places []dto.PlaceDTO
	for _, p := range resp.Places {
		var lat, lon float64
		if p.StopArea != nil {
			lat, _ = strconv.ParseFloat(p.StopArea.Coord.Lat, 64)
			lon, _ = strconv.ParseFloat(p.StopArea.Coord.Lon, 64)
		} else if p.StopPoint != nil {
			lat, _ = strconv.ParseFloat(p.StopPoint.Coord.Lat, 64)
			lon, _ = strconv.ParseFloat(p.StopPoint.Coord.Lon, 64)
		} else if p.AdminRegion != nil {
			lat, _ = strconv.ParseFloat(p.AdminRegion.Coord.Lat, 64)
			lon, _ = strconv.ParseFloat(p.AdminRegion.Coord.Lon, 64)
		}

		places = append(places, dto.PlaceDTO{
			Id:   p.Id,
			Name: p.Name,
			Type: p.EmbeddedType,
			Lat:  lat,
			Lon:  lon,
		})
	}
	return places, nil
}

func (s *DefaultTransportService) GetDisruptions(lat, lon float64) ([]dto.NavitiaDisruption, error) {
	resp, err := s.repo.GetDisruptions(lat, lon)
	if err != nil {
		return nil, err
	}
	return resp.Disruptions, nil
}

func (s *DefaultTransportService) GetJourneys(from, to string) ([]dto.JourneyDTO, error) {
	resp, err := s.repo.GetJourneys(from, to)
	if err != nil {
		return nil, err
	}
	if len(resp.Journeys) == 0 {
		return nil, fmt.Errorf("aucun itinéraire trouvé")
	}

	var results []dto.JourneyDTO

	for _, j := range resp.Journeys {
		var sections []dto.SectionDTO
		for _, sec := range j.Sections {
			// Ignorer les sections "waiting" ou "crowding"
			if sec.Type == "waiting" || sec.Type == "crowding" {
				continue
			}
			
			color := sec.DisplayInformations.Color
			if color != "" && len(color) == 6 {
				color = "0xFF" + color
			} else if color == "" {
				color = "0xFF808080"
			}
			textColor := sec.DisplayInformations.TextColor
			if textColor != "" && len(textColor) == 6 {
				textColor = "0xFF" + textColor
			} else if textColor == "" {
				textColor = "0xFFFFFFFF"
			}

			sections = append(sections, dto.SectionDTO{
				Type:      sec.Type,
				Mode:      sec.Mode,
				Duration:  sec.Duration,
				Line:      sec.DisplayInformations.Code,
				Color:     color,
				TextColor: textColor,
				FromName:  sec.From.Name,
				ToName:    sec.To.Name,
			})
		}

		results = append(results, dto.JourneyDTO{
			Duration:    j.Duration,
			NbTransfers: j.NbTransfers,
			Sections:    sections,
		})
	}

	return results, nil
}
