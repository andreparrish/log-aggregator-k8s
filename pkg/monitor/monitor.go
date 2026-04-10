package monitor

import "strings"

// Checks to see if given text contains the given pattern string (case-sensitive)
func Contains(text, pattern string) bool {
	return strings.Contains(text, pattern)
}

// FormatAlert returns a formatted alert string, based on input logLine string
func FormatAlert(pattern, logLine string) string {
	return "🚨 ALERT DETECTED [" + pattern + "]: " + logLine
}
