import cv2
import os
import mysql.connector
from datetime import datetime
import pytz
import time
import torch
from colorama import init, Fore

# เริ่มต้น Colorama
init(autoreset=True)

# โหลดโมเดล YOLOv5 ครั้งเดียว
model = torch.hub.load('ultralytics/yolov5', 'yolov5s')  # 'yolov5s' คือโมเดลขนาดเล็ก

# ฟังก์ชันสำหรับตรวจสอบว่าภาพมีคนหรือไม่
def contains_person(image_path):
    results = model(image_path)  # ตรวจสอบภาพ

    # ตรวจสอบว่ามีคนในผลลัพธ์
    for detection in results.xyxy[0]:  # results.xyxy[0] คือผลลัพธ์ของภาพแรก
        if detection[5] == 0:  # ตรวจสอบ class_id สำหรับคน
            return True
    return False

# ฟังก์ชันเพื่อให้ได้วันที่และเวลาที่ปรับเป็นเวลาไทย
def get_current_date_time_thai():
    tz = pytz.timezone('Asia/Bangkok')
    now = datetime.now(tz)
    return now.strftime('%Y-%m-%d'), now.strftime('%H:%M:%S')

# ฟังก์ชันสำหรับการตรวจสอบและอัปโหลดภาพ
def process_images():
    # เชื่อมต่อกับ MySQL
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password='',
            database='esp23cam_image'
        )
        cursor = connection.cursor()
    except mysql.connector.Error as err:
        print(Fore.RED + f"Error connecting to database: {err}")
        return

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

        # ตรวจสอบภาพด้วย AI ว่ามีคนหรือไม่
        if contains_person(image_path):
            created_date, created_time = get_current_date_time_thai()
            sql = "INSERT INTO ai_check (file_name, filepath, text, created_date, created_time) VALUES (%s, %s, %s, %s, %s)"
            val = (filename, image_path, "ตรวจสอบโดย AI", created_date, created_time)
            try:
                cursor.execute(sql, val)
                connection.commit()
                print(Fore.GREEN + f"Uploaded (AI-checked person): {filename} - Date: {created_date}, Time: {created_time}")
            except mysql.connector.Error as err:
                print(Fore.RED + f"Error inserting data: {err}")
        else:
            print(Fore.RED + f"No person detected in: {filename}")

    # ปิดการเชื่อมต่อ
    cursor.close()
    connection.close()

# วนลูปตรวจสอบไฟล์ในโฟลเดอร์อย่างต่อเนื่อง
try:
    while True:
        process_images()  # ตรวจสอบและอัปโหลดภาพ
        #time.sleep(10)  # รอ 10 วินาที ก่อนตรวจสอบโฟลเดอร์ใหม่อีกครั้ง
except KeyboardInterrupt:
    print("โปรแกรมหยุดการทำงาน")
