package models

import "armforge/internal/catalog"

type Set struct {
	Arm    string  `json:"arm"`
	Weight float64 `json:"weight"`
	Reps   float64 `json:"reps"`
}

type Entry struct {
	ExerciseID string `json:"exId"`
	Notes      string `json:"notes"`
	Sets       []Set  `json:"sets"`
}

type Session struct {
	ID         string   `json:"id"`
	Date       string   `json:"date"`
	WorkoutIdx int      `json:"workoutIdx"`
	Duration   *int     `json:"duration,omitempty"`
	Mood       *int     `json:"mood,omitempty"`
	Fatigue    *int     `json:"fatigue,omitempty"`
	RPE        *int     `json:"rpe,omitempty"`
	Notes      string   `json:"notes"`
	Tags       []string `json:"tags"`
	Entries    []Entry  `json:"entries"`
}

type Bodyweight struct {
	Date string  `json:"date"`
	Kg   float64 `json:"kg"`
}

type Goal struct {
	ID         string  `json:"id"`
	ExerciseID string  `json:"exId"`
	Arm        string  `json:"arm"`
	Target     float64 `json:"target"`
}

type AppState struct {
	Name            string             `json:"name"`
	Cursor          int                `json:"cursor"`
	Sessions        []Session          `json:"sessions"`
	BW              []Bodyweight       `json:"bw"`
	Goals           []Goal             `json:"goals"`
	Tourney         string             `json:"tourney"`
	CustomExercises []catalog.Exercise `json:"customExercises"`
	CustomWorkouts  []catalog.Workout  `json:"customWorkouts"`
}
