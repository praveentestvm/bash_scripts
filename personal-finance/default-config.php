<?php
declare(strict_types=1);

return [
    'app' => [
        'name' => 'Personal Finance',
        'version' => '1.2.0',
        'environment' => 'production',
        'timezone' => 'Asia/Kolkata',
        // Empty means the application is installed at the domain root.
        // For /personal-finance, the installer automatically sets this to /personal-finance.
        'base_url' => '',
    ],
    'database' => [
        'host' => '127.0.0.1',
        'port' => 3306,
        'name' => 'personal_finance',
        'username' => 'database_user',
        'password' => 'database_password',
        'charset' => 'utf8mb4',
    ],
    'security' => [
        'session_name' => 'personal_finance_session',
        'password_reset_expiry_minutes' => 10,
        'password_reset_max_attempts' => 5,
    ],
    'mail' => [
        'enabled' => false,
        'host' => '',
        'port' => 587,
        'username' => '',
        'password' => '',
        'encryption' => 'tls',
        'from_email' => '',
        'from_name' => 'Personal Finance',
    ],
];
