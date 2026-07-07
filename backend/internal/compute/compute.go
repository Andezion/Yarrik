package compute

import (
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"armforge/internal/catalog"
	"armforge/internal/dateutil"
	"armforge/internal/models"
	"armforge/internal/services"
	"armforge/internal/util"
)

func Meta() MetaDTO {
	return buildMeta()
}

func Dashboard(st models.AppState) DashboardDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	sessions := st.Sessions

	today := dateutil.Today()
	wk := dateutil.WeekKey(dateutil.Parse(today))
	var weekSessions []models.Session
	for _, s := range sessions {
		if dateutil.WeekKey(dateutil.Parse(s.Date)) == wk {
			weekSessions = append(weekSessions, s)
		}
	}
	weekVol, weekSets := 0.0, 0
	for _, s := range weekSessions {
		weekVol += services.SessionVolume(s, cat)
		weekSets += services.SessionSets(s)
	}

	var daysToTourney *int
	if st.Tourney != "" {
		d := dateutil.DaysBetween(today, st.Tourney)
		if d >= 0 {
			daysToTourney = &d
		}
	}

	exIDs := make([]string, len(cat.Exercises))
	for i, ex := range cat.Exercises {
		exIDs[i] = ex.ID
	}
	sumR, sumL := services.ArmBalance(sessions, exIDs)
	pctL := 50
	if sumR+sumL > 0 {
		pctL = int(math.Round(sumL / (sumR + sumL) * 100))
	}

	prs := services.RecentPRs(sessions, 4)
	prDTOs := make([]PRDTO, 0, len(prs))
	for _, pr := range prs {
		name := pr.ExerciseID
		if ex := cat.ExerciseByID(pr.ExerciseID); ex != nil {
			name = ex.Name
		}
		prDTOs = append(prDTOs, PRDTO{ExerciseID: pr.ExerciseID, ExerciseName: name, Arm: pr.Arm, Weight: pr.Weight, Date: pr.Date})
	}

	recoveryMap := services.RecoveryByGroup(sessions, cat)
	recoveryRows := make([]RecoveryRowDTO, 0, len(catalog.Groups))
	for _, g := range catalog.Groups {
		rec := recoveryMap[g.ID]
		recoveryRows = append(recoveryRows, RecoveryRowDTO{GroupID: g.ID, Name: g.Name, Color: g.Color, Pct: rec.Pct, Days: rec.Days})
	}

	bwDTOs := make([]BodyweightDTO, 0, len(st.BW))
	for _, b := range st.BW {
		bwDTOs = append(bwDTOs, BodyweightDTO{Date: b.Date, Kg: b.Kg})
	}

	weeks := services.AggWeeks(sessions, 10, cat)
	weekDTOs := make([]WeekPointDTO, 0, len(weeks))
	for _, wpt := range weeks {
		weekDTOs = append(weekDTOs, WeekPointDTO{WeekStart: wpt.WeekStart, Volume: wpt.Volume})
	}

	sorted := services.SortedSessions(sessions)
	recentCount := 3
	if len(sorted) < recentCount {
		recentCount = len(sorted)
	}
	recent := sorted[len(sorted)-recentCount:]
	recentDTOs := make([]SessionDTO, 0, len(recent))
	for i := len(recent) - 1; i >= 0; i-- {
		recentDTOs = append(recentDTOs, sessionToDTO(recent[i], sessions, cat))
	}

	nextIdx := util.Clamp(st.Cursor%len(cat.Workouts), 0, len(cat.Workouts)-1)

	return DashboardDTO{
		Name:              st.Name,
		NextWorkoutIdx:    nextIdx,
		NextWorkoutName:   cat.Workouts[nextIdx].Name,
		TourneyDate:       st.Tourney,
		DaysToTourney:     daysToTourney,
		WeekSessionsCount: len(weekSessions),
		WeekVolume:        weekVol,
		WeekSets:          weekSets,
		StreakWeeks:       services.StreakWeeks(sessions),
		ArmBalance:        ArmBalanceDTO{SumR: sumR, SumL: sumL, PctL: pctL},
		RecentPRs:         prDTOs,
		Recovery:          recoveryRows,
		Bodyweight:        bwDTOs,
		WeeklyTonnage:     weekDTOs,
		RecentSessions:    recentDTOs,
	}
}

type SessionsFilter struct {
	Query      string
	WorkoutIdx *int
	GroupID    string
}

