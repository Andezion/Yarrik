package services

import (
	"math"

	"armforge/internal/dateutil"
	"armforge/internal/models"
	"armforge/internal/util"
)

func ExerciseProgressPct(sessions []models.Session, exerciseID string) *int {
	agoISO := dateutil.Format(dateutil.Parse(dateutil.Today()).AddDate(0, 0, -28))
	oldBest := math.Max(
		BestForArm(sessions, exerciseID, "R", agoISO),
		BestForArm(sessions, exerciseID, "L", agoISO),
	)
	if oldBest == 0 {
		return nil
	}
	nowBest := math.Max(
		BestForArm(sessions, exerciseID, "R", ""),
		BestForArm(sessions, exerciseID, "L", ""),
	)
	p := int(math.Round((nowBest - oldBest) / oldBest * 100))
	return &p
}

func GoalProgressPct(sessions []models.Session, exerciseID, arm string, target float64) int {
	if target == 0 {
		return 0
	}
	cur := BestForArm(sessions, exerciseID, arm, "")
	return util.Clamp(int(math.Round(cur/target*100)), 0, 100)
}

type StrengthPoint struct {
	Date string  `json:"date"`
	TopR float64 `json:"topR"`
	TopL float64 `json:"topL"`
}

func StrengthProgression(sessions []models.Session, exerciseID string) []StrengthPoint {
	out := []StrengthPoint{}
	for _, s := range SortedSessions(sessions) {
		for _, e := range s.Entries {
			if e.ExerciseID != exerciseID {
				continue
			}
			tR, tL := 0.0, 0.0
			for _, st := range e.Sets {
				w := st.Weight
				if armOf(st) == "R" {
					if w > tR {
						tR = w
					}
				} else if w > tL {
					tL = w
				}
			}
			out = append(out, StrengthPoint{Date: s.Date, TopR: tR, TopL: tL})
		}
	}
	return out
}

func SessionsWithFatigue(sessions []models.Session, limit int) []models.Session {
	out := []models.Session{}
	for _, s := range SortedSessions(sessions) {
		if s.Fatigue != nil {
			out = append(out, s)
		}
	}
	if len(out) > limit {
		out = out[len(out)-limit:]
	}
	return out
}

func ArmBalance(sessions []models.Session, exerciseIDs []string) (sumR, sumL float64) {
	for _, id := range exerciseIDs {
		sumR += BestForArm(sessions, id, "R", "")
		sumL += BestForArm(sessions, id, "L", "")
	}
	return
}
