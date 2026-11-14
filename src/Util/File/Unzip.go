package unzip

import (
	"archive/zip"
	"bytes"
	"errors"
	"io"
	"strings"
)

func _UnzipGoogleSheetAndExtractHtml(filename string, zipContent []byte) (string, error) {
	reader, err := zip.NewReader(bytes.NewReader(zipContent), int64(len(zipContent)))
	if err != nil {
		return "", errors.New("Failed to open ZIP: " + err.Error())
	}
	target := htmlFile(reader.File, filename)
	if target == nil {
		return "", errors.New("File not found in ZIP")
	}
	content, err := target.Open()
	if err != nil {
		return "", errors.New("Failed to read file in ZIP: " + err.Error())
	}
	defer content.Close()
	var out bytes.Buffer
	if _, err = io.Copy(&out, content); err != nil {
		return "", errors.New("Failed to copy file content: " + err.Error())
	}
	return out.String(), nil
}

func htmlFile(files []*zip.File, filename string) *zip.File {
	for _, file := range files {
		if filename != "" && file.Name == filename+".html" || filename == "" && strings.HasSuffix(file.Name, ".html") {
			return file
		}
	}
	return nil
}

func _UnzipToDirectory(outputDir string, zipContent []byte) error {
	return errors.New("Not implemented: _UnzipToDirectory")
}