func Sessions(st models.AppState, f SessionsFilter) []SessionDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	sessions := st.Sessions
	q := strings.ToLower(strings.TrimSpace(f.Query))

	sorted := services.SortedSessions(sessions)
	out := make([]SessionDTO, 0, len(sorted))
	for i := len(sorted) - 1; i >= 0; i-- {
		s := sorted[i]
		if f.WorkoutIdx != nil && s.WorkoutIdx != *f.WorkoutIdx {
			continue
		}
		if f.GroupID != "" && !sessionTouchesGroup(s, f.GroupID, cat) {
			continue
		}
		if q != "" && !sessionMatchesQuery(s, q, cat) {
			continue
		}
		out = append(out, sessionToDTO(s, sessions, cat))
	}
	return out
}

func SessionsOnDate(st models.AppState, date string) []SessionDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	out := []SessionDTO{}
	for _, s := range st.Sessions {
		if s.Date == date {
			out = append(out, sessionToDTO(s, st.Sessions, cat))
		}
	}
	return out
}

func sessionTouchesGroup(s models.Session, group string, cat catalog.Catalog) bool {
	for _, e := range s.Entries {
		if ex := cat.ExerciseByID(e.ExerciseID); ex != nil && ex.Group == group {
			return true
		}
	}
	return false
}

func sessionMatchesQuery(s models.Session, q string, cat catalog.Catalog) bool {
	hay := strings.ToLower(s.Notes + " " + strings.Join(s.Tags, " "))
	for _, e := range s.Entries {
		if ex := cat.ExerciseByID(e.ExerciseID); ex != nil {
			hay += " " + strings.ToLower(ex.Name)
		}
	}
	return strings.Contains(hay, q)
}

type BuildSessionResult struct {
	Session   models.Session `json:"session"`
	NewCursor int            `json:"newCursor"`
}

func BuildSession(st models.AppState, req CreateSessionRequest, currentCursor int) (BuildSessionResult, error) {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	if req.WorkoutIdx < 0 || req.WorkoutIdx >= len(cat.Workouts) {
		return BuildSessionResult{}, errors.New("invalid workoutIdx")
	}
	if req.Date == "" {
		return BuildSessionResult{}, errors.New("date is required")
	}

	entries := make([]models.Entry, 0, len(req.Entries))
	for _, e := range req.Entries {
		sets := make([]models.Set, 0, len(e.Sets))
		for _, s := range e.Sets {
			weight := util.Num(s.Weight)
			reps := util.Num(s.Reps)
			if weight == 0 || reps == 0 {
				continue
			}
			arm := s.Arm
			if arm == "" {
				arm = "R"
			}
			sets = append(sets, models.Set{Arm: arm, Weight: weight, Reps: reps})
		}
		if len(sets) > 0 {
			entries = append(entries, models.Entry{ExerciseID: e.ExerciseID, Sets: sets, Notes: ""})
		}
	}
	if len(entries) == 0 {
		return BuildSessionResult{}, errors.New("fill in at least one set")
	}

	tags := req.Tags
	if tags == nil {
		tags = []string{}
	}

	session := models.Session{
		ID:         util.NewID(),
		Date:       req.Date,
		WorkoutIdx: req.WorkoutIdx,
		Duration:   req.Duration,
		Mood:       req.Mood,
		Fatigue:    req.Fatigue,
		RPE:        req.RPE,
		Notes:      strings.TrimSpace(req.Notes),
		Tags:       tags,
		Entries:    entries,
	}

	newCursor := currentCursor
	if req.WorkoutIdx == currentCursor%len(cat.Workouts) {
		newCursor = currentCursor + 1
	}

	return BuildSessionResult{Session: session, NewCursor: newCursor}, nil
}

type CalendarDayDTO struct {
	Date          string   `json:"date"`
	WorkoutColors []string `json:"workoutColors"`
}

type CalendarDTO struct {
	Year  int              `json:"year"`
	Month int              `json:"month"`
	Days  []CalendarDayDTO `json:"days"`
}

func Calendar(st models.AppState, year, month int) CalendarDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	byDate := map[string][]models.Session{}
	for _, s := range st.Sessions {
		byDate[s.Date] = append(byDate[s.Date], s)
	}

	daysInMonth := time.Date(year, time.Month(month)+1, 0, 0, 0, 0, 0, time.UTC).Day()
	days := make([]CalendarDayDTO, 0, len(byDate))
	for d := 1; d <= daysInMonth; d++ {
		date := dateutil.Format(time.Date(year, time.Month(month), d, 0, 0, 0, 0, time.UTC))
		sessions, ok := byDate[date]
		if !ok {
			continue
		}
		colors := make([]string, 0, len(sessions))
		for _, s := range sessions {
			colors = append(colors, cat.WorkoutColor(s.WorkoutIdx))
		}
		days = append(days, CalendarDayDTO{Date: date, WorkoutColors: colors})
	}

	return CalendarDTO{Year: year, Month: month, Days: days}
}

