<?php
declare(strict_types=1);

namespace Shlinkio\Shlink;

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
};

return [

    'app_options' => [
        'secret_key' => $helper->generateSecretKey(),
        'disable_track_param' => null,
    ],

    'entity_manager' => [
        'connection' => [
            'driver' => 'pdo_sqlite',
            'path' => 'data/database.sqlite',
            'dbname' => 'shlink',
            'driverOptions' => [
                1002 => 'SET NAMES utf8',
            ],
        ],
    ],

    'url_shortener' => [
        'shortcode_chars' => $helper->generateShortcodeChars(),
        'validate_url' => true,
    ],

];
