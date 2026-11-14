package Util_Timer

import (
	"sync"
	"time"
)

type IntervalId struct {
	ticker *time.Ticker
	quit   chan struct{}
	done   chan struct{}
	stop   sync.Once
}

func SetIntervalImpl(ms int64, fn func()) *IntervalId {
	ticker := time.NewTicker(time.Duration(ms) * time.Millisecond)
	id := &IntervalId{ticker: ticker, quit: make(chan struct{}), done: make(chan struct{})}
	go func() {
		defer close(id.done)
		defer ticker.Stop()
		for {
			select {
			case <-id.quit:
				return
			case <-ticker.C:
				select {
				case <-id.quit:
					return
				default:
				}
				fn()
			}
		}
	}()
	return id
}

// Stop is idempotent. A callback already selected may finish; waiting for it
// here would deadlock a callback that clears its own interval.
func ClearIntervalImpl(id *IntervalId) {
	id.stop.Do(func() {
		id.ticker.Stop()
		close(id.quit)
	})
}
