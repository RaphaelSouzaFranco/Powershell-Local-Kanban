# 📌 PowerShell Local Kanban

A complete, lightweight, and functional Kanban server running 100% from a single PowerShell script. No external dependencies required (Zero Node.js, Zero Python, Zero SQL).

## 🚀 Features

- **Single-File App:** Both the HTTP Server and Frontend are embedded in the same `.ps1` file.
- **Modern Interface:** Built with HTML5 and TailwindCSS for a clean, responsive design.
- **Drag and Drop:** Easily drag cards across columns (Backlog, In Progress, Done).
- **Time Tracking:** Automatically calculates the time spent based on the start and end times you input.
- **Local Database:** Data is automatically persisted to a `kanban_data.json` file in the same directory as the script.
- **Zero Installation:** Relies entirely on the native .NET/PowerShell `System.Net.HttpListener`.

## 🛠️ How to Use

1. Download or clone this repository to your local machine.
2. Open your terminal in the folder where the file is located and run:
   ```powershell
   .\KanbanServer.ps1
