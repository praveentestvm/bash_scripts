<?php
require_once __DIR__.'/includes/bootstrap.php';
if(isLoggedIn()) redirect('dashboard.php');
$errors=[];
if($_SERVER['REQUEST_METHOD']==='POST'){
 verify_csrf(); $username=trim((string)($_POST['username']??'')); $email=strtolower(trim((string)($_POST['email']??''))); $password=(string)($_POST['password']??''); $confirm=(string)($_POST['confirm']??'');
 if(!preg_match('/^[A-Za-z0-9_]{3,50}$/',$username))$errors[]='Username must be 3-50 characters using letters, numbers or underscore.';
 if(!filter_var($email,FILTER_VALIDATE_EMAIL))$errors[]='Enter a valid email.';
 if(strlen($password)<10)$errors[]='Password must be at least 10 characters.';
 if($password!==$confirm)$errors[]='Passwords do not match.';
 $s=db()->prepare('SELECT id FROM users WHERE email=? OR username=? LIMIT 1');$s->execute([$email,$username]);if($s->fetch())$errors[]='Username or email is already in use.';
 if(!$errors){$role=db()->query("SELECT id FROM roles WHERE name='Standard User' LIMIT 1")->fetchColumn();$s=db()->prepare('INSERT INTO users(username,email,password_hash,role_id) VALUES(?,?,?,?)');$s->execute([$username,$email,password_hash($password,PASSWORD_DEFAULT),(int)$role]);flash('success','Account created. You can now log in.');redirect('login.php');}
}
$pageTitle='Create Account';include __DIR__.'/includes/header.php';
?>
<div class="auth-card narrow"><h1>Create Account</h1><?php foreach($errors as $e1): ?><div class="alert error"><?= e($e1) ?></div><?php endforeach; ?>
<form method="post"><?= csrf_field() ?><label>Username<input name="username" value="<?= e($_POST['username']??'') ?>" required></label><label>Email<input type="email" name="email" value="<?= e($_POST['email']??'') ?>" required></label><label>Password<input type="password" name="password" required></label><label>Confirm Password<input type="password" name="confirm" required></label><button type="submit" class="btn primary full">Create Account</button></form>
<div class="auth-links"><a href="<?= e(url('login.php')) ?>">Back to Login</a></div></div>
<?php include __DIR__.'/includes/footer.php'; ?>
