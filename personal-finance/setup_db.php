<?php
declare(strict_types=1);

function installDatabase(PDO $pdo): void
{
    $schemaFile = __DIR__ . '/database/schema.sql';
    $sql = file_get_contents($schemaFile);

    if ($sql === false) {
        throw new RuntimeException('Unable to read database schema.');
    }

    $pdo->exec($sql);
}
