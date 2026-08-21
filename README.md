# 📌 PowerShell Local Kanban

A complete, lightweight, and interactive Kanban server running 100% from a single PowerShell script. No external dependencies required (Zero Node.js, Zero Python, Zero SQL).

## 🚀 Features

- **Single-File Architecture:** Both the HTTP Server and the modern Frontend are embedded in a single `.ps1` file.
- **Modern UI & Dark Mode:** Built with HTML5 and TailwindCSS. It includes a toggleable Dark Mode that automatically saves your preference.
- **Drag and Drop:** Intuitive drag-and-drop interface to move cards across columns (Backlog, In Progress, Done).
- **Smart Time Tracking:** Automatically calculates the total time spent based on the start and end times you input.
- **Real-Time Search & Filters:** Instantly filter your board by typing a card title, project name, or selecting a specific date.
- **Toast Notifications:** Clean, non-intrusive pop-up alerts for creating, updating, moving, or deleting cards.
- **Smart Sorting:** The board automatically sorts cards chronologically, keeping your most recent tasks right at the top of each column.
- **Local JSON Database:** Data is automatically persisted to a `kanban_data.json` file in the same directory as the script.

## 🛠️ How to Use

1. Download or clone this repository to your local machine.
2. Open your terminal (PowerShell) in the folder where the file is located and run:
   ```powershell
   .\KanbanServer.ps1
