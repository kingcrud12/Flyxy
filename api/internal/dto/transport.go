package dto

type DepartureDTO struct {
	Line       string         `json:"line"`
	Type       string         `json:"type"`
	Color      string         `json:"color"`
	TextColor  string         `json:"text_color"`
	Directions []DirectionDTO `json:"directions"`
	StopId     string         `json:"stop_id,omitempty"`
	Lat        float64        `json:"lat,omitempty"`
	Lon        float64        `json:"lon,omitempty"`
}

type DirectionDTO struct {
	Name             string   `json:"name"`
	Times            []string `json:"times"`
	VehicleJourneyId string   `json:"vehicle_journey_id,omitempty"`
}

type VehicleJourneyDTO struct {
	Id        string        `json:"id"`
	StopTimes []StopTimeDTO `json:"stop_times"`
}

type StopTimeDTO struct {
	StopName string  `json:"stop_name"`
	Time     string  `json:"time"`
	Lat      float64 `json:"lat"`
	Lon      float64 `json:"lon"`
}

type PlaceDTO struct {
	Id   string  `json:"id"`
	Name string  `json:"name"`
	Type string  `json:"type"`
	Lat  float64 `json:"lat,omitempty"`
	Lon  float64 `json:"lon,omitempty"`
}

type JourneyDTO struct {
	Duration    int          `json:"duration"`
	NbTransfers int          `json:"nb_transfers"`
	Sections    []SectionDTO `json:"sections"`
}

type SectionDTO struct {
	Type      string `json:"type"`
	Mode      string `json:"mode"`
	Duration  int    `json:"duration"`
	Line      string `json:"line,omitempty"`
	Color     string `json:"color,omitempty"`
	TextColor string `json:"text_color,omitempty"`
	FromName  string `json:"from_name"`
	ToName    string `json:"to_name"`
}
