# Quiz Manager

แอป Flutter สำหรับจัดการชุดข้อสอบแบบปรนัยบน Android ผู้ใช้สามารถดู เพิ่ม และลบคำถามได้ โดยแต่ละคำถามมีตัวเลือก 4 รายการ ข้อมูลถูกเก็บถาวรด้วย SQLite ภายในเครื่อง

## Features

- แสดงสถานะกำลังโหลด ข้อผิดพลาด และรายการว่าง
- แสดงคำถามพร้อมตัวเลือก 4 รายการ
- เพิ่มคำถามด้วย Form validation และตัดช่องว่างก่อนบันทึก
- ยืนยันก่อนลบ และเก็บข้อมูลบนหน้าจอไว้หากลบไม่สำเร็จ
- แสดงเลขข้อจากตำแหน่งในรายการ จึงเรียงใหม่อัตโนมัติหลังลบ
- UI ภาษาไทย ใช้ Material 3 และรองรับหน้าจอแคบด้วย layout ที่เลื่อนได้

## Architecture และ Data Flow

โปรเจกต์แบ่งหน้าที่เป็นชั้นเพื่อลดการผูกติดกันและทดสอบได้ง่าย:

```text
Widgets / Pages
      │ อ่าน state และเรียก action
      ▼
QuestionProvider (ChangeNotifier)
      │ เรียกใช้งานข้อมูล
      ▼
QuestionRepository
      │ query / insert / delete
      ▼
AppDatabase (SQLite)
```

- `Question` เป็น immutable domain/data model
- `QuestionProvider` จัดการ loading, error และข้อมูลที่ UI ใช้
- `QuestionRepository` แปลงระหว่างแถวในฐานข้อมูลกับ `Question`
- `AppDatabase` เปิดฐานข้อมูลแบบ lazy และรับ `DatabaseFactory`/path จากภายนอกเพื่อทดสอบได้

Widget tests ใช้ `FakeQuestionRepository` จึงไม่เปิด SQLite ส่วน repository tests ใช้ `sqflite_common_ffi` กับ in-memory database

## Database Schema

ฐานข้อมูลชื่อ `quiz_manager.db` เวอร์ชัน 1 มีตาราง `questions`:

```sql
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_text TEXT NOT NULL,
  choice_1 TEXT NOT NULL,
  choice_2 TEXT NOT NULL,
  choice_3 TEXT NOT NULL,
  choice_4 TEXT NOT NULL
);
```

ไม่มี `correctChoice` เพราะขอบเขตของโจทย์กำหนดเฉพาะการจัดเก็บคำถามและตัวเลือก

## Running Number กับ Primary Key

`id` เป็น Primary Key ที่ SQLite สร้างเพื่อระบุข้อมูลอย่างถาวร จึงไม่ถูกแก้หรือเรียงใหม่เมื่อลบข้อมูล ส่วนเลขข้อที่แสดงต่อผู้ใช้เป็น Running Number ซึ่งคำนวณจาก `index + 1` หลังเรียงข้อมูลด้วย `id ASC` วิธีนี้ทำให้เลขข้อบนหน้าจอต่อเนื่องโดยไม่ทำลายตัวระบุข้อมูลในฐานข้อมูล

## Project Structure

```text
lib/
├── app.dart
├── core/theme/app_theme.dart
├── data/
│   ├── database/app_database.dart
│   └── repositories/question_repository.dart
├── models/question.dart
├── pages/
│   ├── question_form_page.dart
│   └── question_list_page.dart
├── providers/question_provider.dart
└── main.dart

test/
├── data/repositories/question_repository_test.dart
├── models/question_test.dart
├── providers/question_provider_test.dart
└── widget_test.dart
```

## Technology Stack

- Flutter และ Dart
- Material 3
- Provider / ChangeNotifier
- SQLite ด้วย `sqflite`
- `path` สำหรับสร้างตำแหน่งไฟล์ฐานข้อมูล
- `sqflite_common_ffi` สำหรับ in-memory repository tests บนเครื่องพัฒนา

## ติดตั้ง

ต้องมี Flutter stable, Android SDK และยอมรับ Android licenses แล้ว จากนั้นรัน:

```bash
git clone <repository-url>
cd flutter_quiz_manager
flutter pub get
flutter doctor -v
```

## รันแอป

เปิด Android emulator หรือเชื่อมต่อ Android device แล้วรัน:

```bash
flutter devices
flutter run
```

## ทดสอบและตรวจคุณภาพ

```bash
dart format .
flutter analyze
flutter test
```

## Build APK

```bash
flutter build apk --release
```

ไฟล์ที่ได้อยู่ที่ `build/app/outputs/flutter-apk/app-release.apk`
