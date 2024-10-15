<?php
// api_ai_check.php
header('Access-Control-Allow-Origin: *'); // Allow any origin
header('Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE'); // Allow specific methods
header('Access-Control-Allow-Headers: Content-Type'); // Allow specific headers
header('Content-Type: application/json');

// Include the database configuration file
include 'config_api_ai.php'; // Ensure this file is in the same directory

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    // Send a response for preflight request
    http_response_code(204);
    exit;
}

// Get the request method
$method = $_SERVER['REQUEST_METHOD'];

if ($method == 'GET') {
    // Prepare the SQL query for fetching images
    $sql = "SELECT * FROM ai_check";
    $result = $conn->query($sql);

    // Initialize an array to hold the images
    $images = [];

    // Fetch data from the database
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $images[] = $row;
        }
    }

    // Close the database connection
    $conn->close();

    // Return the results as a JSON response
    echo json_encode($images);
} elseif ($method == 'DELETE') {
    // Get the ID from the request body
    parse_str(file_get_contents("php://input"), $data);
    $id = isset($data['id']) ? intval($data['id']) : 0;

    if ($id > 0) {
        // Prepare the SQL query for deleting an image
        $sql = "DELETE FROM ai_check WHERE id = ?";

        // Prepare the statement
        if ($stmt = $conn->prepare($sql)) {
            $stmt->bind_param('i', $id);

            // Execute the statement
            if ($stmt->execute()) {
                if ($stmt->affected_rows > 0) {
                    echo json_encode(['message' => 'Image deleted successfully']);
                } else {
                    echo json_encode(['message' => 'No image found with that ID']);
                }
            } else {
                error_log("Execution failed: " . $stmt->error); // Log any SQL errors
                echo json_encode(['error' => 'Failed to delete image']);
            }

            // Close the statement
            $stmt->close();
        } else {
            // Error preparing the statement
            echo json_encode(['error' => 'Failed to prepare statement']);
        }
    } else {
        // Invalid ID
        echo json_encode(['error' => 'Invalid ID']);
    }

    // Close the database connection
    $conn->close();
} else {
    // Method not allowed
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
