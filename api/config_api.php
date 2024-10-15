<?php
$host = '127.0.0.1'; // Database host
$user = 'root'; // Database username
$password = ''; // Database password
$dbname = 'esp23cam_image'; // Database name

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo "Connection failed: " . $e->getMessage();
}
?>
