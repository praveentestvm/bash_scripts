<?php require_once dirname(__DIR__).'/includes/bootstrap.php';requireSuperAdmin();$pageTitle='Admin';include dirname(__DIR__).'/includes/header.php'; ?>
<div class="page-heading"><div><h1>Admin</h1><p>System management.</p></div></div><a class="card block-card" href="<?= e(url('admin/categories.php')) ?>"><h2>Categories</h2><p>Manage income and expense categories.</p></a>
<?php include dirname(__DIR__).'/includes/footer.php'; ?>
