<?php
declare(strict_types=1);

require_once APP_ROOT . '/vendor/autoload.php';

use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\PHPMailer;

/**
 * Send a password-reset verification code.
 *
 * SMTP credentials are read from config.php. Never log the password or code.
 * Exceptions are intentionally propagated to the caller so the caller can
 * invalidate the pending reset and show a friendly message.
 */
function sendPasswordResetCode(string $email, string $username, string $code): void
{
    global $config;

    if (empty($config['mail']['enabled'])) {
        throw new RuntimeException('Password reset email is not configured.');
    }

    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = (string) $config['mail']['host'];
    $mail->Port = (int) $config['mail']['port'];
    $mail->SMTPAuth = trim((string) $config['mail']['username']) !== '';
    $mail->Username = (string) $config['mail']['username'];
    $mail->Password = (string) $config['mail']['password'];
    $mail->Timeout = 15;

    switch ($config['mail']['encryption'] ?? 'tls') {
        case 'tls':
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            break;
        case 'ssl':
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            break;
        case 'none':
            $mail->SMTPAutoTLS = false;
            break;
        default:
            throw new RuntimeException('Invalid SMTP encryption setting.');
    }

    $mail->CharSet = 'UTF-8';
    $mail->setFrom(
        (string) $config['mail']['from_email'],
        (string) $config['mail']['from_name']
    );
    $mail->addAddress($email, $username);
    $mail->Subject = 'Your Personal Finance verification code';

    $mail->Body = <<<TEXT
Hello {$username},

Your Personal Finance password reset verification code is:

{$code}

This code expires in {$config['security']['password_reset_expiry_minutes']} minutes.

If you did not request a password reset, you can safely ignore this email.

Regards,
Personal Finance
TEXT;

    $mail->AltBody = $mail->Body;

    try {
        $mail->send();
    } catch (Exception $e) {
        error_log('Password reset email failed: ' . $mail->ErrorInfo);
        throw $e;
    }
}
