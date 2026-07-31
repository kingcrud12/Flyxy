package dto

type MapStopDTO struct {
	Id         string         `json:"id"`
	Name       string         `json:"name"`
	Lat        float64        `json:"lat"`
	Lon        float64        `json:"lon"`
	Departures []DepartureDTO `json:"departures"`
}
