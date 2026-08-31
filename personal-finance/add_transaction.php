<?php
require_once __DIR__.'/includes/bootstrap.php';requireLogin();$errors=[];$type=$_POST['type']??'expense';$pdo=db();
$s=$pdo->prepare('SELECT id,name FROM categories WHERE type=? AND is_active=1 ORDER BY name');$s->execute([$type]);$categories=$s->fetchAll();
if($_SERVER['REQUEST_METHOD']==='POST'){verify_csrf();$type=in_array($_POST['type']??'', ['income','expense'],true)?$_POST['type']:'';$cid=(int)($_POST['category_id']??0);$amount=(float)($_POST['amount']??0);$payment=$_POST['payment_method']??'';$desc=trim((string)($_POST['description']??''));$date=$_POST['transaction_date']??'';
if(!$type)$errors[]='Select a valid transaction type.';if($amount<=0)$errors[]='Amount must be greater than zero.';if(!in_array($payment,['cash','debit_card','credit_card'],true))$errors[]='Select a valid payment method.';if(!validDate($date))$errors[]='Select a valid transaction date.';if(strlen($desc)>500)$errors[]='Description is too long.';
$s=$pdo->prepare('SELECT id FROM categories WHERE id=? AND type=? AND is_active=1');$s->execute([$cid,$type]);if(!$s->fetch())$errors[]='Invalid category.';
if(!$errors){$s=$pdo->prepare('INSERT INTO transactions(user_id,category_id,amount,type,payment_method,description,transaction_date) VALUES(?,?,?,?,?,?,?)');$s->execute([currentUserId(),$cid,$amount,$type,$payment,$desc?:null,$date]);flash('success','Transaction added.');redirect('view_transactions.php');}
$s=$pdo->prepare('SELECT id,name FROM categories WHERE type=? AND is_active=1 ORDER BY name');$s->execute([$type]);$categories=$s->fetchAll();}
$pageTitle='Add Transaction';include __DIR__.'/includes/header.php';
?>
<div class="card narrow-card"><h1>Add Transaction</h1><?php foreach($errors as $e1): ?><div class="alert error"><?= e($e1) ?></div><?php endforeach; ?>
<form method="post" id="transaction-form" data-category-url="<?= e(url('api/categories.php')) ?>"><?= csrf_field() ?>
<label>Type<select name="type" id="transaction-type"><option value="expense" <?= $type==='expense'?'selected':'' ?>>Expense</option><option value="income" <?= $type==='income'?'selected':'' ?>>Income</option></select></label>
<label>Category<select name="category_id" id="transaction-category" required><?php foreach($categories as $c): ?><option value="<?= e($c['id']) ?>" <?= (int)($_POST['category_id']??0)===(int)$c['id']?'selected':'' ?>><?= e($c['name']) ?></option><?php endforeach; ?></select></label>
<label>Amount (₹)<input type="number" step="0.01" min="0.01" name="amount" value="<?= e($_POST['amount']??'') ?>" required></label>
<label>Transaction Date<input type="date" name="transaction_date" value="<?= e($_POST['transaction_date']??date('Y-m-d')) ?>" required></label>
<fieldset><legend>Payment Method</legend><label class="radio"><input type="radio" name="payment_method" value="cash" <?= ($_POST['payment_method']??'cash')==='cash'?'checked':'' ?>> Cash</label><label class="radio"><input type="radio" name="payment_method" value="debit_card" <?= ($_POST['payment_method']??'')==='debit_card'?'checked':'' ?>> Debit Card</label><label class="radio"><input type="radio" name="payment_method" value="credit_card" <?= ($_POST['payment_method']??'')==='credit_card'?'checked':'' ?>> Credit Card</label></fieldset>
<label>Description / Notes<textarea name="description" maxlength="500" rows="4"><?= e($_POST['description']??'') ?></textarea></label><button type="submit" class="btn primary full">Save Transaction</button></form></div>
<?php include __DIR__.'/includes/footer.php'; ?>
