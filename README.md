<p align="center">
  <h1 align="center">⚡ Razer System Master</h1>
</p>

<p align="center">
  <b>A lightweight, high-performance Windows utility GUI designed to maintain system health, manage updates, and flush network configurations, styled with a sleek Razer aesthetic.</b>
</p>

<br>

![ System Master UI](screenshot.png)

---

## 📌 Overview
`Razer System Master` acts as an all-in-one control panel for basic Windows maintenance. Written natively with a Windows Forms GUI, it safely automates repetitive tasks like clearing temporary system caches, flushing DNS, and managing outdated applications via `winget`.

---

## ✨ Features & Capabilities

- **🧹 Temp File Cleaner**: Scans and securely purges temporary files from user and system directories (`%TEMP%`, `C:\Windows\Temp`), instantly recovering valuable disk space.
- **🌐 DNS Refresh**: Executes an underlying administrative `ipconfig /flushdns` process to instantly clear local network resolver caches and fix connectivity issues.
- **🔄 Winget Integration**:
  - *Check Updates*: Queries the Windows Package Manager to count and display out-of-date software packages.
  - *Update All*: Automates silent, background updates for all installed applications.
- **🌍 Multi-Language Support**: Dynamically toggle between English (En) and Russian (Ru) directly from the UI dropdown menu.
- **📊 Real-time Progress Tracking**: Built-in progress bar and status logs keep you informed of ongoing tasks.

---

## 🚀 Usage Guide

### Requirements
- **Windows 10 or 11**
- **Windows Package Manager (`winget`)** *(Comes pre-installed on modern Windows builds via the 'App Installer' package from the Microsoft Store).*

### Execution
1. Head over to the **[Releases](../../releases)** tab on the right side of this page.
2. Download the latest compiled `SystemMaster.exe` binary.
3. **Right-click** the `.exe` file -> select **Run as Administrator** *(Administrative privileges are strictly required for DNS flushing and clearing system-wide temp folders).*

---

## 🤝 Contributing
Contributions, suggestions, and bug reports are highly welcome! Feel free to open an issue or submit a pull request.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
