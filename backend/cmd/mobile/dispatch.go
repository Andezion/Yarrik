package main

import (
	"encoding/json"
	"fmt"

	"armforge/internal/compute"
	"armforge/internal/models"
	"armforge/internal/services"
)

type envelope struct {
	OK    bool            `json:"ok"`
	Data  json.RawMessage `json:"data,omitempty"`
	Error string          `json:"error,omitempty"`
}

type methodFunc func(args json.RawMessage) (interface{}, error)

var methods = map[string]methodFunc{
	"meta":           methodMeta,
	"dashboard":      methodDashboard,
	"sessions":       methodSessions,
	"sessionsOnDate": methodSessionsOnDate,
	"buildSession":   methodBuildSession,
	"calendar":       methodCalendar,
	"stats":          methodStats,
	"exercisesTable": methodExercisesTable,
	"exerciseDetail": methodExerciseDetail,
	"goals":          methodGoals,
	"buildGoal":      methodBuildGoal,
	"logInit":        methodLogInit,
	"importAny":      methodImportAny,
	"createExercise": methodCreateExercise,
	"createWorkout":  methodCreateWorkout,
}

func dispatch(method string, argsJSON string) string {
	fn, ok := methods[method]
	if !ok {
		return encodeEnvelope(envelope{OK: false, Error: fmt.Sprintf("unknown method %q", method)})
	}
	result, err := fn(json.RawMessage(argsJSON))
	if err != nil {
		return encodeEnvelope(envelope{OK: false, Error: err.Error()})
	}
	data, err := json.Marshal(result)
	if err != nil {
		return encodeEnvelope(envelope{OK: false, Error: "failed to encode result: " + err.Error()})
	}
	return encodeEnvelope(envelope{OK: true, Data: data})
}

func encodeEnvelope(e envelope) string {
	b, err := json.Marshal(e)
	if err != nil {
		return `{"ok":false,"error":"internal encoding failure"}`
	}
	return string(b)
}

type stateArgs struct {
	State models.AppState `json:"state"`
}

func methodMeta(_ json.RawMessage) (interface{}, error) {
	return compute.Meta(), nil
}

func methodDashboard(args json.RawMessage) (interface{}, error) {
	var a stateArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.Dashboard(a.State), nil
}

type sessionsArgs struct {
	State      models.AppState `json:"state"`
	Query      string          `json:"query"`
	WorkoutIdx *int            `json:"workoutIdx"`
	GroupID    string          `json:"groupId"`
}

func methodSessions(args json.RawMessage) (interface{}, error) {
	var a sessionsArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.Sessions(a.State, compute.SessionsFilter{Query: a.Query, WorkoutIdx: a.WorkoutIdx, GroupID: a.GroupID}), nil
}

type sessionsOnDateArgs struct {
	State models.AppState `json:"state"`
	Date  string          `json:"date"`
}

func methodSessionsOnDate(args json.RawMessage) (interface{}, error) {
	var a sessionsOnDateArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.SessionsOnDate(a.State, a.Date), nil
}

type buildSessionArgs struct {
	State         models.AppState              `json:"state"`
	Request       compute.CreateSessionRequest `json:"request"`
	CurrentCursor int                          `json:"currentCursor"`
}

func methodBuildSession(args json.RawMessage) (interface{}, error) {
	var a buildSessionArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.BuildSession(a.State, a.Request, a.CurrentCursor)
}

type calendarArgs struct {
	State models.AppState `json:"state"`
	Year  int             `json:"year"`
	Month int             `json:"month"`
}

func methodCalendar(args json.RawMessage) (interface{}, error) {
	var a calendarArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.Calendar(a.State, a.Year, a.Month), nil
}

type statsArgs struct {
	State      models.AppState `json:"state"`
	ExerciseID string          `json:"exerciseId"`
}

func methodStats(args json.RawMessage) (interface{}, error) {
	var a statsArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.Stats(a.State, a.ExerciseID), nil
}

func methodExercisesTable(args json.RawMessage) (interface{}, error) {
	var a stateArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.ExercisesTable(a.State), nil
}

type exerciseDetailArgs struct {
	State      models.AppState `json:"state"`
	ExerciseID string          `json:"exerciseId"`
}

func methodExerciseDetail(args json.RawMessage) (interface{}, error) {
	var a exerciseDetailArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	detail, ok := compute.ExerciseDetail(a.State, a.ExerciseID)
	if !ok {
		return nil, fmt.Errorf("unknown exercise %q", a.ExerciseID)
	}
	return detail, nil
}

func methodGoals(args json.RawMessage) (interface{}, error) {
	var a stateArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.Goals(a.State), nil
}

type buildGoalArgs struct {
	State   models.AppState           `json:"state"`
	Request compute.CreateGoalRequest `json:"request"`
}

func methodBuildGoal(args json.RawMessage) (interface{}, error) {
	var a buildGoalArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.BuildGoal(a.State, a.Request)
}

type logInitArgs struct {
	State      models.AppState `json:"state"`
	WorkoutIdx *int            `json:"workoutIdx"`
}

func methodLogInit(args json.RawMessage) (interface{}, error) {
	var a logInitArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.LogInit(a.State, a.WorkoutIdx), nil
}

type importAnyArgs struct {
	Raw     map[string]json.RawMessage `json:"raw"`
	Current models.AppState            `json:"current"`
}

func methodImportAny(args json.RawMessage) (interface{}, error) {
	var a importAnyArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	result, ok := services.ImportAny(a.Raw, a.Current)
	if !ok {
		return nil, fmt.Errorf("file doesn't look like a diary backup")
	}
	return result, nil
}

type createExerciseArgs struct {
	State   models.AppState                `json:"state"`
	Request compute.CreateExerciseRequest `json:"request"`
}

func methodCreateExercise(args json.RawMessage) (interface{}, error) {
	var a createExerciseArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.BuildExercise(a.State, a.Request)
}

type createWorkoutArgs struct {
	State   models.AppState               `json:"state"`
	Request compute.CreateWorkoutRequest `json:"request"`
}

func methodCreateWorkout(args json.RawMessage) (interface{}, error) {
	var a createWorkoutArgs
	if err := json.Unmarshal(args, &a); err != nil {
		return nil, err
	}
	return compute.BuildWorkout(a.State, a.Request)
}
