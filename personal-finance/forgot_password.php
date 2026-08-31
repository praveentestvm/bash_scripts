<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

$notice = null;
$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();

    $email = strtolower(trim((string) ($_POST['email'] ?? '')));

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Enter a valid email address.';
    } else {
        $pdo = db();
        $stmt = $pdo->prepare(
            'SELECT id,email,username FROM users WHERE email=? AND is_active=1 LIMIT 1'
        );
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if ($user) {
            $pdo->prepare(
                'UPDATE password_reset_codes SET used_at=NOW() WHERE user_id=? AND used_at IS NULL'
            )->execute([(int) $user['id']]);

            $code = (string) random_int(100000, 999999);
            $expiryMinutes = (int) ($config['security']['password_reset_expiry_minutes'] ?? 10);
            $expires = date('Y-m-d H:i:s', time() + ($expiryMinutes * 60));

            $stmt = $pdo->prepare(
                'INSERT INTO password_reset_codes(user_id,code_hash,expires_at) VALUES(?,?,?)'
            );
            $stmt->execute([
                (int) $user['id'],
                password_hash($code, PASSWORD_DEFAULT),
                $expires,
            ]);
            $resetId = (int) $pdo->lastInsertId();

            try {
                require_once __DIR__ . '/includes/mailer.php';
                sendPasswordResetCode($user['email'], $user['username'], $code);
                $_SESSION['reset_email'] = $user['email'];
                $notice = 'If an account exists for that email, a verification code has been sent.';
            } catch (Throwable $e) {
                // Never expose SMTP credentials or PHPMailer internals to the user.
                $pdo->prepare(
                    'UPDATE password_reset_codes SET used_at=NOW() WHERE id=?'
                )->execute([$resetId]);
                error_log('Password reset request could not send email: ' . $e->getMessage());
                $errors[] = 'We could not send the verification email right now. Please try again later.';
            }
        } else {
            // Avoid account enumeration.
            $notice = 'If an account exists for that email, a verification code has been sent.';
        }
    }
}

$pageTitle = 'Forgot Password';
include __DIR__ . '/includes/header.php';
?>
<div class="auth-card narrow">
    <h1>Forgot Password</h1>
    <?php if ($notice): ?><div class="alert success"><?= e($notice) ?></div><?php endif; ?>
    <?php foreach ($errors as $error): ?><div class="alert error"><?= e($error) ?></div><?php endforeach; ?>
    <form method="post">
        <?= csrf_field() ?>
        <label>Email<input type="email" name="email" autocomplete="email" required></label>
        <button class="btn primary full" type="submit">Send Verification Code</button>
    </form>
    <div class="auth-links">
        <a href="<?= e(url('verify_code.php')) ?>">I have a code</a>
        <a href="<?= e(url('login.php')) ?>">Back to Login</a>
    </div>
</div>
<?php include __DIR__ . '/includes/footer.php'; ?>
