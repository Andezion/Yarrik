package catalog

type Group struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color"`
}

var Groups = []Group{
	{ID: "bok", Name: "Бок (Тодд) — крюк", Color: "#17B8A6"},
	{ID: "kist", Name: "Кисть", Color: "#2E97E5"},
	{ID: "verh", Name: "Верх / пронация", Color: "#F2A93B"},
	{ID: "baza", Name: "База", Color: "#57C84D"},
}

func GroupByID(id string) *Group {
	for i := range Groups {
		if Groups[i].ID == id {
			return &Groups[i]
		}
	}
	return nil
}

type Exercise struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Group string `json:"group"`
	Unit  string `json:"unit"`
}

var Exercises = []Exercise{
	{ID: "kruk2", Name: "Крюк, 2 хвата", Group: "bok", Unit: "reps"},
	{ID: "krukms", Name: "Крюк мультипинер", Group: "bok", Unit: "reps"},
	{ID: "kistrol", Name: "Кисть ролик", Group: "kist", Unit: "reps"},
	{ID: "boklam", Name: "Бок тяга на лямках", Group: "bok", Unit: "reps"},
	{ID: "kistlam", Name: "Кисть тяга на лямках", Group: "kist", Unit: "sec"},
	{ID: "toprol", Name: "Топ ролл, 2 хвата", Group: "verh", Unit: "reps"},
	{ID: "boktop", Name: "Бок топ-ролл (добивание)", Group: "verh", Unit: "reps"},
	{ID: "kistms", Name: "Кисть мультипинер (супинация)", Group: "kist", Unit: "sec"},
	{ID: "kruksp", Name: "Крюк (супинация/пронация)", Group: "bok", Unit: "reps"},
	{ID: "bokms", Name: "Бок мультипинер (супинация)", Group: "bok", Unit: "reps"},
	{ID: "pronfw", Name: "Пронация, свободный вес", Group: "verh", Unit: "reps"},
	{ID: "raizsr", Name: "Райз строгий", Group: "verh", Unit: "reps"},
	{ID: "raizfw", Name: "Райз, свободный вес", Group: "verh", Unit: "reps"},
	{ID: "pres2", Name: "Жим, 2 хвата (трицепс)", Group: "baza", Unit: "reps"},
	{ID: "skamya", Name: "Скамья (Скотта)", Group: "baza", Unit: "reps"},
}

func ExerciseByID(id string) *Exercise {
	for i := range Exercises {
		if Exercises[i].ID == id {
			return &Exercises[i]
		}
	}
	return nil
}

type Workout struct {
	Name        string   `json:"name"`
	ExerciseIDs []string `json:"exerciseIds"`
	Color       string   `json:"color"`
}

var Workouts = []Workout{
	{Name: "Тренировка 1", ExerciseIDs: []string{"kruk2", "toprol", "kistrol"}, Color: "#2E97E5"},
	{Name: "Тренировка 2", ExerciseIDs: []string{"krukms", "boktop", "kistlam"}, Color: "#17B8A6"},
	{Name: "Тренировка 3", ExerciseIDs: []string{"boklam", "pronfw", "kistms"}, Color: "#F2A93B"},
	{Name: "Тренировка 4", ExerciseIDs: []string{"kruksp", "raizsr", "pres2"}, Color: "#57C84D"},
	{Name: "Тренировка 5", ExerciseIDs: []string{"bokms", "raizfw", "skamya"}, Color: "#9A7BE8"},
}

func BestMatchingWorkout(exerciseIDs []string) int {
	best, bestIdx := -1, 0
	for i, w := range Workouts {
		matches := 0
		for _, wid := range w.ExerciseIDs {
			for _, id := range exerciseIDs {
				if id == wid {
					matches++
					break
				}
			}
		}
		if matches > best {
			best = matches
			bestIdx = i
		}
	}
	return bestIdx
}

var Moods = []string{"😫", "😕", "😐", "🙂", "🔥"}
var MoodLabels = []string{"ужасно", "так себе", "норм", "хорошо", "огонь"}

var FatigueColors = []string{"#57C84D", "#8CC63F", "#F2A93B", "#F5822E", "#E8564E"}

func WorkoutColor(idx int) string {
	if idx < 0 || idx >= len(Workouts) {
		return "#2E97E5"
	}
	return Workouts[idx].Color
}

type Catalog struct {
	Groups    []Group
	Exercises []Exercise
	Workouts  []Workout
}

func Resolve(customExercises []Exercise, customWorkouts []Workout) Catalog {
	exercises := make([]Exercise, 0, len(Exercises)+len(customExercises))
	exercises = append(exercises, Exercises...)
	exercises = append(exercises, customExercises...)

	workouts := make([]Workout, 0, len(Workouts)+len(customWorkouts))
	workouts = append(workouts, Workouts...)
	workouts = append(workouts, customWorkouts...)

	return Catalog{Groups: Groups, Exercises: exercises, Workouts: workouts}
}

func (c Catalog) ExerciseByID(id string) *Exercise {
	for i := range c.Exercises {
		if c.Exercises[i].ID == id {
			return &c.Exercises[i]
		}
	}
	return nil
}

func (c Catalog) WorkoutColor(idx int) string {
	if idx < 0 || idx >= len(c.Workouts) {
		return "#2E97E5"
	}
	return c.Workouts[idx].Color
}

func (c Catalog) BestMatchingWorkout(exerciseIDs []string) int {
	best, bestIdx := -1, 0
	for i, w := range c.Workouts {
		matches := 0
		for _, wid := range w.ExerciseIDs {
			for _, id := range exerciseIDs {
				if id == wid {
					matches++
					break
				}
			}
		}
		if matches > best {
			best = matches
			bestIdx = i
		}
	}
	return bestIdx
}
