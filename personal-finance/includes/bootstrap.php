<?php
declare(strict_types=1);

define('APP_ROOT', dirname(__DIR__));
$configFile = APP_ROOT . '/config.php';

if (!is_file($configFile)) {
    header('Location: setup.php');
    exit;
}

$config = require $configFile;

date_default_timezone_set((string) ($config['app']['timezone'] ?? 'UTC'));

require_once APP_ROOT . '/includes/functions.php';
require_once APP_ROOT . '/includes/db.php';
require_once APP_ROOT . '/includes/csrf.php';
require_once APP_ROOT . '/includes/auth.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_name((string) ($config['security']['session_name'] ?? 'personal_finance_session'));
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'secure' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}
