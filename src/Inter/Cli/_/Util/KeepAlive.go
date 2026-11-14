func KeepMainAlive() interface{} {
	select {} // Block main thread indefinitely
	return nil
}
