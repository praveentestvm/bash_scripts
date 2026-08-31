<?php
declare(strict_types=1);
if(!is_file(__DIR__.'/config.php')){header('Location: setup.php');exit;}
require_once __DIR__.'/includes/bootstrap.php';
redirect(isLoggedIn()?'dashboard.php':'login.php');
