package query_youcao

import (
	"net/url"
	"time"
)

const (
	youdao    = "https://openapi.youdao.com/api"
	appKey    = "1858465a8708c121"
	appPasswd = "fG0sitfk16nJOlIlycnLPYZn1optxUxL"
)

type data struct {
	q        string
	from     string
	to       string
	// appKey   string
	salt     string
	sign     string
	signType string
	curtime  string
}


func input(word string) string {
	var input string
	len := len(word)
	if len > 20 {
		input = word[:10] + string(rune(len)) + word[len-10:]
	} else {
		input = word
	}
	return input
}

func salt(_ string) string {
	// TODO : hash salt
	var salt string

	return salt
}

func to_value(d data) url.Values {
	// return value
}

func Query(word string) {

}