type FatiguePointDTO struct {
	Date    string `json:"date"`
	Fatigue int    `json:"fatigue"`
}

type GroupSliceDTO struct {
	GroupID string `json:"groupId"`
	Name    string `json:"name"`
	Color   string `json:"color"`
	Count   int    `json:"count"`
}

type StatsDTO struct {
	WeeklyTonnage       []WeekPointDTO           `json:"weeklyTonnage"`
	MonthlyTonnage      []services.MonthAgg      `json:"monthlyTonnage"`
	SelectedExerciseID  string                   `json:"selectedExerciseId"`
	StrengthProgression []services.StrengthPoint `json:"strengthProgression"`
	FatigueTrend        []FatiguePointDTO        `json:"fatigueTrend"`
	GroupDistribution   []GroupSliceDTO          `json:"groupDistribution"`
}

func Stats(st models.AppState, exerciseID string) StatsDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	sessions := st.Sessions
	if cat.ExerciseByID(exerciseID) == nil {
		exerciseID = cat.Exercises[0].ID
	}

	weeks := services.AggWeeks(sessions, 12, cat)
	weekDTOs := make([]WeekPointDTO, 0, len(weeks))
	for _, wpt := range weeks {
		weekDTOs = append(weekDTOs, WeekPointDTO{WeekStart: wpt.WeekStart, Volume: wpt.Volume})
	}

	months := services.AggMonths(sessions, 6, cat)
	strength := services.StrengthProgression(sessions, exerciseID)

	fatigueSessions := services.SessionsWithFatigue(sessions, 15)
	fatiguePts := make([]FatiguePointDTO, 0, len(fatigueSessions))
	for _, s := range fatigueSessions {
		fatiguePts = append(fatiguePts, FatiguePointDTO{Date: s.Date, Fatigue: *s.Fatigue})
	}

	dist := services.GroupDistribution(sessions, cat)
	groupSlices := make([]GroupSliceDTO, 0, len(catalog.Groups))
	for _, g := range catalog.Groups {
		count := dist[g.ID]
		if count == 0 {
			continue
		}
		groupSlices = append(groupSlices, GroupSliceDTO{GroupID: g.ID, Name: g.Name, Color: g.Color, Count: count})
	}

	return StatsDTO{
		WeeklyTonnage:       weekDTOs,
		MonthlyTonnage:      months,
		SelectedExerciseID:  exerciseID,
		StrengthProgression: strength,
		FatigueTrend:        fatiguePts,
		GroupDistribution:   groupSlices,
	}
}

func ExercisesTable(st models.AppState) []ExerciseRowDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	sessions := st.Sessions
	rows := make([]ExerciseRowDTO, 0, len(cat.Exercises))
	for _, ex := range cat.Exercises {
		bR := services.BestForArm(sessions, ex.ID, "R", "")
		bL := services.BestForArm(sessions, ex.ID, "L", "")
		row := ExerciseRowDTO{
			ID:          ex.ID,
			Name:        ex.Name,
			GroupID:     ex.Group,
			Unit:        ex.Unit,
			BestR:       bR,
			BestL:       bL,
			ProgressPct: services.ExerciseProgressPct(sessions, ex.ID),
		}
		if g := catalog.GroupByID(ex.Group); g != nil {
			row.GroupColor = g.Color
		}

		if le := services.LastEntry(sessions, ex.ID); le != nil {
			date := le.Date
			row.LastDate = &date
			row.Volume = services.EntryVolume(le.Entry, cat)
			for _, s := range le.Entry.Sets {
				arm := s.Arm
				if arm == "" {
					arm = "R"
				}
				if arm == "R" && s.Weight > row.CurR {
					row.CurR = s.Weight
				} else if arm == "L" && s.Weight > row.CurL {
					row.CurL = s.Weight
				}
			}
			row.IsPR = (row.CurR > 0 && row.CurR >= bR) || (row.CurL > 0 && row.CurL >= bL)
		}
		rows = append(rows, row)
	}
	return rows
}

