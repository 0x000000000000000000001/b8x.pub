import (
	"os"
	"path/filepath"
)

var _RootDirAbsolutePath string = func() string {
	dir, err := os.Getwd()
	if err != nil {
		return "/"
	}
	// Walk up until we find the project root (where go.mod or src might be)
	// For now, we simulate the PHP logic which stripped '/output/' or '/run/bak/'
	for dir != "/" {
		if filepath.Base(dir) == "output" || filepath.Base(dir) == "php" || filepath.Base(dir) == "js" || filepath.Base(dir) == "go" || filepath.Base(dir) == "bak" || filepath.Base(dir) == "run" {
			dir = filepath.Dir(dir)
		} else {
			break
		}
	}
	// In b8x PHP it stripped up to before 'output'
	// Here we just return dir + "/"
	if dir == "/" {
		return dir
	}
	return dir + "/"
}()
