package codec

import (
	"strings"
	"testing"
)

func TestValidateJSONRejectsDuplicateNestedKeysAndTrailingValues(t *testing.T) {
	for _, input := range []string{
		`{"outer":{"key":1,"key":2}}`,
		`{"value":1} {"value":2}`,
	} {
		if err := ValidateJSON([]byte(input), 0); err == nil {
			t.Fatalf("accepted invalid JSON %q", input)
		}
	}
}

func TestValidateJSONEnforcesUTF8AndByteBound(t *testing.T) {
	if err := ValidateJSON([]byte{0xff}, 0); err == nil {
		t.Fatal("accepted invalid UTF-8")
	}
	if err := ValidateJSON([]byte(strings.Repeat(" ", 4)+"null"), 4); err == nil {
		t.Fatal("accepted input beyond the byte bound")
	}
	if err := ValidateJSON([]byte(`{"ok":true}`), 32); err != nil {
		t.Fatalf("valid bounded JSON rejected: %v", err)
	}
}
