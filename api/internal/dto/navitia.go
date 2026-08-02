package dto

// NavitiaDisruption represents an incident or disruption
type NavitiaDisruption struct {
	ID       string `json:"id"`
	Status   string `json:"status"` // "active", "past", "future"
	Severity struct {
		Name   string `json:"name"`
		Effect string `json:"effect"`
		Color  string `json:"color"`
	} `json:"severity"`
	Messages []struct {
		Text string `json:"text"`
	} `json:"messages"`
	ImpactedObjects []struct {
		PtObject struct {
			Line *struct {
				Name string `json:"name"`
				Code string `json:"code"`
				Network struct {
					Name string `json:"name"`
				} `json:"network"`
			} `json:"line"`
		} `json:"pt_object"`
	} `json:"impacted_objects"`
}

type NavitiaDisruptionsResponse struct {
	Disruptions []NavitiaDisruption `json:"disruptions"`
}

type NavitiaDeparturesResponse struct {
	Departures []NavitiaDeparture `json:"departures"`
}

type NavitiaDeparture struct {
	StopPoint           NavitiaStopPoint    `json:"stop_point"`
	Route               NavitiaRoute        `json:"route"`
	DisplayInformations NavitiaDisplayInfo  `json:"display_informations"`
	StopDateTime        NavitiaStopDateTime `json:"stop_date_time"`
	Links               []NavitiaLink       `json:"links"`
}

type NavitiaLink struct {
	Type  string `json:"type"`
	Id    string `json:"id"`
	Value string `json:"value"`
}

type NavitiaStopPoint struct {
	Name  string          `json:"name"`
	Coord NavitiaCoord    `json:"coord"`
}

type NavitiaStopArea struct {
	Id    string       `json:"id"`
	Name  string       `json:"name"`
	Coord NavitiaCoord `json:"coord"`
}

type NavitiaCoord struct {
	Lat string `json:"lat"`
	Lon string `json:"lon"`
}

type NavitiaAdminRegion struct {
	Id    string       `json:"id"`
	Name  string       `json:"name"`
	Coord NavitiaCoord `json:"coord"`
}

type NavitiaRoute struct {
	Name string      `json:"name"`
	Line NavitiaLine `json:"line"`
}

type NavitiaLine struct {
	Code           string `json:"code"`
	Color          string `json:"color"`
	CommercialMode struct {
		Name string `json:"name"`
	} `json:"commercial_mode"`
}

type NavitiaDisplayInfo struct {
	Direction string `json:"direction"`
	Code      string `json:"code"`
	Color     string `json:"color"`
	TextColor string `json:"text_color"`
}

type NavitiaStopDateTime struct {
	DepartureDateTime string `json:"departure_date_time"` // Format: YYYYMMDDTHHMMSS
}

type NavitiaVehicleJourneysResponse struct {
	VehicleJourneys []NavitiaVehicleJourney `json:"vehicle_journeys"`
}

type NavitiaVehicleJourney struct {
	Id        string            `json:"id"`
	Name      string            `json:"name"`
	StopTimes []NavitiaStopTime `json:"stop_times"`
}

type NavitiaStopTime struct {
	StopPoint    NavitiaStopPoint `json:"stop_point"`
	ArrivalTime  string           `json:"arrival_time"`
}

type NavitiaPlacesResponse struct {
	Places []NavitiaPlace `json:"places"`
}

type NavitiaPlace struct {
	Id           string            `json:"id"`
	Name         string            `json:"name"`
	EmbeddedType string            `json:"embedded_type"`
	StopArea     *NavitiaStopArea   `json:"stop_area,omitempty"`
	StopPoint    *NavitiaStopPoint  `json:"stop_point,omitempty"`
	AdminRegion  *NavitiaAdminRegion `json:"administrative_region,omitempty"`
}

type NavitiaJourneysResponse struct {
	Journeys []NavitiaJourney `json:"journeys"`
}

type NavitiaJourney struct {
	Duration int            `json:"duration"`
	NbTransfers int         `json:"nb_transfers"`
	Type     string         `json:"type"`
	Sections []NavitiaSection `json:"sections"`
}

type NavitiaSection struct {
	Type     string         `json:"type"`
	Mode     string         `json:"mode"`
	Duration int            `json:"duration"`
	DisplayInformations NavitiaDisplayInfo `json:"display_informations"`
	From     NavitiaPlace   `json:"from"`
	To       NavitiaPlace   `json:"to"`
}
