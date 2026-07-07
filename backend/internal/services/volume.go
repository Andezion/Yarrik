package services

import (
	"armforge/internal/catalog"
	"armforge/internal/models"
)

func EntryVolume(e models.Entry, cat catalog.Catalog) float64 {
	ex := cat.ExerciseByID(e.ExerciseID)
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

func SessionVolume(s models.Session, cat catalog.Catalog) float64 {
	v := 0.0
	for _, e := range s.Entries {
		v += EntryVolume(e, cat)
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
