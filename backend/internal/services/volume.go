package services

import (
	"armforge/internal/catalog"
	"armforge/internal/models"
)

func EntryVolume(e models.Entry) float64 {
	ex := catalog.ExerciseByID(e.ExerciseID)
	v := 0.0
	for _, s := range e.Sets {
		if ex != nil && ex.Unit == "sec" {
			v += s.Weight * s.Reps / 10
		} else {
			v += s.Weight * s.Reps
		}
	}
	return v
}

func SessionVolume(s models.Session) float64 {
	v := 0.0
	for _, e := range s.Entries {
		v += EntryVolume(e)
	}
	return v
}

func SessionSets(s models.Session) int {
	n := 0
	for _, e := range s.Entries {
		n += len(e.Sets)
	}
	return n
}
