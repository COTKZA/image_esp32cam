import cv2
import os
import mysql.connector
from datetime import datetime
import pytz
import time
from colorama import init, Fore

# เริ่มต้น Colorama
init(autoreset=True)

# ฟังก์ชันสำหรับตรวจสอบว่าภาพมีคนหรือไม่
def contains_person(image_path):
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)
    return len(faces) > 0

# ฟังก์ชันเพื่อให้ได้วันที่และเวลาที่ปรับเป็นเวลาไทย
def get_current_date_time_thai():
    tz = pytz.timezone('Asia/Bangkok')
    now = datetime.now(tz)
    return now.strftime('%Y-%m-%d'), now.strftime('%H:%M:%S')

# ฟังก์ชันสำหรับการตรวจสอบและอัปโหลดภาพ
def process_images():
    # เชื่อมต่อกับ MySQL
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='esp23cam_image'
    )
    cursor = connection.cursor()

    # กำหนดโฟลเดอร์ที่ต้องการดึงภาพ
    folder_path = 'C:/xampp/htdocs/image_esp32cam/uploads/'  # เปลี่ยนตำแหน่งนี้เป็นตำแหน่งโฟลเดอร์ของคุณ

    # อ่านรายชื่อไฟล์ในโฟลเดอร์
    files = os.listdir(folder_path)

    # ตรวจสอบและอัปโหลดข้อมูล
    for filename in files:
        image_path = os.path.join(folder_path, filename)
        
        # ตรวจสอบว่าไฟล์เป็นภาพหรือไม่
        if not filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            print(f"Skipping non-image file: {filename}")
            continue
        
        # แสดงเส้นทางของภาพเพื่อตรวจสอบ
        print(f"Checking image path: {image_path}")
        
        # โหลดภาพ
        image = cv2.imread(image_path)
        if image is None:
            print(f"Cannot load image: {image_path}")
            continue

        # ตรวจสอบว่าชื่อไฟล์นี้มีอยู่ในตาราง ai_check แล้วหรือยัง
        cursor.execute("SELECT COUNT(*) FROM ai_check WHERE file_name = %s", (filename,))
        result = cursor.fetchone()

        # ถ้าพบชื่อไฟล์ซ้ำ ไม่ต้องบันทึกใหม่
        if result[0] > 0:
            print(f"File already exists in database: {filename}")
            continue

        # ตรวจสอบภาพด้วย AI ว่าเป็นคนหรือไม่
        if contains_person(image_path):
            created_date, created_time = get_current_date_time_thai()
            # แก้ไข SQL เพื่อรวม filepath
            sql = "INSERT INTO ai_check (file_name, filepath, text, created_date, created_time) VALUES (%s, %s, %s, %s, %s)"
            val = (filename, image_path, "ตรวจสอบโดย AI", created_date, created_time)  # รวม image_path
            cursor.execute(sql, val)
            connection.commit()
            print(Fore.GREEN + f"Uploaded (AI-checked person): {filename} - Date: {created_date}, Time: {created_time}")
        else:
            print(Fore.RED + f"No person detected in: {filename}")

    # ปิดการเชื่อมต่อ
    cursor.close()
    connection.close()

# วนลูปตรวจสอบไฟล์ในโฟลเดอร์อย่างต่อเนื่อง
try:
    while True:
        process_images()  # ตรวจสอบและอัปโหลดภาพ
        # time.sleep(10)  # รอ 10 วินาที ก่อนตรวจสอบโฟลเดอร์ใหม่อีกครั้ง
except KeyboardInterrupt:
    print("โปรแกรมหยุดการทำงาน")
