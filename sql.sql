CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE images ( 
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    filepath VARCHAR(255) NOT NULL,
    text TEXT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    time TIME NOT NULL DEFAULT CURRENT_TIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ai_check (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- คอลัมน์ ID ที่เป็นเอกลักษณ์และเพิ่มอัตโนมัติ
    file_name VARCHAR(255) NOT NULL,    -- คอลัมน์เก็บชื่อไฟล์
    filepath VARCHAR(255) NOT NULL,
    text TEXT NOT NULL,          -- คอลัมน์ระบุว่าสิ่งที่ตรวจพบคือคนหรือไม่
    created_date DATE NOT NULL,          -- คอลัมน์เก็บวันที่
    created_time TIME NOT NULL            -- คอลัมน์เก็บเวลา
);
