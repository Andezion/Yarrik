package services

import (
	"math"
	"math/rand"
	"time"

	"armforge/internal/catalog"
	"armforge/internal/dateutil"
	"armforge/internal/models"
	"armforge/internal/util"
)

var demoBaseWeights = map[string]float64{
	"kruk2": 34, "krukms": 29, "kistrol": 24, "boklam": 39, "kistlam": 28,
	"toprol": 31, "boktop": 33, "kistms": 26, "kruksp": 32, "bokms": 30,
	"pronfw": 11, "raizsr": 19, "raizfw": 13, "pres2": 44, "skamya": 37,
}

var demoMoodPool = []int{2, 3, 3, 4, 4, 3, 4}

var demoNotesPool = []string{
	"Крюк держал плотно, кисть не гуляла.",
	"Левая идёт лучше — добавил 2.5 кг.",
	"Локоть слегка ныл, снизил темп.",
	"Хорошая связка бок—крюк.",
	"Пронация с паузой в строгом.",
	"Стол чувствуется, работал углы.",
	"",
}

func intPtr(v int) *int { return &v }

func GenDemo() (sessions []models.Session, cursor int, bw []models.Bodyweight) {
	start := time.Now().AddDate(0, 0, -70)
	d := start
	week := 0
	now := time.Now()

	for !d.After(now) {
		wd := int(d.Weekday())
		dow := (wd + 6) % 7
		if dow == 0 || dow == 2 || dow == 4 {
			wi := cursor % 5
			cursor++
			prog := 1 + float64(week)*0.012

			entries := make([]models.Entry, 0, 3)
			for _, exID := range catalog.Workouts[wi].ExerciseIDs {
				ex := catalog.ExerciseByID(exID)
				baseW := demoBaseWeights[exID] * prog
				sets := make([]models.Set, 0, 6)
				for _, arm := range [2]string{"R", "L"} {
					w := baseW + jitter(arm)
					w = math.Round(w*2) / 2
					var reps float64
					if ex.Unit == "sec" {
						reps = 20 + math.Round(rand.Float64()*10)
					} else {
						reps = 6 + math.Round(rand.Float64()*3)
					}
					for k := 0; k < 3; k++ {
						setW := w
						setR := reps
						if k == 2 {
							setW -= 2.5
						} else {
							setR -= float64(k)
						}
						sets = append(sets, models.Set{Arm: arm, Weight: setW, Reps: setR})
					}
				}
				entries = append(entries, models.Entry{ExerciseID: exID, Notes: "", Sets: sets})
			}

			var tags []string
			roll := rand.Float64()
			if roll < 0.25 {
				tags = []string{"техника"}
			} else if roll < 0.2 {
				tags = []string{"тяжёлая"}
			} else {
				tags = []string{}
			}

			sessions = append(sessions, models.Session{
				ID:         util.NewID(),
				Date:       dateutil.Format(d),
				WorkoutIdx: wi,
				Duration:   intPtr(55 + int(math.Round(rand.Float64()*25))),
				Mood:       intPtr(demoMoodPool[rand.Intn(len(demoMoodPool))]),
				Fatigue:    intPtr(1 + rand.Intn(4)),
				RPE:        intPtr(6 + rand.Intn(3)),
				Notes:      demoNotesPool[rand.Intn(len(demoNotesPool))],
				Tags:       tags,
				Entries:    entries,
			})
			if dow == 4 {
				week++
			}
		}
		d = d.AddDate(0, 0, 1)
	}

	w0 := 88.6
	for i := 10; i >= 0; i-- {
		dd := time.Now().AddDate(0, 0, -i*7)
		kg := math.Round((w0-float64(10-i)*0.13+(rand.Float64()*0.4-0.2))*10) / 10
		bw = append(bw, models.Bodyweight{Date: dateutil.Format(dd), Kg: kg})
	}
	return sessions, cursor, bw
}

func jitter(arm string) float64 {
	base := rand.Float64()*2 - 1
	if arm == "L" {
		return base + 2.5
	}
	return base
}

func SeedDemoState() models.AppState {
	sessions, cursor, bw := GenDemo()
	return models.AppState{
		Name:     "Атлет",
		Cursor:   cursor,
		Sessions: sessions,
		BW:       bw,
		Goals: []models.Goal{
			{ID: util.NewID(), ExerciseID: "kruk2", Arm: "L", Target: 45},
			{ID: util.NewID(), ExerciseID: "toprol", Arm: "R", Target: 40},
		},
		Tourney: "2026-07-31",
		Demo:    true,
	}
}
