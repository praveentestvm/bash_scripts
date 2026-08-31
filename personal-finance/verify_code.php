<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

if (empty($_SESSION['reset_email'])) {
    redirect('forgot_password.php');
}

$errors = [];
$maxAttempts = (int) ($config['security']['password_reset_max_attempts'] ?? 5);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $code = trim((string) ($_POST['code'] ?? ''));

    if (!preg_match('/^\d{6}$/', $code)) {
        $errors[] = 'Enter a 6-digit numeric code.';
    } else {
        $stmt = db()->prepare(
            'SELECT pr.*
             FROM password_reset_codes pr
             JOIN users u ON u.id=pr.user_id
             WHERE u.email=? AND pr.used_at IS NULL
             ORDER BY pr.id DESC LIMIT 1'
        );
        $stmt->execute([$_SESSION['reset_email']]);
        $reset = $stmt->fetch();

        $valid = $reset
            && (int) $reset['attempts'] < $maxAttempts
            && strtotime((string) $reset['expires_at']) >= time()
            && password_verify($code, (string) $reset['code_hash']);

        if (!$valid) {
            $errors[] = 'Invalid or expired verification code.';
            if ($reset && (int) $reset['attempts'] < $maxAttempts) {
                db()->prepare(
                    'UPDATE password_reset_codes SET attempts=attempts+1 WHERE id=?'
                )->execute([(int) $reset['id']]);
            }
        } else {
            $_SESSION['verified_reset_id'] = (int) $reset['id'];
            redirect('reset_password.php');
        }
    }
}

$pageTitle = 'Verify Code';
include __DIR__ . '/includes/header.php';
?>
<div class="auth-card narrow">
    <h1>Verify Code</h1>
    <?php foreach ($errors as $error): ?><div class="alert error"><?= e($error) ?></div><?php endforeach; ?>
    <p>Enter the 6-digit code sent to your email.</p>
    <form method="post">
        <?= csrf_field() ?>
        <label>Verification Code<input inputmode="numeric" pattern="[0-9]{6}" maxlength="6" name="code" autocomplete="one-time-code" required></label>
        <button class="btn primary full" type="submit">Verify Code</button>
    </form>
</div>
<?php include __DIR__ . '/includes/footer.php'; ?>
