package services

import (
	"encoding/json"
	"sort"

	"armforge/internal/catalog"
	"armforge/internal/models"
	"armforge/internal/util"
)

type ImportResult struct {
	Name     string              `json:"name"`
	Cursor   int                 `json:"cursor"`
	Sessions []models.Session    `json:"sessions"`
	BW       []models.Bodyweight `json:"bw"`
	Goals    []models.Goal       `json:"goals"`
	Tourney  string              `json:"tourney"`
}

func ImportAny(raw map[string]json.RawMessage, current models.AppState) (ImportResult, bool) {
	if sessionsRaw, has := raw["sessions"]; has {
		var sessions []models.Session
		if err := json.Unmarshal(sessionsRaw, &sessions); err != nil {
			return ImportResult{}, false
		}
		res := ImportResult{
			Name:     current.Name,
			Cursor:   0,
			Sessions: sessions,
			Tourney:  current.Tourney,
		}
		if v, ok := raw["name"]; ok {
			_ = json.Unmarshal(v, &res.Name)
		}
		if v, ok := raw["cursor"]; ok {
			_ = json.Unmarshal(v, &res.Cursor)
		}
		if v, ok := raw["bw"]; ok {
			_ = json.Unmarshal(v, &res.BW)
		}
		if v, ok := raw["goals"]; ok {
			_ = json.Unmarshal(v, &res.Goals)
		}
		if v, ok := raw["tourney"]; ok {
			_ = json.Unmarshal(v, &res.Tourney)
		}
		return res, true
	}

	if logsRaw, has := raw["logs"]; has {
		sessions, ok := importLegacyLogs(logsRaw)
		if !ok {
			return ImportResult{}, false
		}
		return ImportResult{
			Name:     current.Name,
			Cursor:   current.Cursor,
			Sessions: sessions,
			BW:       current.BW,
			Goals:    current.Goals,
			Tourney:  current.Tourney,
		}, true
	}

	return ImportResult{}, false
}

type legacyLog struct {
	Date  string `json:"date"`
	ExID  string `json:"exId"`
	Notes string `json:"notes"`
	Sets  []struct {
		Arm    string      `json:"arm"`
		Weight interface{} `json:"weight"`
		Reps   interface{} `json:"reps"`
	} `json:"sets"`
}

func importLegacyLogs(raw json.RawMessage) ([]models.Session, bool) {
	var logs []legacyLog
	if err := json.Unmarshal(raw, &logs); err != nil {
		return nil, false
	}

	byDate := map[string][]legacyLog{}
	for _, l := range logs {
		byDate[l.Date] = append(byDate[l.Date], l)
	}
	dates := make([]string, 0, len(byDate))
	for d := range byDate {
		dates = append(dates, d)
	}
	sort.Strings(dates)

	sessions := make([]models.Session, 0, len(dates))
	for _, date := range dates {
		dayLogs := byDate[date]
		entries := make([]models.Entry, 0, len(dayLogs))
		ids := make([]string, 0, len(dayLogs))
		for _, l := range dayLogs {
			sets := make([]models.Set, 0, len(l.Sets))
			for _, s := range l.Sets {
				arm := s.Arm
				if arm == "" {
					arm = "R"
				}
				sets = append(sets, models.Set{Arm: arm, Weight: util.Num(s.Weight), Reps: util.Num(s.Reps)})
			}
			entries = append(entries, models.Entry{ExerciseID: l.ExID, Notes: l.Notes, Sets: sets})
			ids = append(ids, l.ExID)
		}
		sessions = append(sessions, models.Session{
			ID:         util.NewID(),
			Date:       date,
			WorkoutIdx: catalog.BestMatchingWorkout(ids),
			Notes:      "",
			Tags:       []string{},
			Entries:    entries,
		})
	}
	return sessions, true
}
