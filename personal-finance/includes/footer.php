</main>
<?php if (isLoggedIn()): ?><a class="floating-add" href="<?= e(url('add_transaction.php')) ?>" aria-label="Add transaction">+</a><?php endif; ?>
<footer class="footer"><div class="container">Personal Finance · <?= e($config['app']['version']) ?></div></footer>
<script src="<?= e(asset('js/app.js')) ?>"></script>
<script src="<?= e(asset('js/dashboard.js')) ?>"></script>
<script src="<?= e(asset('js/transactions.js')) ?>"></script>
</body>
</html>
