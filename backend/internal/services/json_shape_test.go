package services

import (
	"encoding/json"
	"testing"
)

func TestStrengthProgressionSerializesEmptyAsArrayNotNull(t *testing.T) {
	got := StrengthProgression(nil, "kruk2")
	b, err := json.Marshal(got)
	if err != nil {
		t.Fatal(err)
	}
	if string(b) != "[]" {
		t.Fatalf("StrengthProgression([]) marshaled to %s, want []", b)
	}
}

func TestSessionsWithFatigueSerializesEmptyAsArrayNotNull(t *testing.T) {
	got := SessionsWithFatigue(nil, 15)
	b, err := json.Marshal(got)
	if err != nil {
		t.Fatal(err)
	}
	if string(b) != "[]" {
		t.Fatalf("SessionsWithFatigue([]) marshaled to %s, want []", b)
	}
}
