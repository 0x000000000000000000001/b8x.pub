package Infra_EventStore_Postgres_EventStore

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var (
	processIdStr string
	counter      int
	mu           sync.Mutex
)

func init() {
	rand.Seed(time.Now().UnixNano())
	processIdStr = fmt.Sprintf("%03d", rand.Intn(1000))
}

func GenerateLockKeyStr() string {
	mu.Lock()
	defer mu.Unlock()

	counter = (counter + 1) % 1000
	counterStr := fmt.Sprintf("%03d", counter)
	now := time.Now().UnixNano() / int64(time.Millisecond)

	return fmt.Sprintf("%d%s%s", now, processIdStr, counterStr)
}
