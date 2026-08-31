<?php
require_once __DIR__.'/includes/bootstrap.php';
if(isLoggedIn()) redirect('dashboard.php');
$errors=[];
if($_SERVER['REQUEST_METHOD']==='POST'){
    verify_csrf();
    $login=trim((string)($_POST['login']??'')); $password=(string)($_POST['password']??'');
    $stmt=db()->prepare('SELECT id,username,email,password_hash,role_id FROM users WHERE (email=? OR username=?) AND is_active=1 LIMIT 1');
    $stmt->execute([$login,$login]);
    $user=$stmt->fetch();
    if($user && password_verify($password,$user['password_hash'])){ loginUser($user); redirect('dashboard.php'); }
    $errors[]='Invalid login credentials.';
}
$pageTitle='Login'; include __DIR__.'/includes/header.php';
?>
<div class="auth-card narrow"><h1>Welcome back</h1>
<?php foreach($errors as $e1): ?><div class="alert error"><?= e($e1) ?></div><?php endforeach; ?>
<form method="post"><?= csrf_field() ?><label>Email or Username<input name="login" autocomplete="username" required></label>
<label>Password<input type="password" name="password" autocomplete="current-password" required></label>
<button type="submit" class="btn primary full">Login</button></form>
<div class="auth-links"><a href="<?= e(url('register.php')) ?>">Create Account</a><a href="<?= e(url('forgot_password.php')) ?>">Forgot Password?</a></div></div>
<?php include __DIR__.'/includes/footer.php'; ?>
