package compute

import (
	"armforge/internal/catalog"
	"armforge/internal/models"
	"armforge/internal/services"
)

type MetaDTO struct {
	Groups        []catalog.Group    `json:"groups"`
	Exercises     []catalog.Exercise `json:"exercises"`
	Workouts      []catalog.Workout  `json:"workouts"`
	Moods         []string           `json:"moods"`
	MoodLabels    []string           `json:"moodLabels"`
	FatigueColors []string           `json:"fatigueColors"`
}

func buildMeta() MetaDTO {
	return MetaDTO{
		Groups:        catalog.Groups,
		Exercises:     catalog.Exercises,
		Workouts:      catalog.Workouts,
		Moods:         catalog.Moods,
		MoodLabels:    catalog.MoodLabels,
		FatigueColors: catalog.FatigueColors,
	}
}

type SetDTO struct {
	Arm    string  `json:"arm"`
	Weight float64 `json:"weight"`
	Reps   float64 `json:"reps"`
}

type EntryDTO struct {
	ExerciseID   string   `json:"exId"`
	ExerciseName string   `json:"exerciseName"`
	Unit         string   `json:"unit"`
	GroupID      string   `json:"groupId"`
	GroupColor   string   `json:"groupColor"`
	Notes        string   `json:"notes"`
	Sets         []SetDTO `json:"sets"`
}

type SessionDTO struct {
	ID           string     `json:"id"`
	Date         string     `json:"date"`
	WorkoutIdx   int        `json:"workoutIdx"`
	WorkoutName  string     `json:"workoutName"`
	WorkoutColor string     `json:"workoutColor"`
	Duration     *int       `json:"duration"`
	Mood         *int       `json:"mood"`
	MoodEmoji    *string    `json:"moodEmoji"`
	MoodLabel    *string    `json:"moodLabel"`
	Fatigue      *int       `json:"fatigue"`
	FatigueColor *string    `json:"fatigueColor"`
	RPE          *int       `json:"rpe"`
	Notes        string     `json:"notes"`
	Tags         []string   `json:"tags"`
	Entries      []EntryDTO `json:"entries"`
	Score        int        `json:"score"`
	ScoreColor   string     `json:"scoreColor"`
	Volume       float64    `json:"volume"`
	SetsCount    int        `json:"setsCount"`
}

func entryToDTO(e models.Entry) EntryDTO {
	ex := catalog.ExerciseByID(e.ExerciseID)
	dto := EntryDTO{ExerciseID: e.ExerciseID, Notes: e.Notes}
	sets := make([]SetDTO, 0, len(e.Sets))
	for _, s := range e.Sets {
		sets = append(sets, SetDTO{Arm: s.Arm, Weight: s.Weight, Reps: s.Reps})
	}
	dto.Sets = sets
	if ex != nil {
		dto.ExerciseName = ex.Name
		dto.Unit = ex.Unit
		dto.GroupID = ex.Group
		if g := catalog.GroupByID(ex.Group); g != nil {
			dto.GroupColor = g.Color
		}
	}
	return dto
}

func sessionToDTO(s models.Session, all []models.Session) SessionDTO {
	entries := make([]EntryDTO, 0, len(s.Entries))
	for _, e := range s.Entries {
		entries = append(entries, entryToDTO(e))
	}
	score := services.PerfScore(all, s)
	dto := SessionDTO{
		ID:           s.ID,
		Date:         s.Date,
		WorkoutIdx:   s.WorkoutIdx,
		WorkoutName:  workoutName(s.WorkoutIdx),
		WorkoutColor: catalog.WorkoutColor(s.WorkoutIdx),
		Duration:     s.Duration,
		RPE:          s.RPE,
		Notes:        s.Notes,
		Tags:         s.Tags,
		Entries:      entries,
		Score:        score,
		ScoreColor:   services.ScoreColor(score),
		Volume:       services.SessionVolume(s),
		SetsCount:    services.SessionSets(s),
	}
	if s.Mood != nil && *s.Mood >= 0 && *s.Mood < len(catalog.Moods) {
		emoji := catalog.Moods[*s.Mood]
		label := catalog.MoodLabels[*s.Mood]
		dto.Mood = s.Mood
		dto.MoodEmoji = &emoji
		dto.MoodLabel = &label
	}
	if s.Fatigue != nil && *s.Fatigue >= 1 && *s.Fatigue <= len(catalog.FatigueColors) {
		color := catalog.FatigueColors[*s.Fatigue-1]
		dto.Fatigue = s.Fatigue
		dto.FatigueColor = &color
	}
	if dto.Tags == nil {
		dto.Tags = []string{}
	}
	return dto
}

func workoutName(idx int) string {
	if idx < 0 || idx >= len(catalog.Workouts) {
		return ""
	}
	return catalog.Workouts[idx].Name
}

type GoalDTO struct {
	ID           string  `json:"id"`
	ExerciseID   string  `json:"exId"`
	ExerciseName string  `json:"exerciseName"`
	Arm          string  `json:"arm"`
	Target       float64 `json:"target"`
	Current      float64 `json:"current"`
	Pct          int     `json:"pct"`
}

