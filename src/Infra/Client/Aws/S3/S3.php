<?php

$exports['_createInnerClient'] = static function ($region, $accessKeyId, $secretAccessKey) {
    return new \Aws\S3\S3Client([
        'version' => 'latest',
        'region' => $region,
        'credentials' => ['key' => $accessKeyId, 'secret' => $secretAccessKey],
    ]);
};

// SDK operations start when Aff registers its callbacks. Cancellation does not
// abort these operations, matching the previous Promise adapter.
$runAsync = static function (callable $operation): \Closure {
    return static function (callable $onError, callable $onSuccess) use ($operation): \Closure {
        \Amp\async(static function () use ($operation, $onError, $onSuccess): void {
            try {
                $result = $operation();
            } catch (\Throwable $error) {
                $onError($error);
                return;
            }
            $onSuccess($result);
        });
        return static function ($cancelError, $onCancelError, $onCancelSuccess): void {
            $onCancelSuccess(null);
        };
    };
};

$exports['_uploadUrlContentImpl'] = static function (
    $client,
    $bucket,
    $isPublic,
    $bucketDirectory,
    $autocropBlackWhite,
    $autocropTransparent,
    $url,
    $mimeTypeToExtension,
) use ($runAsync) {
    return $runAsync(static function () use (
        $client,
        $bucket,
        $isPublic,
        $bucketDirectory,
        $autocropBlackWhite,
        $autocropTransparent,
        $url,
        $mimeTypeToExtension,
    ) {
        $httpClient = \Amp\Http\Client\HttpClientBuilder::buildDefault();
        $request = new \Amp\Http\Client\Request($url);
        $request->setHeader('User-Agent', 'Mozilla/5.0');

        $response = $httpClient->request($request);
        $body = $response->getBody()->buffer();

        if (empty($body)) {
            throw new \Exception("Failed to fetch image from $url");
        }

        $finfo = new \finfo(FILEINFO_MIME_TYPE);
        $mimeType = $finfo->buffer($body);

        if (strpos($mimeType, 'text/html') !== false) {
            throw new \Exception('Skipping HTML content for S3 upload');
        }

        $dimensions = @getimagesizefromstring($body);
        if ($dimensions === false) {
            throw new \RuntimeException("Cannot determine image dimensions for $url");
        }
        [$width, $height] = $dimensions;
        if (strpos($mimeType, 'image/') === 0 && function_exists('imagecreatefromstring')) {
            $img = @imagecreatefromstring($body);
            if ($img !== false) {
                $cropped = false;
                if ($autocropBlackWhite) {
                    $croppedImg = imagecropauto($img, IMG_CROP_WHITE);
                    if ($croppedImg !== false) {
                        $img = $croppedImg;
                        $cropped = true;
                    }
                    $croppedImg = imagecropauto($img, IMG_CROP_BLACK);
                    if ($croppedImg !== false) {
                        $img = $croppedImg;
                        $cropped = true;
                    }
                }
                if ($autocropTransparent) {
                    $croppedImg = imagecropauto($img, IMG_CROP_TRANSPARENT);
                    if ($croppedImg !== false) {
                        $img = $croppedImg;
                        $cropped = true;
                    }
                }
                $width = imagesx($img);
                $height = imagesy($img);

                if ($cropped) {
                    ob_start();
                    if ($mimeType === 'image/png') {
                        imagepng($img);
                    } elseif ($mimeType === 'image/webp') {
                        imagewebp($img);
                    } elseif ($mimeType === 'image/jpeg') {
                        imagejpeg($img);
                    } else {
                        imagepng($img);
                    }
                    $body = ob_get_clean();
                }
                imagedestroy($img);
            }
        }

        $extension = $mimeTypeToExtension($mimeType);
        $hash = hash('sha256', $body);
        $prefix = $isPublic ? 'public' : 'private';
        $key = "{$prefix}/{$bucketDirectory}/{$hash}.{$extension}";

        $exists = false;
        try {
            $client->headObject([
                'Bucket' => $bucket,
                'Key' => $key,
            ]);
            $exists = true;
        } catch (\Aws\S3\Exception\S3Exception $e) {
            // Preserve the existing fallback: upload when the head request fails.
        }

        if (!$exists) {
            $client->putObject([
                'Bucket' => $bucket,
                'Key' => $key,
                'Body' => $body,
                'ContentType' => $mimeType,
            ]);
        }

        return (object) [
            'src' => "{$prefix}/{$bucketDirectory}/{$hash}.{$extension}",
            'hash' => $hash,
            'mimeType' => $mimeType,
            'size' => strlen($body),
            'dimensions' => (object) ['width' => $width, 'height' => $height],
        ];
    });
};

$exports['_uploadHtmlUrlContentsImpl'] = static function (
    $client,
    $bucket,
    $isPublic,
    $bucketDirectory,
    $mimeTypeToExtension,
    $shouldRelativize,
    $host,
    $legacyHost,
    $contentHtml,
) use ($runAsync) {
    // HTML image rewriting is not implemented by this PHP adapter yet.
    return $runAsync(static fn() => $contentHtml);
};

return $exports;
