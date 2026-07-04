package dateutil

import (
	"math"
	"time"
)

const Layout = "2006-01-02"

func Parse(s string) time.Time {
	t, err := time.Parse(Layout, s)
	if err != nil {
		return time.Time{}
	}
	return t
}

func Format(t time.Time) string {
	return t.Format(Layout)
}

func Today() string {
	return Format(time.Now())
}

func WeekKey(t time.Time) string {
	wd := int(t.Weekday())
	offset := (wd + 6) % 7
	monday := t.AddDate(0, 0, -offset)
	return Format(monday)
}

func DaysBetween(a, b string) int {
	ta, tb := Parse(a), Parse(b)
	hours := tb.Sub(ta).Hours()
	return int(math.Round(hours / 24))
}
