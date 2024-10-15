CREATE TABLE images ( 
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    filepath VARCHAR(255) NOT NULL,
    text TEXT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    time TIME NOT NULL DEFAULT CURRENT_TIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
