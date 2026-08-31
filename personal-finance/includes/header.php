<?php
declare(strict_types=1);
$pageTitle = $pageTitle ?? $config['app']['name'];
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= e($pageTitle) ?> · <?= e($config['app']['name']) ?></title>
<link rel="stylesheet" href="<?= e(asset('css/app.css')) ?>">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.0/dist/chart.umd.min.js"></script>
</head>
<body>
<header class="topbar">
<div class="container topbar-inner">
<a class="brand" href="<?= e(url('dashboard.php')) ?>">🌿 <?= e($config['app']['name']) ?></a>
<?php if (isLoggedIn()): ?>
<nav class="nav">
<a href="<?= e(url('dashboard.php')) ?>">Dashboard</a>
<a href="<?= e(url('view_transactions.php')) ?>">Transactions</a>
<a href="<?= e(url('budget.php')) ?>">Budget</a>
<a href="<?= e(url('goals.php')) ?>">Goals</a>
<?php if ((int)($_SESSION['role_id'] ?? 0) === 1): ?><a href="<?= e(url('admin/categories.php')) ?>">Admin</a><?php endif; ?>
<a href="<?= e(url('profile.php')) ?>">Profile</a>
<a href="<?= e(url('logout.php')) ?>">Logout</a>
</nav>
<?php endif; ?>
</div>
</header>
<main class="container page">
<?php if ($m=flash('success')): ?><div class="alert success"><?= e($m) ?></div><?php endif; ?>
<?php if ($m=flash('error')): ?><div class="alert error"><?= e($m) ?></div><?php endif; ?>
