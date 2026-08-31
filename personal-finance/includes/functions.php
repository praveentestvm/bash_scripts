<?php
declare(strict_types=1);

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function appBaseUrl(): string
{
    global $config;
    return rtrim((string) ($config['app']['base_url'] ?? ''), '/');
}

function url(string $path = ''): string
{
    $base = appBaseUrl();
    $path = ltrim($path, '/');
    return $base . ($path !== '' ? '/' . $path : '/');
}

function asset(string $path): string
{
    return url('assets/' . ltrim($path, '/'));
}

function redirect(string $path): never
{
    header('Location: ' . url($path));
    exit;
}

function flash(string $key, ?string $message = null): ?string
{
    if ($message !== null) {
        $_SESSION['_flash'][$key] = $message;
        return null;
    }

    $value = $_SESSION['_flash'][$key] ?? null;
    unset($_SESSION['_flash'][$key]);
    return $value;
}

function money(float|int|string $amount): string
{
    return '₹' . number_format((float) $amount, 2);
}

function monthBounds(int $year, int $month): array
{
    $start = sprintf('%04d-%02d-01', $year, $month);
    return [$start, date('Y-m-d', strtotime($start . ' +1 month'))];
}

function validDate(string $date): bool
{
    $d = DateTime::createFromFormat('Y-m-d', $date);
    return $d instanceof DateTime && $d->format('Y-m-d') === $date;
}

function postString(string $key, string $default = ''): string
{
    return trim((string) ($_POST[$key] ?? $default));
}
