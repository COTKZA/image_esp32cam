<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

require 'config_api.php';

$request_method = $_SERVER["REQUEST_METHOD"];

switch ($request_method) {
    case 'GET':
        // Handle GET request
        if (isset($_GET['id'])) {
            // Get a single image
            $id = intval($_GET['id']);
            $stmt = $conn->prepare("SELECT * FROM images WHERE id = :id");
            $stmt->execute([':id' => $id]);
            $image = $stmt->fetch(PDO::FETCH_ASSOC);
            echo json_encode($image);
        } else {
            // Get all images
            $stmt = $conn->query("SELECT * FROM images");
            $images = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($images);
        }
        break;

    case 'POST':
        // Handle POST request
        $data = json_decode(file_get_contents("php://input"), true);
        $stmt = $conn->prepare("INSERT INTO images (filename, filepath, text) VALUES (:filename, :filepath, :text)");
        $stmt->execute([
            ':filename' => $data['filename'],
            ':filepath' => $data['filepath'],
            ':text' => $data['text']
        ]);
        echo json_encode(['message' => 'Image created successfully']);
        break;

    case 'PUT':
        // Handle PUT request
        $data = json_decode(file_get_contents("php://input"), true);
        $stmt = $conn->prepare("UPDATE images SET filename = :filename, filepath = :filepath, text = :text WHERE id = :id");
        $stmt->execute([
            ':filename' => $data['filename'],
            ':filepath' => $data['filepath'],
            ':text' => $data['text'],
            ':id' => $data['id']
        ]);
        echo json_encode(['message' => 'Image updated successfully']);
        break;

    case 'DELETE':
        // Handle DELETE request
        $id = intval($_GET['id']);
        $stmt = $conn->prepare("DELETE FROM images WHERE id = :id");
        $stmt->execute([':id' => $id]);
        echo json_encode(['message' => 'Image deleted successfully']);
        break;

    default:
        echo json_encode(['message' => 'Invalid request method']);
        break;
}
?>
