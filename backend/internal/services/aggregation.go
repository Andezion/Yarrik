package services

import (
	"fmt"
	"math"
	"time"

	"armforge/internal/catalog"
	"armforge/internal/dateutil"
	"armforge/internal/models"
)

type WeekAgg struct {
	WeekStart string  `json:"weekStart"`
	Volume    float64 `json:"volume"`
}

func AggWeeks(sessions []models.Session, n int) []WeekAgg {
	byWeek := map[string]float64{}
	for _, s := range sessions {
		k := dateutil.WeekKey(dateutil.Parse(s.Date))
		byWeek[k] += SessionVolume(s)
	}
	now := time.Now()
	out := make([]WeekAgg, 0, n)
	for i := n - 1; i >= 0; i-- {
		d := now.AddDate(0, 0, -7*i)
		k := dateutil.WeekKey(d)
		out = append(out, WeekAgg{WeekStart: k, Volume: math.Round(byWeek[k])})
	}
	return out
}

type MonthAgg struct {
	Month  string  `json:"month"`
	Volume float64 `json:"volume"`
}

func AggMonths(sessions []models.Session, n int) []MonthAgg {
	byMonth := map[string]float64{}
	for _, s := range sessions {
		if len(s.Date) >= 7 {
			byMonth[s.Date[:7]] += SessionVolume(s)
		}
	}
	now := time.Now()
	out := make([]MonthAgg, 0, n)
	for i := n - 1; i >= 0; i-- {
		d := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location()).AddDate(0, -i, 0)
		k := fmt.Sprintf("%04d-%02d", d.Year(), int(d.Month()))
		out = append(out, MonthAgg{Month: k, Volume: math.Round(byMonth[k])})
	}
	return out
}

func GroupDistribution(sessions []models.Session) map[string]int {
	dist := map[string]int{}
	for _, s := range sessions {
		for _, e := range s.Entries {
			ex := catalog.ExerciseByID(e.ExerciseID)
			if ex == nil {
				continue
			}
			dist[ex.Group] += len(e.Sets)
		}
	}
	return dist
}
