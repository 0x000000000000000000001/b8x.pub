<?php

$_createInnerClient = function($region, $accessKeyId = null, $secretAccessKey = null) use (&$_createInnerClient) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_createInnerClient) {
            return $_createInnerClient(...\array_merge($__args, $more));
        };
    }
    return function() use ($region, $accessKeyId, $secretAccessKey) {
        return new \Aws\S3\S3Client([
            'region' => $region,
            'version' => 'latest',
            'credentials' => [
                'key' => $accessKeyId,
                'secret' => $secretAccessKey
            ]
        ]);
    };
};
$exports['_createInnerClient'] = $_createInnerClient;

$_uploadUrlContentImpl = function($newPromise, $client = null, $bucket = null, $isPublic = null, $bucketDirectory = null, $autocropBlackWhite = null, $autocropTransparent = null, $url = null, $mimeTypeToExtension = null) use (&$_uploadUrlContentImpl) {
    if (\func_num_args() < 9) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_uploadUrlContentImpl) {
            return $_uploadUrlContentImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $client, $bucket, $isPublic, $bucketDirectory, $autocropBlackWhite, $autocropTransparent, $url, $mimeTypeToExtension) {
        return $newPromise(function($resolve, $reject) use ($client, $bucket, $isPublic, $bucketDirectory, $autocropBlackWhite, $autocropTransparent, $url, $mimeTypeToExtension) {
            \Amp\async(function() use ($resolve, $reject, $client, $bucket, $isPublic, $bucketDirectory, $autocropBlackWhite, $autocropTransparent, $url, $mimeTypeToExtension) {
                try {
                    $httpClient = \Amp\Http\Client\HttpClientBuilder::buildDefault();
                    $request = new \Amp\Http\Client\Request($url);
                    $request->setHeader('User-Agent', 'Mozilla/5.0');
                    
                    $response = $httpClient->request($request);
                    $body = $response->getBody()->buffer();
                    
                    if (empty($body)) {
                        throw new \Exception("Failed to fetch image from $url");
                    }
                    
                    $mimeType = null;
                    $finfo = new \finfo(FILEINFO_MIME_TYPE);
                    $mimeType = $finfo->buffer($body);
                    
                    if (strpos($mimeType, 'text/html') !== false) {
                        throw new \Exception('Skipping HTML content for S3 upload');
                    }

                    $width = null;
                    $height = null;
                    if (strpos($mimeType, 'image/') === 0 && function_exists('imagecreatefromstring')) {
                        $img = @imagecreatefromstring($body);
                        if ($img !== false) {
                            $cropped = false;
                            if ($autocropBlackWhite) {
                                $croppedImg = imagecropauto($img, IMG_CROP_WHITE);
                                if ($croppedImg !== false) { $img = $croppedImg; $cropped = true; }
                                $croppedImg = imagecropauto($img, IMG_CROP_BLACK);
                                if ($croppedImg !== false) { $img = $croppedImg; $cropped = true; }
                            }
                            if ($autocropTransparent) {
                                $croppedImg = imagecropauto($img, IMG_CROP_TRANSPARENT);
                                if ($croppedImg !== false) { $img = $croppedImg; $cropped = true; }
                            }
                            $width = imagesx($img);
                            $height = imagesy($img);
                            
                            if ($cropped) {
                                ob_start();
                                if ($mimeType === 'image/png') imagepng($img);
                                elseif ($mimeType === 'image/webp') imagewebp($img);
                                elseif ($mimeType === 'image/jpeg') imagejpeg($img);
                                else imagepng($img);
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
                            'Key' => $key
                        ]);
                        $exists = true;
                    } catch (\Aws\S3\Exception\S3Exception $e) {
                        // ignore if 404
                    }

                    if (!$exists) {
                        $client->putObject([
                            'Bucket' => $bucket,
                            'Key' => $key,
                            'Body' => $body,
                            'ContentType' => $mimeType
                        ]);
                    }

                    $resolve((object)[
                        'src' => "{$prefix}/{$bucketDirectory}/{$hash}.{$extension}",
                        'hash' => $hash,
                        'mimeType' => $mimeType,
                        'size' => strlen($body),
                        'dimensions' => ($width !== null && $height !== null) ? (object)['width' => $width, 'height' => $height, 'type' => $extension] : null
                    ]);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_uploadUrlContentImpl'] = $_uploadUrlContentImpl;

$_uploadHtmlUrlContentsImpl = function($newPromise, $client = null, $bucket = null, $isPublic = null, $bucketDirectory = null, $mimeTypeToExtension = null, $shouldRelativize = null, $host = null, $legacyHost = null, $contentHtml = null) use (&$_uploadHtmlUrlContentsImpl) {
    if (\func_num_args() < 10) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_uploadHtmlUrlContentsImpl) {
            return $_uploadHtmlUrlContentsImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $client, $bucket, $isPublic, $bucketDirectory, $mimeTypeToExtension, $shouldRelativize, $host, $legacyHost, $contentHtml) {
        return $newPromise(function($resolve, $reject) use ($client, $bucket, $isPublic, $bucketDirectory, $mimeTypeToExtension, $shouldRelativize, $host, $legacyHost, $contentHtml) {
            \Amp\async(function() use ($resolve, $contentHtml) {
                $resolve($contentHtml);
            });
        });
    };
};
$exports['_uploadHtmlUrlContentsImpl'] = $_uploadHtmlUrlContentsImpl;

return $exports;
