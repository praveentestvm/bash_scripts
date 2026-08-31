<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

if (empty($_SESSION['verified_reset_id'])) {
    redirect('forgot_password.php');
}

$errors = [];
$resetId = (int) $_SESSION['verified_reset_id'];

$stmt = db()->prepare(
    'SELECT * FROM password_reset_codes WHERE id=? AND used_at IS NULL LIMIT 1'
);
$stmt->execute([$resetId]);
$reset = $stmt->fetch();

if (!$reset || strtotime((string) $reset['expires_at']) < time()) {
    unset($_SESSION['verified_reset_id'], $_SESSION['reset_email']);
    redirect('forgot_password.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();

    $password = (string) ($_POST['password'] ?? '');
    $confirm = (string) ($_POST['confirm'] ?? '');

    if (strlen($password) < 10) {
        $errors[] = 'Password must be at least 10 characters.';
    }
    if ($password !== $confirm) {
        $errors[] = 'Passwords do not match.';
    }

    if (!$errors) {
        $pdo = db();
        try {
            $pdo->beginTransaction();
            $pdo->prepare(
                'UPDATE users SET password_hash=? WHERE id=?'
            )->execute([
                password_hash($password, PASSWORD_DEFAULT),
                (int) $reset['user_id'],
            ]);
            $pdo->prepare(
                'UPDATE password_reset_codes SET used_at=NOW() WHERE id=?'
            )->execute([$resetId]);
            $pdo->commit();

            unset($_SESSION['verified_reset_id'], $_SESSION['reset_email']);
            flash('success', 'Password reset successfully. Please log in.');
            redirect('login.php');
        } catch (Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            error_log('Password reset failed: ' . $e->getMessage());
            $errors[] = 'Unable to reset the password right now. Please try again.';
        }
    }
}

$pageTitle = 'Reset Password';
include __DIR__ . '/includes/header.php';
?>
<div class="auth-card narrow">
    <h1>Reset Password</h1>
    <?php foreach ($errors as $error): ?><div class="alert error"><?= e($error) ?></div><?php endforeach; ?>
    <form method="post">
        <?= csrf_field() ?>
        <label>New Password<input type="password" name="password" autocomplete="new-password" required></label>
        <label>Confirm Password<input type="password" name="confirm" autocomplete="new-password" required></label>
        <button class="btn primary full" type="submit">Reset Password</button>
    </form>
</div>
<?php include __DIR__ . '/includes/footer.php'; ?>
