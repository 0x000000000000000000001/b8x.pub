<?php

$_createInnerClient = function($region, $accessKeyId = null, $secretAccessKey = null) use (&$_createInnerClient) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_createInnerClient) {
            return $_createInnerClient(...\array_merge($__args, $more));
        };
    }
    return function() use ($region, $accessKeyId, $secretAccessKey) {
        return new \Aws\Ses\SesClient([
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

$_sendMailImpl = function($newPromise, $client = null, $options = null) use (&$_sendMailImpl) {
    if (\func_num_args() < 3) {
        $__args = \func_get_args();
        return function(...$more) use ($__args, &$_sendMailImpl) {
            return $_sendMailImpl(...\array_merge($__args, $more));
        };
    }
    return function() use ($newPromise, $client, $options) {
        return $newPromise(function($resolve, $reject) use ($client, $options) {
            \Amp\async(function() use ($resolve, $reject, $client, $options) {
                try {
                    $body = [];
                    if (property_exists($options, 'html') && !empty($options->html)) {
                        $body['Html'] = [
                            'Charset' => 'UTF-8',
                            'Data' => $options->html
                        ];
                    }
                    if (property_exists($options, 'text') && !empty($options->text)) {
                        $body['Text'] = [
                            'Charset' => 'UTF-8',
                            'Data' => $options->text
                        ];
                    }

                    $toName = property_exists($options->to, 'name') ? $options->to->name : '';
                    $toEmail = property_exists($options->to, 'email') ? $options->to->email : '';
                    $destination = !empty($toName) ? "{$toName} <{$toEmail}>" : $toEmail;

                    $fromName = property_exists($options->from, 'name') ? $options->from->name : '';
                    $fromEmail = property_exists($options->from, 'email') ? $options->from->email : '';
                    $source = !empty($fromName) ? "{$fromName} <{$fromEmail}>" : $fromEmail;

                    $result = $client->sendEmail([
                        'Destination' => [
                            'ToAddresses' => [$destination],
                        ],
                        'Message' => [
                            'Body' => $body,
                            'Subject' => [
                                'Charset' => 'UTF-8',
                                'Data' => $options->subject,
                            ],
                        ],
                        'Source' => $source,
                    ]);

                    $resolve($result);
                } catch (\Throwable $e) {
                    $reject($e);
                }
            });
        });
    };
};
$exports['_sendMailImpl'] = $_sendMailImpl;

return $exports;
