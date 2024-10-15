<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if a file is being uploaded
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Check if the 'file' key exists in the $_FILES array
    if (isset($_FILES['file']) && $_FILES['file']['error'] == UPLOAD_ERR_OK) {
        // Set target directory
        $target_dir = "./uploads/";
        
        // Ensure the target directory exists
        if (!is_dir($target_dir)) {
            mkdir($target_dir, 0777, true); // Create the directory if it doesn't exist
        }

        $target_file = $target_dir . basename($_FILES['file']['name']);
        
        // Move the uploaded file to the target directory
        if (move_uploaded_file($_FILES['file']['tmp_name'], $target_file)) {
            // Database connection
            $conn = new mysqli("127.0.0.1", "root", "", "esp23cam_image");
            
            // Check the database connection
            if ($conn->connect_error) {
                die("Connection failed: " . $conn->connect_error);
            }

            // Determine the message based on the capture type
            $message = "กดถ่ายเอง"; // Default message
            
            // Check for the 'capture_type' parameter in the POST request
            if (isset($_POST['capture_type']) && $_POST['capture_type'] == 'auto') {
                $message = "ถ่ายออโต้"; // Change to auto-capture message
            }

            // Prepare the SQL statement
            $stmt = $conn->prepare("INSERT INTO images (filename, filepath, text) VALUES (?, ?, ?)");
            
            // Use the relative path for the database
            $relative_path = "./uploads/" . basename($_FILES['file']['name']); // Store relative path

            // Bind parameters
            $stmt->bind_param("sss", basename($_FILES['file']['name']), $relative_path, $message);

            // Execute the SQL statement
            if ($stmt->execute() === TRUE) {
                echo "File uploaded and database updated successfully.";
            } else {
                echo "Error: " . $stmt->error; // Output SQL error
                error_log("SQL error: " . $stmt->error); // Log error to PHP error log
            }

            // Close statement and connection
            $stmt->close();
            $conn->close();
        } else {
            echo "Sorry, there was an error uploading your file.";
        }
    } else {
        echo "No file uploaded or there was an upload error.";
    }
} else {
    echo "Invalid request method.";
}
?>
