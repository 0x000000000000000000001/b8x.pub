package Util_Signal

import (
	"os"
	"os/signal"
	"syscall"
)

func OnSignalImpl(sigName string, fn func()) {
	var sig os.Signal

	switch sigName {
	case "SIGINT":
		sig = syscall.SIGINT
	case "SIGTERM":
		sig = syscall.SIGTERM
	case "SIGQUIT":
		sig = syscall.SIGQUIT
	default:
		return
	}

	c := make(chan os.Signal, 1)
	signal.Notify(c, sig)

	go func() {
		<-c
		fn()
	}()

	return
}
