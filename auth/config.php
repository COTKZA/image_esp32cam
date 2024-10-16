<?php
// connect_db.php
$host = "localhost";
$user = "root";
$pass = "";
$db = "esp23cam_image";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>