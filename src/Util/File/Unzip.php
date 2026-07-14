<?php

$exports['_unzipGoogleSheetAndExtractHtml'] = function($filename, $zipContent = null) {
    if (\func_num_args() < 2) {
        return function($zipContent) use ($filename) {
            global $exports;
            return $exports['_unzipGoogleSheetAndExtractHtml']($filename, $zipContent);
        };
    }
    return function() use ($filename, $zipContent) {
        $tempFile = tempnam(sys_get_temp_dir(), 'zip');
        \file_put_contents($tempFile, $zipContent);
        $zip = new \ZipArchive();
        if ($zip->open($tempFile) === true) {
            $targetIndex = -1;
            $filename_ = $filename . '.html';
            for ($i = 0; $i < $zip->numFiles; $i++) {
                $stat = $zip->statIndex($i);
                if ($filename !== '') {
                    if ($stat['name'] === $filename_) { $targetIndex = $i; break; }
                } else {
                    if (substr($stat['name'], -5) === '.html') { $targetIndex = $i; break; }
                }
            }
            if ($targetIndex === -1) {
                $zip->close();
                unlink($tempFile);
                throw new \Exception("File not found in ZIP");
            }
            $content = $zip->getFromIndex($targetIndex);
            $zip->close();
            unlink($tempFile);
            return $content;
        }
        unlink($tempFile);
        throw new \Exception("Failed to open ZIP");
    };
};

$exports['_unzipToDirectory'] = function($outputPath, $zipContent = null) {
    if (\func_num_args() < 2) {
        return function($zipContent) use ($outputPath) {
            global $exports;
            return $exports['_unzipToDirectory']($outputPath, $zipContent);
        };
    }
    return function() use ($outputPath, $zipContent) {
        $tempFile = tempnam(sys_get_temp_dir(), 'zip');
        \file_put_contents($tempFile, $zipContent);
        $zip = new \ZipArchive();
        if ($zip->open($tempFile) === true) {
            $zip->extractTo($outputPath);
            $zip->close();
            unlink($tempFile);
            return $outputPath;
        }
        unlink($tempFile);
        throw new \Exception("Failed to open ZIP");
    };
};

$exports['_unzipGoogleSheet'] = function($zipContent) {
    return function() use ($zipContent) {
        throw new \Exception("Not implemented in PHP: returning raw Zip object");
    };
};

return $exports;
