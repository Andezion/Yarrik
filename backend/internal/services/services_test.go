package services

import (
	"testing"

	"armforge/internal/models"
)

func TestGenDemoProducesPlausibleHistory(t *testing.T) {
	sessions, cursor, bw := GenDemo()
	if len(sessions) == 0 {
		t.Fatal("expected at least one demo session")
	}
	if cursor != len(sessions) {
		t.Fatalf("cursor should equal number of sessions logged, got cursor=%d sessions=%d", cursor, len(sessions))
	}
	if len(bw) != 11 {
		t.Fatalf("expected 11 bodyweight points, got %d", len(bw))
	}
	for _, s := range sessions {
		if len(s.Entries) != 3 {
			t.Fatalf("expected 3 entries per demo session, got %d for session %s", len(s.Entries), s.ID)
		}
		for _, e := range s.Entries {
			if len(e.Sets) != 6 {
				t.Fatalf("expected 6 sets (3 per arm) per entry, got %d", len(e.Sets))
			}
		}
	}
}

func TestEntryVolumeScalesSecondsExercises(t *testing.T) {
	e := models.Entry{ExerciseID: "kistlam", Sets: []models.Set{{Arm: "R", Weight: 30, Reps: 20}}}
	got := EntryVolume(e)
	want := 30.0 * 20.0 / 10.0
	if got != want {
		t.Fatalf("EntryVolume(sec) = %v, want %v", got, want)
	}
	e2 := models.Entry{ExerciseID: "kruk2", Sets: []models.Set{{Arm: "R", Weight: 30, Reps: 8}}}
	got2 := EntryVolume(e2)
	if got2 != 240 {
		t.Fatalf("EntryVolume(reps) = %v, want 240", got2)
	}
}

func TestRecentPRsOnlyReportsMostRecentImprovement(t *testing.T) {
	sessions := []models.Session{
		{ID: "1", Date: "2026-01-01", Entries: []models.Entry{{ExerciseID: "kruk2", Sets: []models.Set{{Arm: "R", Weight: 30, Reps: 5}}}}},
		{ID: "2", Date: "2026-01-08", Entries: []models.Entry{{ExerciseID: "kruk2", Sets: []models.Set{{Arm: "R", Weight: 32, Reps: 5}}}}},
		{ID: "3", Date: "2026-01-15", Entries: []models.Entry{{ExerciseID: "kruk2", Sets: []models.Set{{Arm: "R", Weight: 31, Reps: 5}}}}},
	}
	prs := RecentPRs(sessions, 5)
	if len(prs) != 1 {
		t.Fatalf("expected exactly 1 PR (session 2 beat session 1; session 3 didn't beat session 2), got %d: %+v", len(prs), prs)
	}
	if prs[0].Date != "2026-01-08" || prs[0].Weight != 32 {
		t.Fatalf("expected PR on 2026-01-08 @ 32kg, got %+v", prs[0])
	}
}

func TestBestForArmRespectsBeforeDate(t *testing.T) {
	sessions := []models.Session{
		{ID: "1", Date: "2026-01-01", Entries: []models.Entry{{ExerciseID: "kruk2", Sets: []models.Set{{Arm: "L", Weight: 20, Reps: 5}}}}},
		{ID: "2", Date: "2026-01-10", Entries: []models.Entry{{ExerciseID: "kruk2", Sets: []models.Set{{Arm: "L", Weight: 40, Reps: 5}}}}},
	}
	got := BestForArm(sessions, "kruk2", "L", "2026-01-10")
	if got != 20 {
		t.Fatalf("BestForArm before 2026-01-10 = %v, want 20 (session on that date itself excluded)", got)
	}
	got2 := BestForArm(sessions, "kruk2", "L", "")
	if got2 != 40 {
		t.Fatalf("BestForArm with no cutoff = %v, want 40", got2)
	}
}
