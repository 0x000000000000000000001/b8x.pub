<?php

$exports['_createInnerClient'] = static function ($region, $accessKeyId, $secretAccessKey) {
    return new \Aws\Ses\SesClient([
        'region' => $region,
        'version' => 'latest',
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

$exports['_sendMailImpl'] = static function ($client, $fromName, $fromEmail, $toName, $toEmail, $subject, $text, $html) use ($runAsync) {
    return $runAsync(static function () use ($client, $fromName, $fromEmail, $toName, $toEmail, $subject, $text, $html) {
        $body = [];
        if (!empty($html)) {
            $body['Html'] = [
                'Charset' => 'UTF-8',
                'Data' => $html,
            ];
        }
        if (!empty($text)) {
            $body['Text'] = [
                'Charset' => 'UTF-8',
                'Data' => $text,
            ];
        }

        $destination = !empty($toName) ? "{$toName} <{$toEmail}>" : $toEmail;

        $source = !empty($fromName) ? "{$fromName} <{$fromEmail}>" : $fromEmail;

        $client->sendEmail([
            'Destination' => [
                'ToAddresses' => [$destination],
            ],
            'Message' => [
                'Body' => $body,
                'Subject' => [
                    'Charset' => 'UTF-8',
                    'Data' => $subject,
                ],
            ],
            'Source' => $source,
        ]);

        return null;
    });
};

return $exports;
