<?php

function unzipCheck(bool $condition, string $message): void
{
    if (!$condition) {
        throw new RuntimeException($message);
    }
}

function unzipRun(callable $operation): mixed
{
    $settlements = 0;
    $result = null;
    $failure = null;
    $cancel = $operation(
        function ($error) use (&$settlements, &$failure) {
            $settlements++;
            $failure = $error;
        },
        function ($value) use (&$settlements, &$result) {
            $settlements++;
            $result = $value;
        },
    );
    unzipCheck($settlements === 1, 'Operation must settle exactly once');
    $completed = false;
    $cancel(null, fn($error) => throw $error, function () use (&$completed) {
        $completed = true;
    });
    unzipCheck($completed, 'Canceler must complete');
    if ($failure !== null) {
        throw $failure;
    }
    return $result;
}

$exports = [];
$unzip = require dirname(__DIR__, 2) . '/src/Util/File/Unzip.php';
$archivePath = tempnam(sys_get_temp_dir(), 'b8x-unzip-');
$outputPath = $archivePath . '-out';
$archive = new ZipArchive();
$archive->open($archivePath, ZipArchive::OVERWRITE);
$archive->addFromString('sheet.html', '<h1>sheet</h1>');
$archive->addFromString('other.html', '<h1>other</h1>');
$archive->addFromString('nested/value.txt', 'value');
$archive->close();
try {
    $content = file_get_contents($archivePath);
    $extract = $unzip['_unzipGoogleSheetAndExtractHtml']('sheet', $content);
    unzipCheck(is_callable($extract), 'Extraction must defer until registration');
    unzipCheck(unzipRun($extract) === '<h1>sheet</h1>', 'Named HTML extraction failed');
    unzipCheck(unzipRun($extract) === '<h1>sheet</h1>', 'Extraction cannot replay');
    unzipCheck(
        unzipRun($unzip['_unzipGoogleSheetAndExtractHtml']('', $content)) === '<h1>sheet</h1>',
        'First HTML selection failed',
    );
    foreach ([['missing', $content], ['sheet', 'invalid ZIP']] as [$filename, $bytes]) {
        $failed = false;
        try {
            unzipRun($unzip['_unzipGoogleSheetAndExtractHtml']($filename, $bytes));
        } catch (Throwable) {
            $failed = true;
        }
        unzipCheck($failed, 'Invalid ZIP request succeeded');
    }
    $extractDirectory = $unzip['_unzipToDirectory']($outputPath, $content);
    unzipCheck(!file_exists($outputPath), 'Directory extraction started early');
    unzipCheck(unzipRun($extractDirectory) === null, 'Directory extraction must return Unit');
    unzipCheck(
        file_get_contents($outputPath . '/nested/value.txt') === 'value',
        'Nested file extraction failed',
    );
    echo "Unzip PHP FFI checks passed\n";
} finally {
    unlink($archivePath);
    foreach (['nested/value.txt', 'sheet.html', 'other.html'] as $file) {
        if (is_file($outputPath . '/' . $file)) {
            unlink($outputPath . '/' . $file);
        }
    }
    if (is_dir($outputPath . '/nested')) {
        rmdir($outputPath . '/nested');
    }
    if (is_dir($outputPath)) {
        rmdir($outputPath);
    }
}
