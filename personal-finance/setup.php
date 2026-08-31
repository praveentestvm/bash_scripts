<?php
declare(strict_types=1);
require_once __DIR__ . '/includes/functions.php';

if (is_file(__DIR__ . '/config.php')) {
    http_response_code(403);
    exit('The application is already configured.');
}

$defaults = require __DIR__ . '/default-config.php';
$errors=[]; $success=false;

function writeConfig(array $config): void {
    $content="<?php\nreturn ".var_export($config,true).";\n";
    if (file_put_contents(__DIR__.'/config.php',$content,LOCK_EX)===false)
        throw new RuntimeException('Unable to write config.php.');
}

if ($_SERVER['REQUEST_METHOD']==='POST') {
    try {
        $db=[
            'host'=>trim((string)($_POST['db_host']??'')),
            'port'=>max(1,(int)($_POST['db_port']??3306)),
            'name'=>trim((string)($_POST['db_name']??'')),
            'username'=>trim((string)($_POST['db_user']??'')),
            'password'=>(string)($_POST['db_password']??''),
            'charset'=>'utf8mb4'
        ];
        $au=trim((string)($_POST['admin_username']??''));
        $ae=strtolower(trim((string)($_POST['admin_email']??'')));
        $ap=(string)($_POST['admin_password']??'');
        $ac=(string)($_POST['admin_confirm']??'');

        if ($db['host']===''||$db['name']===''||$db['username']==='') $errors[]='Database host, name and username are required.';
        if (!preg_match('/^[A-Za-z0-9_]{3,50}$/',$au)) $errors[]='Admin username must be 3-50 characters using letters, numbers or underscore.';
        if (!filter_var($ae,FILTER_VALIDATE_EMAIL)) $errors[]='Enter a valid admin email.';
        if (strlen($ap)<10) $errors[]='Admin password must be at least 10 characters.';
        if (!hash_equals($ap,$ac)) $errors[]='Admin passwords do not match.';

        $mail=[
            'enabled'=>!empty($_POST['mail_enabled']),
            'host'=>trim((string)($_POST['mail_host']??'')),
            'port'=>max(1,(int)($_POST['mail_port']??587)),
            'username'=>trim((string)($_POST['mail_username']??'')),
            'password'=>(string)($_POST['mail_password']??''),
            'encryption'=>in_array($_POST['mail_encryption']??'tls',['tls','ssl','none'],true)?$_POST['mail_encryption']:'tls',
            'from_email'=>strtolower(trim((string)($_POST['mail_from_email']??''))),
            'from_name'=>trim((string)($_POST['mail_from_name']??'Personal Finance'))
        ];
        if ($mail['enabled']) {
            if ($mail['host'] === '' || !filter_var($mail['from_email'], FILTER_VALIDATE_EMAIL)) {
                $errors[] = 'SMTP host and valid From email are required when SMTP is enabled.';
            }
            if ($mail['username'] === '' || $mail['password'] === '') {
                $errors[] = 'SMTP username and password are required when SMTP is enabled.';
            }
        }

        if (!$errors) {
            $live=$defaults; $live['database']=$db; $live['mail']=$mail;
            $pdo=new PDO("mysql:host={$db['host']};port={$db['port']};charset=utf8mb4",$db['username'],$db['password'],[
                PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES=>false
            ]);
            $name=str_replace('`','``',$db['name']);
            $pdo->exec("CREATE DATABASE IF NOT EXISTS `{$name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            $pdo->exec("USE `{$name}`");
            require_once __DIR__.'/setup_db.php';
            installDatabase($pdo);

            $role=$pdo->query("SELECT id FROM roles WHERE name='Super Admin' LIMIT 1")->fetchColumn();
            $stmt=$pdo->prepare('INSERT INTO users(username,email,password_hash,role_id) VALUES(?,?,?,?)');
            $stmt->execute([$au,$ae,password_hash($ap,PASSWORD_DEFAULT),(int)$role]);
            $pdo->prepare("INSERT INTO system_settings(setting_key,setting_value) VALUES('installation_completed','1') ON DUPLICATE KEY UPDATE setting_value='1'")->execute();

            // For /personal-finance installed under web root, derive the URL prefix from the request.
            $live['app']['base_url'] = rtrim(str_replace('\\','/',dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
            if ($live['app']['base_url']==='/') $live['app']['base_url']='';
            writeConfig($live);
            $success=true;
        }
    } catch(Throwable $e) {
        if (is_file(__DIR__.'/config.php')) @unlink(__DIR__.'/config.php');
        $errors[]='Installation failed: '.$e->getMessage();
    }
}
$setupBase = rtrim(str_replace('\\','/',dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
$setupAsset = function(string $p) use ($setupBase): string { return $setupBase.'/assets/'.$p; };
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Install · Personal Finance</title><link rel="stylesheet" href="<?= e($setupAsset('css/app.css')) ?>"></head>
<body class="auth-page"><div class="auth-card wide">
<div class="brand large">🌿 Personal Finance</div><h1>First-time installation</h1>
<?php if($success): ?><div class="alert success">Installation completed successfully.</div><p>Your database, roles, categories and Super Admin account are ready.</p><a class="btn primary full" href="<?= e($setupBase.'/login.php') ?>">Go to Login</a>
<?php else: ?>
<?php foreach($errors as $error): ?><div class="alert error"><?= e($error) ?></div><?php endforeach; ?>
<form method="post" class="form-grid">
<section class="card"><h2>Database</h2>
<label>DB Host<input name="db_host" value="<?= e($_POST['db_host']??$defaults['database']['host']) ?>" required></label>
<label>DB Port<input type="number" name="db_port" value="<?= e($_POST['db_port']??$defaults['database']['port']) ?>" required></label>
<label>DB Name<input name="db_name" value="<?= e($_POST['db_name']??$defaults['database']['name']) ?>" required></label>
<label>DB User<input name="db_user" value="<?= e($_POST['db_user']??'') ?>" required></label>
<label>DB Password<input type="password" name="db_password"></label></section>
<section class="card"><h2>Super Admin</h2>
<label>Username<input name="admin_username" value="<?= e($_POST['admin_username']??'') ?>" required></label>
<label>Email<input type="email" name="admin_email" value="<?= e($_POST['admin_email']??'') ?>" required></label>
<label>Password<input type="password" name="admin_password" required></label>
<label>Confirm Password<input type="password" name="admin_confirm" required></label></section>
<section class="card full-span"><h2>Email / SMTP <small>(optional)</small></h2>
<label class="check"><input type="checkbox" name="mail_enabled" <?= !empty($_POST['mail_enabled'])?'checked':'' ?>> Enable SMTP</label>
<div class="form-grid compact">
<label>SMTP Host<input name="mail_host" value="<?= e($_POST['mail_host']??'') ?>"></label>
<label>SMTP Port<input type="number" name="mail_port" value="<?= e($_POST['mail_port']??587) ?>"></label>
<label>SMTP Username<input name="mail_username" value="<?= e($_POST['mail_username']??'') ?>"></label>
<label>SMTP Password<input type="password" name="mail_password"></label>
<label>Encryption<select name="mail_encryption"><option value="tls">TLS</option><option value="ssl">SSL</option><option value="none">None</option></select></label>
<label>From Email<input type="email" name="mail_from_email" value="<?= e($_POST['mail_from_email']??'') ?>"></label>
<label>From Name<input name="mail_from_name" value="<?= e($_POST['mail_from_name']??'Personal Finance') ?>"></label>
</div></section>
<button class="btn primary full-span" type="submit">Install Application</button>
</form><?php endif; ?></div></body></html>
