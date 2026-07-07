package main

import (
	"encoding/json"
	"testing"
)

func TestDispatchUnknownMethod(t *testing.T) {
	raw := dispatch("nope", "{}")
	var env envelope
	if err := json.Unmarshal([]byte(raw), &env); err != nil {
		t.Fatal(err)
	}
	if env.OK {
		t.Fatal("expected ok=false for an unknown method")
	}
}

func TestDispatchMeta(t *testing.T) {
	raw := dispatch("meta", "{}")
	var env envelope
	if err := json.Unmarshal([]byte(raw), &env); err != nil {
		t.Fatal(err)
	}
	if !env.OK {
		t.Fatalf("expected ok=true, got error %q", env.Error)
	}
	var meta struct {
		Exercises []interface{} `json:"exercises"`
	}
	if err := json.Unmarshal(env.Data, &meta); err != nil {
		t.Fatal(err)
	}
	if len(meta.Exercises) != 15 {
		t.Fatalf("expected 15 exercises, got %d", len(meta.Exercises))
	}
}

func TestDispatchBuildSessionRoundTrip(t *testing.T) {
	args := `{
		"request": {
			"date": "2026-07-01",
			"workoutIdx": 0,
			"entries": [{"exId":"kruk2","sets":[{"arm":"R","weight":30,"reps":8}]}]
		},
		"currentCursor": 0
	}`
	raw := dispatch("buildSession", args)
	var env envelope
	if err := json.Unmarshal([]byte(raw), &env); err != nil {
		t.Fatal(err)
	}
	if !env.OK {
		t.Fatalf("expected ok=true, got error %q", env.Error)
	}
	var result struct {
		NewCursor int `json:"newCursor"`
		Session   struct {
			ID string `json:"id"`
		} `json:"session"`
	}
	if err := json.Unmarshal(env.Data, &result); err != nil {
		t.Fatal(err)
	}
	if result.NewCursor != 1 {
		t.Fatalf("expected newCursor=1, got %d", result.NewCursor)
	}
	if result.Session.ID == "" {
		t.Fatal("expected a generated session ID")
	}
}

func TestDispatchBuildSessionValidationError(t *testing.T) {
	args := `{"request":{"date":"","workoutIdx":0,"entries":[]},"currentCursor":0}`
	raw := dispatch("buildSession", args)
	var env envelope
	if err := json.Unmarshal([]byte(raw), &env); err != nil {
		t.Fatal(err)
	}
	if env.OK {
		t.Fatal("expected ok=false for a session with an empty date")
	}
	if env.Error == "" {
		t.Fatal("expected a non-empty error message")
	}
}
