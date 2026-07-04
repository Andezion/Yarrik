package util

import (
	"crypto/rand"
	"encoding/base32"
	"strconv"
	"strings"
	"time"
)

func Clamp(v, lo, hi int) int {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func ClampF(v, lo, hi float64) float64 {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func NewID() string {
	ts := strconv.FormatInt(time.Now().UnixNano(), 36)
	var buf [4]byte
	_, _ = rand.Read(buf[:])
	suffix := strings.ToLower(base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString(buf[:]))
	return ts + suffix
}

func Num(v interface{}) float64 {
	switch x := v.(type) {
	case float64:
		return x
	case int:
		return float64(x)
	case string:
		s := strings.ReplaceAll(strings.TrimSpace(x), ",", ".")
		f, err := strconv.ParseFloat(s, 64)
		if err != nil {
			return 0
		}
		return f
	default:
		return 0
	}
}
