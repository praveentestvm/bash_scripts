<?php
declare(strict_types=1);

function isLoggedIn(): bool { return !empty($_SESSION['user_id']); }
function currentUserId(): int { return (int)($_SESSION['user_id'] ?? 0); }

function requireLogin(): void {
    if (!isLoggedIn()) redirect('login.php');
}

function requireSuperAdmin(): void {
    requireLogin();
    if ((int)($_SESSION['role_id'] ?? 0) !== 1) {
        http_response_code(403);
        exit('Access denied.');
    }
}

function loginUser(array $user): void {
    session_regenerate_id(true);
    $_SESSION['user_id'] = (int)$user['id'];
    $_SESSION['role_id'] = (int)$user['role_id'];
    $_SESSION['username'] = $user['username'];
    $_SESSION['email'] = $user['email'];
}

function logoutUser(): void {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
    }
    session_destroy();
}
