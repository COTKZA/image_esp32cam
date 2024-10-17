#include "esp_camera.h"
#include <WiFi.h>
#include <HTTPClient.h>
#include <WebServer.h>

// Your WiFi credentials
const char* ssid = "cotkza";
const char* password = "12345678";

// Define the GPIO pin for the flash
#define FLASH_PIN 4 // Replace with your actual flash pin

// Camera configuration
camera_config_t config = {
    .pin_pwdn       = 32,  // Pin for power down (change as needed)
    .pin_reset      = -1,  // Pin for reset (not used)
    .pin_xclk       = 0,   // Pin for XCLK (change as needed)
    .pin_sccb_sda   = 26,  // Pin for SCCB SDA (change as needed)
    .pin_sccb_scl   = 27,  // Pin for SCCB SCL (change as needed)
    .pin_d7         = 35,  // Pin D7 (change as needed)
    .pin_d6         = 34,  // Pin D6 (change as needed)
    .pin_d5         = 39,  // Pin D5 (change as needed)
    .pin_d4         = 36,  // Pin D4 (change as needed)
    .pin_d3         = 21,  // Pin D3 (change as needed)
    .pin_d2         = 19,  // Pin D2 (change as needed)
    .pin_d1         = 18,  // Pin D1 (change as needed)
    .pin_d0         = 5,   // Pin D0 (change as needed)
    .pin_vsync      = 25,  // Pin VSYNC (change as needed)
    .pin_href       = 23,  // Pin HREF (change as needed)
    .pin_pclk       = 22,  // Pin PCLK (change as needed)
    .xclk_freq_hz   = 20000000, // Set the XCLK frequency
    .ledc_timer     = LEDC_TIMER_0,
    .ledc_channel   = LEDC_CHANNEL_0,
    .pixel_format   = PIXFORMAT_JPEG, // Use JPEG format
    .frame_size     = FRAMESIZE_SVGA, // Set the frame size (SVGA)
    .jpeg_quality   = 12, // JPEG quality (0-63, lower means better quality)
    .fb_count       = 2,  // Number of frame buffers
};

// Create a web server on port 80
WebServer server(80);

// Time interval for automatic capture
unsigned long lastCaptureTime = 0;
const unsigned long captureInterval = 5000; // Capture every 5 seconds

void setup() {
    Serial.begin(115200);
    pinMode(FLASH_PIN, OUTPUT); // Set the flash pin as an output
    digitalWrite(FLASH_PIN, LOW); // Ensure flash is off initially

    // Initialize camera
    if (esp_camera_init(&config) != ESP_OK) {
        Serial.println("Camera init failed");
        return;
    }

    // Connect to Wi-Fi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");

    // Start the web server
    server.on("/capture", HTTP_GET, handleCapture);
    server.begin();
    Serial.println("HTTP server started");
}

void loop() {
    server.handleClient(); // Handle incoming client requests

    // Automatic capture every 5 seconds
    unsigned long currentMillis = millis();
    if (currentMillis - lastCaptureTime >= captureInterval) {
        lastCaptureTime = currentMillis;
        handleAutoCapture(); // Call automatic capture function
    }
}

void handleCapture() {
    // Turn on flash
    digitalWrite(FLASH_PIN, HIGH);
    delay(100); // Flash duration
    digitalWrite(FLASH_PIN, LOW);

    // Take a picture manually
    camera_fb_t *fb = esp_camera_fb_get();
    if (!fb) {
        Serial.println("Camera capture failed");
        server.send(500, "text/plain", "Camera capture failed");
        return;
    }

    // Upload the image
    uploadImage(fb, false); // Manual capture
    esp_camera_fb_return(fb);

    server.send(200, "text/plain", "Image captured and uploaded successfully");
}

void handleAutoCapture() {
    // Turn on flash
    digitalWrite(FLASH_PIN, HIGH);
    delay(100); // Flash duration
    digitalWrite(FLASH_PIN, LOW);

    // Take a picture automatically
    camera_fb_t *fb = esp_camera_fb_get();
    if (!fb) {
        Serial.println("Camera capture failed");
        return;
    }

    // Upload the image
    uploadImage(fb, true); // Automatic capture
    esp_camera_fb_return(fb);
}

void uploadImage(camera_fb_t *fb, bool isAutoCapture) {
    if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        String serverPath = "http://192.168.100.165/image_esp32cam/uploads.php"; // Your server URL

        // Prepare the file name
        String imageFileName = "image_" + String(millis()) + ".jpg"; // Unique file name based on timestamp

        // Create a boundary for the multipart/form-data
        String boundary = "----WebKitFormBoundary" + String(millis());

        // Start the HTTP request
        http.begin(serverPath);
        http.addHeader("Content-Type", "multipart/form-data; boundary=" + boundary);

        // Prepare the body of the request
        String body = "--" + boundary + "\r\n";
        body += "Content-Disposition: form-data; name=\"file\"; filename=\"" + imageFileName + "\"\r\n";
        body += "Content-Type: image/jpeg\r\n\r\n";

        // Ensure you send the image data correctly
        body += String((char*)fb->buf, fb->len); // Add the image data as a string
        body += "\r\n"; // New line before closing the boundary
        
        // Include capture type in the request
        String captureType = isAutoCapture ? "auto" : "manual"; // Determine capture type
        body += "--" + boundary + "\r\n";
        body += "Content-Disposition: form-data; name=\"capture_type\"\r\n\r\n";
        body += captureType + "\r\n"; // Add capture type
        body += "--" + boundary + "--\r\n"; // End of the form data

        // Send the image data
        int httpResponseCode = http.POST(body);

        if (httpResponseCode > 0) {
            String response = http.getString();
            Serial.println(httpResponseCode);
            Serial.println(response);
        } else {
            Serial.print("Error on sending POST: ");
            Serial.println(httpResponseCode);
        }
        http.end();
    } else {
        Serial.println("WiFi not connected");
    }
}
