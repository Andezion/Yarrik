package services

import (
	"sort"

	"armforge/internal/models"
)

func SortedSessions(sessions []models.Session) []models.Session {
	out := make([]models.Session, len(sessions))
	copy(out, sessions)
	sort.SliceStable(out, func(i, j int) bool { return out[i].Date < out[j].Date })
	return out
}

func armOf(s models.Set) string {
	if s.Arm == "" {
		return "R"
	}
	return s.Arm
}

func BestForArm(sessions []models.Session, exerciseID, arm, beforeDate string) float64 {
	best := 0.0
	for _, s := range sessions {
		if beforeDate != "" && s.Date >= beforeDate {
			continue
		}
		for _, e := range s.Entries {
			if e.ExerciseID != exerciseID {
				continue
			}
			for _, st := range e.Sets {
				if armOf(st) == arm && st.Weight > best {
					best = st.Weight
				}
			}
		}
	}
	return best
}

type LastEntryResult struct {
	Date  string
	Entry models.Entry
}

func LastEntry(sessions []models.Session, exerciseID string) *LastEntryResult {
	var found *LastEntryResult
	for _, s := range SortedSessions(sessions) {
		for _, e := range s.Entries {
			if e.ExerciseID == exerciseID {
				found = &LastEntryResult{Date: s.Date, Entry: e}
			}
		}
	}
	return found
}

type PRRecord struct {
	ExerciseID string  `json:"exId"`
	Arm        string  `json:"arm"`
	Weight     float64 `json:"weight"`
	Date       string  `json:"date"`
}

func RecentPRs(sessions []models.Session, limit int) []PRRecord {
	out := []PRRecord{}
	seen := map[string]bool{}
	sorted := SortedSessions(sessions)

	for i := len(sorted) - 1; i >= 0; i-- {
		s := sorted[i]
		for _, e := range s.Entries {
			for _, arm := range [2]string{"R", "L"} {
				top := 0.0
				for _, st := range e.Sets {
					if armOf(st) == arm && st.Weight > top {
						top = st.Weight
					}
				}
				if top == 0 {
					continue
				}
				prev := BestForArm(sessions, e.ExerciseID, arm, s.Date)
				key := e.ExerciseID + arm
				if top > prev && !seen[key] {
					seen[key] = true
					out = append(out, PRRecord{ExerciseID: e.ExerciseID, Arm: arm, Weight: top, Date: s.Date})
				}
			}
		}
		if len(out) >= limit {
			break
		}
	}
	if len(out) > limit {
		out = out[:limit]
	}
	return out
}
