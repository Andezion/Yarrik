package services

import (
	"math"
	"time"

	"armforge/internal/catalog"
	"armforge/internal/dateutil"
	"armforge/internal/models"
	"armforge/internal/util"
)

func PerfScore(sessions []models.Session, s models.Session) int {
	sorted := SortedSessions(sessions)
	var same []models.Session
	for _, x := range sorted {
		if x.WorkoutIdx == s.WorkoutIdx && x.Date < s.Date {
			same = append(same, x)
		}
	}
	if len(same) > 5 {
		same = same[len(same)-5:]
	}
	vol := SessionVolume(s)
	if len(same) == 0 {
		if vol > 0 {
			return 75
		}
		return 0
	}
	sum := 0.0
	for _, x := range same {
		sum += SessionVolume(x)
	}
	avg := sum / float64(len(same))
	if avg == 0 {
		return 75
	}
	return util.Clamp(int(math.Round(75*vol/avg)), 35, 99)
}

func ScoreColor(v int) string {
	switch {
	case v >= 85:
		return "#2FA344"
	case v >= 70:
		return "#F2A93B"
	case v >= 55:
		return "#F5822E"
	default:
		return "#E8564E"
	}
}

func StreakWeeks(sessions []models.Session) int {
	if len(sessions) == 0 {
		return 0
	}
	weeks := map[string]bool{}
	for _, s := range sessions {
		weeks[dateutil.WeekKey(dateutil.Parse(s.Date))] = true
	}
	n := 0
	cur := time.Now()
	k := dateutil.WeekKey(cur)
	if !weeks[k] {
		cur = cur.AddDate(0, 0, -7)
		k = dateutil.WeekKey(cur)
	}
	for weeks[k] {
		n++
		cur = cur.AddDate(0, 0, -7)
		k = dateutil.WeekKey(cur)
	}
	return n
}

type Recovery struct {
	Pct  int  `json:"pct"`
	Days *int `json:"days"`
}

func RecoveryByGroup(sessions []models.Session) map[string]Recovery {
	res := map[string]Recovery{}
	today := dateutil.Today()
	sorted := SortedSessions(sessions)
	for _, g := range catalog.Groups {
		last := ""
		for _, s := range sorted {
			touched := false
			for _, e := range s.Entries {
				ex := catalog.ExerciseByID(e.ExerciseID)
				if ex != nil && ex.Group == g.ID {
					touched = true
					break
				}
			}
			if touched {
				last = s.Date
			}
		}
		if last == "" {
			res[g.ID] = Recovery{Pct: 100, Days: nil}
			continue
		}
		d := dateutil.DaysBetween(last, today)
		pct := util.Clamp(int(math.Round(float64(d)/3*100)), 8, 100)
		dCopy := d
		res[g.ID] = Recovery{Pct: pct, Days: &dCopy}
	}
	return res
}
