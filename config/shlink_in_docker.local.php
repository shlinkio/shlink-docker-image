<?php
declare(strict_types=1);

namespace Shlinkio\Shlink;

use function Shlinkio\Shlink\Common\env;
use function str_shuffle;
use function substr;

$helper = new class {
    private const CHARSET = '123456789bcdfghjkmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ';

    public function generateSecretKey(): string
    {
        return substr(str_shuffle(self::CHARSET), 0, 32);
    }

    public function generateShortcodeChars(): string
    {
        return str_shuffle(self::CHARSET);
    }

    public function getDbConfig(): array
    {
        $driver = env('DB_DRIVER');
        if ($driver === null || $driver === 'sqlite') {
            return [
                'driver' => 'pdo_sqlite',
                'path' => 'data/database.sqlite',
            ];
        }

        return [
            'driver' => 'pdo_mysql',
            'dbname' => env('DB_NAME', 'shlink'),
            'user' => env('DB_USER'),
            'password' => env('DB_PASSWORD'),
            'host' => env('DB_HOST'),
            'port' => env('DB_PORT', '3306'),
            'driverOptions' => [
                1002 => 'SET NAMES utf8',
            ],
        ];
    }

    public function getNotFoundConfig(): array
    {
        $notFoundRedirectTo = env('NOT_FOUND_REDIRECT_TO');

        return [
            'enable_redirection' => $notFoundRedirectTo !== null,
            'redirect_to' => $notFoundRedirectTo,
        ];
    }
};

return [

    'app_options' => [
        'secret_key' => $helper->generateSecretKey(),
        'disable_track_param' => env('DISABLE_TRACK_PARAM'),
    ],

    'delete_short_urls' => [
        'check_visits_threshold' => true,
        'visits_threshold' => (int) env('DELETE_SHORT_URL_THRESHOLD', 15),
    ],

    'translator' => [
        'locale' => env('LOCALE', 'en'),
    ],

    'entity_manager' => [
        'connection' => $helper->getDbConfig(),
    ],

    'url_shortener' => [
        'domain' => [
            'schema' => env('SHORT_DOMAIN_SCHEMA', 'http'),
            'hostname' => env('SHORT_DOMAIN_HOST', ''),
        ],
        'shortcode_chars' => $helper->generateShortcodeChars(),
        'validate_url' => (bool) env('VALIDATE_URLS', true),
        'not_found_short_url' => $helper->getNotFoundConfig(),
    ],

];
