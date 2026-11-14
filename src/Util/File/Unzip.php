<?php

$withZip = static function ($zipContent, $action) {
    $temporaryFile = tempnam(sys_get_temp_dir(), 'zip');
    if ($temporaryFile === false) {
        throw new \RuntimeException('Failed to create temporary ZIP file');
    }
    $zip = null;
    $opened = false;
    try {
        $zip = new \ZipArchive();
        if (file_put_contents($temporaryFile, $zipContent) === false) {
            throw new \RuntimeException('Failed to write temporary ZIP file');
        }
        $opened = $zip->open($temporaryFile) === true;
        if (!$opened) {
            throw new \RuntimeException('Failed to open ZIP');
        }
        return $action($zip);
    } finally {
        if ($opened) {
            $zip->close();
        }
        unlink($temporaryFile);
    }
};

$exports['_unzipGoogleSheetAndExtractHtml'] = static function ($filename, $zipContent) use (
    $withZip,
) {
    return static function ($onError, $onSuccess) use ($filename, $zipContent, $withZip) {
        $cancel = static fn($reason, $onCancelerError, $onCancelerSuccess) => $onCancelerSuccess(
            null,
        );
        try {
            $content = $withZip($zipContent, static function ($zip) use ($filename) {
                $targetName = $filename . '.html';
                for ($index = 0; $index < $zip->numFiles; $index++) {
                    $name = $zip->getNameIndex($index);
                    if ($name === false) {
                        continue;
                    }
                    $matches =
                        $filename === '' ? str_ends_with($name, '.html') : $name === $targetName;
                    if ($matches) {
                        $content = $zip->getFromIndex($index);
                        if ($content === false) {
                            throw new \RuntimeException('Failed to read HTML file in ZIP');
                        }
                        return $content;
                    }
                }
                throw new \RuntimeException('File not found in ZIP');
            });
        } catch (\Throwable $failure) {
            $onError($failure);
            return $cancel;
        }
        $onSuccess($content);
        return $cancel;
    };
};

$exports['_unzipToDirectory'] = static function ($outputPath, $zipContent) use ($withZip) {
    return static function ($onError, $onSuccess) use ($outputPath, $zipContent, $withZip) {
        $cancel = static fn($reason, $onCancelerError, $onCancelerSuccess) => $onCancelerSuccess(
            null,
        );
        try {
            $withZip($zipContent, static function ($zip) use ($outputPath) {
                if (!$zip->extractTo($outputPath)) {
                    throw new \RuntimeException('Failed to extract ZIP');
                }
            });
        } catch (\Throwable $failure) {
            $onError($failure);
            return $cancel;
        }
        $onSuccess(null);
        return $cancel;
    };
};

return $exports;
