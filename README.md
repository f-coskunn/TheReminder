# TheReminder

**TheReminder** is an accessibility-first Flutter application designed to help users manage and track their daily tasks and reminders efficiently. It features a clean, intuitive interface and integrates with a local SQLite database for offline-first usage.

---

## Features

- Create, edit, and delete reminders
- Track tasks by time and completion status
- Simple UI built with accessibility in mind
- Flutter frontend
- Local persistence using SQLite
- Modular architecture for easy extensibility

## Project Structure

lib/
├── models/ # Data models (e.g. Reminder)  
├── db/ # SQLite helper and initialization  
│ └── database_helper.dart  
├── screens/ # UI screens  
│ └── home_screen.dart  
├── utils/ # Utility functions (e.g. singleton)  
│ └── singleton.dart  
├── main.dart # Entry point of the app  


##  Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- An emulator or a physical device

### Installation

```bash
git clone https://github.com/f-coskunn/TheReminder.git
cd TheReminder
flutter pub get
flutter run