func goalToDTO(g models.Goal, sessions []models.Session) GoalDTO {
	ex := catalog.ExerciseByID(g.ExerciseID)
	name := ""
	if ex != nil {
		name = ex.Name
	}
	return GoalDTO{
		ID:           g.ID,
		ExerciseID:   g.ExerciseID,
		ExerciseName: name,
		Arm:          g.Arm,
		Target:       g.Target,
		Current:      services.BestForArm(sessions, g.ExerciseID, g.Arm, ""),
		Pct:          services.GoalProgressPct(sessions, g.ExerciseID, g.Arm, g.Target),
	}
}

type ExerciseRowDTO struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	GroupID     string  `json:"groupId"`
	GroupColor  string  `json:"groupColor"`
	Unit        string  `json:"unit"`
	LastDate    *string `json:"lastDate"`
	CurR        float64 `json:"curR"`
	CurL        float64 `json:"curL"`
	Volume      float64 `json:"volume"`
	BestR       float64 `json:"bestR"`
	BestL       float64 `json:"bestL"`
	IsPR        bool    `json:"isPr"`
	ProgressPct *int    `json:"progressPct"`
}

type ExerciseDetailDTO struct {
	Exercise            catalog.Exercise         `json:"exercise"`
	GroupColor          string                   `json:"groupColor"`
	StrengthProgression []services.StrengthPoint `json:"strengthProgression"`
	History             []ExerciseHistoryItemDTO `json:"history"`
}

type ExerciseHistoryItemDTO struct {
	Date  string   `json:"date"`
	Sets  []SetDTO `json:"sets"`
	Notes string   `json:"notes"`
	TopR  float64  `json:"topR"`
	TopL  float64  `json:"topL"`
}

type BodyweightDTO struct {
	Date string  `json:"date"`
	Kg   float64 `json:"kg"`
}

type SettingsDTO struct {
	Name       string          `json:"name"`
	Tourney    string          `json:"tourney"`
	Demo       bool            `json:"demo"`
	Bodyweight []BodyweightDTO `json:"bodyweight"`
}

type ArmBalanceDTO struct {
	SumR float64 `json:"sumR"`
	SumL float64 `json:"sumL"`
	PctL int     `json:"pctL"`
}

type RecoveryRowDTO struct {
	GroupID string `json:"groupId"`
	Name    string `json:"name"`
	Color   string `json:"color"`
	Pct     int    `json:"pct"`
	Days    *int   `json:"days"`
}

type WeekPointDTO struct {
	WeekStart string  `json:"weekStart"`
	Volume    float64 `json:"volume"`
}

type DashboardDTO struct {
	Name              string           `json:"name"`
	NextWorkoutIdx    int              `json:"nextWorkoutIdx"`
	NextWorkoutName   string           `json:"nextWorkoutName"`
	TourneyDate       string           `json:"tourneyDate"`
	DaysToTourney     *int             `json:"daysToTourney"`
	WeekSessionsCount int              `json:"weekSessionsCount"`
	WeekVolume        float64          `json:"weekVolume"`
	WeekSets          int              `json:"weekSets"`
	StreakWeeks       int              `json:"streakWeeks"`
	ArmBalance        ArmBalanceDTO    `json:"armBalance"`
	RecentPRs         []PRDTO          `json:"recentPrs"`
	Recovery          []RecoveryRowDTO `json:"recovery"`
	Bodyweight        []BodyweightDTO  `json:"bodyweight"`
	WeeklyTonnage     []WeekPointDTO   `json:"weeklyTonnage"`
	RecentSessions    []SessionDTO     `json:"recentSessions"`
	IsDemo            bool             `json:"isDemo"`
}

type PRDTO struct {
	ExerciseID   string  `json:"exId"`
	ExerciseName string  `json:"exerciseName"`
	Arm          string  `json:"arm"`
	Weight       float64 `json:"weight"`
	Date         string  `json:"date"`
}

type LogExerciseDTO struct {
	ExerciseID  string  `json:"exId"`
	Name        string  `json:"name"`
	Unit        string  `json:"unit"`
	BestR       float64 `json:"bestR"`
	BestL       float64 `json:"bestL"`
	LastWeightR float64 `json:"lastWeightR"`
	LastWeightL float64 `json:"lastWeightL"`
}

type LogInitDTO struct {
	WorkoutIdx int              `json:"workoutIdx"`
	Exercises  []LogExerciseDTO `json:"exercises"`
}

type CreateSetRequest struct {
	Arm    string      `json:"arm"`
	Weight interface{} `json:"weight"`
	Reps   interface{} `json:"reps"`
}

type CreateEntryRequest struct {
	ExerciseID string             `json:"exId"`
	Sets       []CreateSetRequest `json:"sets"`
}

type CreateSessionRequest struct {
	Date       string               `json:"date"`
	WorkoutIdx int                  `json:"workoutIdx"`
	Duration   *int                 `json:"duration"`
	Mood       *int                 `json:"mood"`
	Fatigue    *int                 `json:"fatigue"`
	RPE        *int                 `json:"rpe"`
	Notes      string               `json:"notes"`
	Tags       []string             `json:"tags"`
	Entries    []CreateEntryRequest `json:"entries"`
}

type CreateGoalRequest struct {
	ExerciseID string  `json:"exId"`
	Arm        string  `json:"arm"`
	Target     float64 `json:"target"`
}

type UpdateSettingsRequest struct {
	Name    *string `json:"name"`
	Tourney *string `json:"tourney"`
}

type AddBodyweightRequest struct {
	Kg float64 `json:"kg"`
}
