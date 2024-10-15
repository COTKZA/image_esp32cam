<?php
// config.php
$host = 'localhost'; // Your database host
$user = 'root';      // Your database username
$password = '';      // Your database password
$database = 'esp23cam_image'; // Your database name

// Create connection
$conn = new mysqli($host, $user, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['error' => 'Connection failed: ' . $conn->connect_error]));
}
?>
