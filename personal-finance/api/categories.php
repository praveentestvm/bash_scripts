<?php
require_once dirname(__DIR__).'/includes/bootstrap.php';requireLogin();
header('Content-Type: application/json; charset=utf-8');
$type=$_GET['type']??'expense';
if(!in_array($type,['income','expense'],true)){http_response_code(400);echo json_encode(['error'=>'Invalid type']);exit;}
$s=db()->prepare('SELECT id,name FROM categories WHERE type=? AND is_active=1 ORDER BY name');$s->execute([$type]);
echo json_encode($s->fetchAll(),JSON_UNESCAPED_UNICODE);exit;