func ExerciseDetail(st models.AppState, exerciseID string) (ExerciseDetailDTO, bool) {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	ex := cat.ExerciseByID(exerciseID)
	if ex == nil {
		return ExerciseDetailDTO{}, false
	}

	sessions := st.Sessions
	strength := services.StrengthProgression(sessions, exerciseID)

	sorted := services.SortedSessions(sessions)
	history := make([]ExerciseHistoryItemDTO, 0)
	for i := len(sorted) - 1; i >= 0; i-- {
		s := sorted[i]
		for _, e := range s.Entries {
			if e.ExerciseID != exerciseID {
				continue
			}
			tR, tL := 0.0, 0.0
			sets := make([]SetDTO, 0, len(e.Sets))
			for _, st := range e.Sets {
				arm := st.Arm
				if arm == "" {
					arm = "R"
				}
				if arm == "R" && st.Weight > tR {
					tR = st.Weight
				} else if arm == "L" && st.Weight > tL {
					tL = st.Weight
				}
				sets = append(sets, SetDTO{Arm: arm, Weight: st.Weight, Reps: st.Reps})
			}
			history = append(history, ExerciseHistoryItemDTO{Date: s.Date, Sets: sets, Notes: e.Notes, TopR: tR, TopL: tL})
		}
	}

	groupColor := ""
	if g := catalog.GroupByID(ex.Group); g != nil {
		groupColor = g.Color
	}

	return ExerciseDetailDTO{
		Exercise:            *ex,
		GroupColor:          groupColor,
		StrengthProgression: strength,
		History:             history,
	}, true
}

func Goals(st models.AppState) []GoalDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	out := make([]GoalDTO, 0, len(st.Goals))
	for _, g := range st.Goals {
		out = append(out, goalToDTO(g, st.Sessions, cat))
	}
	return out
}

func BuildGoal(st models.AppState, req CreateGoalRequest) (models.Goal, error) {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	if cat.ExerciseByID(req.ExerciseID) == nil {
		return models.Goal{}, errors.New("unknown exercise")
	}
	if req.Arm != "R" && req.Arm != "L" {
		return models.Goal{}, errors.New("arm must be R or L")
	}
	if req.Target <= 0 {
		return models.Goal{}, errors.New("target weight is required")
	}
	return models.Goal{ID: util.NewID(), ExerciseID: req.ExerciseID, Arm: req.Arm, Target: req.Target}, nil
}

func LogInit(st models.AppState, workoutIdx *int) LogInitDTO {
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	idx := st.Cursor % len(cat.Workouts)
	if workoutIdx != nil && *workoutIdx >= 0 && *workoutIdx < len(cat.Workouts) {
		idx = *workoutIdx
	}

	sessions := st.Sessions
	exIDs := cat.Workouts[idx].ExerciseIDs
	exercises := make([]LogExerciseDTO, 0, len(exIDs))
	for _, exID := range exIDs {
		ex := cat.ExerciseByID(exID)
		if ex == nil {
			continue
		}
		dto := LogExerciseDTO{
			ExerciseID: ex.ID,
			Name:       ex.Name,
			Unit:       ex.Unit,
			BestR:      services.BestForArm(sessions, ex.ID, "R", ""),
			BestL:      services.BestForArm(sessions, ex.ID, "L", ""),
		}
		if le := services.LastEntry(sessions, ex.ID); le != nil {
			for _, s := range le.Entry.Sets {
				arm := s.Arm
				if arm == "" {
					arm = "R"
				}
				if arm == "R" {
					dto.LastWeightR = s.Weight
				} else {
					dto.LastWeightL = s.Weight
				}
			}
		}
		exercises = append(exercises, dto)
	}

	return LogInitDTO{WorkoutIdx: idx, Exercises: exercises}
}

func BuildExercise(st models.AppState, req CreateExerciseRequest) (catalog.Exercise, error) {
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return catalog.Exercise{}, errors.New("name is required")
	}
	if catalog.GroupByID(req.Group) == nil {
		return catalog.Exercise{}, errors.New("unknown group")
	}
	if req.Unit != "reps" && req.Unit != "sec" {
		return catalog.Exercise{}, errors.New("unit must be reps or sec")
	}
	return catalog.Exercise{ID: util.NewID(), Name: name, Group: req.Group, Unit: req.Unit}, nil
}

func BuildWorkout(st models.AppState, req CreateWorkoutRequest) (catalog.Workout, error) {
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return catalog.Workout{}, errors.New("name is required")
	}
	if len(req.ExerciseIDs) < 1 || len(req.ExerciseIDs) > 6 {
		return catalog.Workout{}, errors.New("pick between 1 and 6 exercises")
	}
	cat := catalog.Resolve(st.CustomExercises, st.CustomWorkouts)
	for _, id := range req.ExerciseIDs {
		if cat.ExerciseByID(id) == nil {
			return catalog.Workout{}, fmt.Errorf("unknown exercise %q", id)
		}
	}
	color := strings.TrimSpace(req.Color)
	if color == "" {
		return catalog.Workout{}, errors.New("color is required")
	}
	return catalog.Workout{Name: name, ExerciseIDs: req.ExerciseIDs, Color: color}, nil
}
