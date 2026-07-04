package compute

import (
	"testing"

	"armforge/internal/models"
)

func emptyState() models.AppState {
	return models.AppState{
		Name:     "Тест",
		Sessions: []models.Session{},
		BW:       []models.Bodyweight{},
		Goals:    []models.Goal{},
		Tourney:  "2026-07-31",
	}
}

func TestMetaListsCatalog(t *testing.T) {
	meta := Meta()
	if len(meta.Exercises) != 15 {
		t.Fatalf("expected 15 exercises, got %d", len(meta.Exercises))
	}
	if len(meta.Workouts) != 5 {
		t.Fatalf("expected 5 workouts, got %d", len(meta.Workouts))
	}
}

func TestBuildSessionThenAppearsInDashboardAndDiary(t *testing.T) {
	st := emptyState()

	req := CreateSessionRequest{
		Date:       "2026-07-01",
		WorkoutIdx: 0,
		Entries: []CreateEntryRequest{
			{ExerciseID: "kruk2", Sets: []CreateSetRequest{{Arm: "R", Weight: 30, Reps: 8}}},
		},
	}
	result, err := BuildSession(req, st.Cursor)
	if err != nil {
		t.Fatal(err)
	}
	if result.NewCursor != 1 {
		t.Fatalf("expected cursor to advance to 1 (workoutIdx 0 matched cursor%%5==0), got %d", result.NewCursor)
	}

	st.Sessions = append(st.Sessions, result.Session)
	st.Cursor = result.NewCursor

	dash := Dashboard(st)
	if dash.NextWorkoutIdx != 1 {
		t.Fatalf("expected next workout idx 1, got %d", dash.NextWorkoutIdx)
	}
	if len(dash.RecentSessions) != 1 || dash.RecentSessions[0].Volume != 240 {
		t.Fatalf("expected 1 recent session with volume 240, got %+v", dash.RecentSessions)
	}

	list := Sessions(st, SessionsFilter{})
	if len(list) != 1 || list[0].ID != result.Session.ID {
		t.Fatalf("expected the built session in the diary list, got %+v", list)
	}
}

func TestBuildSessionRejectsEmptySets(t *testing.T) {
	req := CreateSessionRequest{
		Date:       "2026-07-01",
		WorkoutIdx: 0,
		Entries: []CreateEntryRequest{
			{ExerciseID: "kruk2", Sets: []CreateSetRequest{{Arm: "R", Weight: 0, Reps: 0}}},
		},
	}
	if _, err := BuildSession(req, 0); err == nil {
		t.Fatal("expected an error for a session with no valid sets")
	}
}

func TestBuildGoalValidation(t *testing.T) {
	if _, err := BuildGoal(CreateGoalRequest{ExerciseID: "does-not-exist", Arm: "L", Target: 10}); err == nil {
		t.Fatal("expected error for unknown exercise")
	}
	if _, err := BuildGoal(CreateGoalRequest{ExerciseID: "kruk2", Arm: "L", Target: 0}); err == nil {
		t.Fatal("expected error for zero target")
	}
	g, err := BuildGoal(CreateGoalRequest{ExerciseID: "kruk2", Arm: "L", Target: 45})
	if err != nil {
		t.Fatal(err)
	}
	if g.ID == "" {
		t.Fatal("expected a generated ID")
	}

	st := emptyState()
	st.Goals = append(st.Goals, g)
	goals := Goals(st)
	if len(goals) != 1 || goals[0].Pct != 0 {
		t.Fatalf("expected 1 goal at 0%% progress with no sessions logged, got %+v", goals)
	}
}

func TestExercisesTableCoversFullCatalog(t *testing.T) {
	rows := ExercisesTable(emptyState())
	if len(rows) != 15 {
		t.Fatalf("expected 15 rows, got %d", len(rows))
	}
	for _, r := range rows {
		if r.LastDate != nil {
			t.Fatalf("expected no last date for exercise %s in an empty state", r.ID)
		}
	}
}

func TestExerciseDetailUnknownID(t *testing.T) {
	if _, ok := ExerciseDetail(emptyState(), "nope"); ok {
		t.Fatal("expected ok=false for an unknown exercise id")
	}
}

func TestLogInitDefaultsToCursorWorkout(t *testing.T) {
	st := emptyState()
	st.Cursor = 7
	init := LogInit(st, nil)
	if init.WorkoutIdx != 2 {
		t.Fatalf("expected workoutIdx 2 from cursor 7, got %d", init.WorkoutIdx)
	}
	if len(init.Exercises) != 3 {
		t.Fatalf("expected 3 exercises for the workout template, got %d", len(init.Exercises))
	}
}
