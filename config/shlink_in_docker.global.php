<?php
declare(strict_types=1);

namespace Shlinkio\Shlink;

use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Monolog\Processor\PsrLogMessageProcessor;

use function str_shuffle;
use function substr;

return [

    'zend-expressive-swoole' => [
        'swoole-http-server' => [
            'host' => '0.0.0.0',

            'options' => [
                'enable_coroutine' => true,
            ],
        ],
    ],

    'logger' => [
        'handlers' => [
            'stdout_handler' => [
                'class' => StreamHandler::class,
                'filename' => 'php://stdout',
                'level' => Logger::INFO,
            ],
        ],

        'processors' => [
            'psr3' => [
                'class' => PsrLogMessageProcessor::class,
            ],
        ],

        'loggers' => [
            'ShlinkWithSwoole' => [
                'handlers' => ['stdout_handler'],
                'processors' => ['psr3'],
            ],
        ],
    ],

    'dependencies' => [
        'aliases' => [
            // This alias will make all services depending on the shlink logger, to use the shlink-with-swoole logger
            // instead
            'Logger_Shlink' => 'Logger_ShlinkWithSwoole'
        ],
    ],

    'app_options' => [
        'secret_key' => substr(str_shuffle('123456789bcdfghjkmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'), 0, 32),
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
        'shortcode_chars' => str_shuffle('123456789bcdfghjkmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'),
        'validate_url' => true,
    ],

];
