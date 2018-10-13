<?php
declare(strict_types=1);

use Monolog\Handler\StreamHandler;
use Monolog\Logger;
use Monolog\Processor\PsrLogMessageProcessor;

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

];
