#!/usr/bin/env python3
"""
BPS Data Uploader - Main GUI Application
PyQt6-based desktop application for BPS staff.
"""

import sys
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QFileDialog, QTextEdit, QProgressBar,
    QCheckBox, QGroupBox, QMessageBox, QLineEdit, QComboBox,
    QSplitter, QTreeWidget, QTreeWidgetItem, QHeaderView
)
from PyQt6.QtCore import Qt, QThread, pyqtSignal
from PyQt6.QtGui import QFont, QIcon

from excel_reader import BPSExcelReader, ValidationResult
from github_publisher import upload_with_lock
import platform

class UploadWorker(QThread):
    """Background worker for uploading data."""
    progress = pyqtSignal(str)
    finished = pyqtSignal(bool, str)
    
    def __init__(self, file_path: str, selected_categories: List[str], 
                 github_token: str, commit_message: str):
        super().__init__()
        self.file_path = file_path
        self.selected_categories = selected_categories
        self.github_token = github_token
        self.commit_message = commit_message
        
    def run(self):
        """Execute upload process."""
        try:
            self.progress.emit("Membaca file Excel...")
            reader = BPSExcelReader(self.file_path)
            data = reader.read_all_categories()
            
            self.progress.emit("Memvalidasi data...")
            for category in self.selected_categories:
                result = reader.validate_data(category)
                if not result.is_valid:
                    self.finished.emit(False, f"Validasi gagal untuk {category}")
                    return
            
            self.progress.emit("Mengkonversi ke JSON...")
            # Filter only selected categories
            categories_data = {
                cat: data[cat] for cat in self.selected_categories 
                if cat in data
            }
            
            self.progress.emit("Mengupload ke GitHub...")
            # Get user info (PC name + username)
            user_info = f"{platform.node()} - {platform.system()}"
            
            # Upload with lock mechanism
            success, message, results = upload_with_lock(
                self.github_token,
                categories_data,
                self.commit_message,
                user_info,
                progress_callback=lambda msg: self.progress.emit(msg)
            )
            
            self.finished.emit(success, message)
            
        except Exception as e:
            self.finished.emit(False, f"Error: {str(e)}")

class BPSDataUploader(QMainWindow):
    """Main application window."""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("BPS Data Uploader v1.0")
        self.setGeometry(100, 100, 1200, 800)
        
        self.excel_file_path = ""
        self.reader = None
        self.data = {}
        self.category_checkboxes = {}
        
        self.init_ui()
        
    def init_ui(self):
        """Initialize user interface."""
        # Central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # Main layout
        main_layout = QVBoxLayout(central_widget)
        main_layout.setSpacing(20)
        main_layout.setContentsMargins(20, 20, 20, 20)
        
        # Title
        title_label = QLabel("📊 BPS DATA UPLOADER")
        title_label.setFont(QFont("Arial", 18, QFont.Weight.Bold))
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title_label.setStyleSheet("color: #2E5090; padding: 10px;")
        main_layout.addWidget(title_label)
        
        # Subtitle
        subtitle = QLabel("Upload Data Statistik ke GitHub")
        subtitle.setFont(QFont("Arial", 12))
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        subtitle.setStyleSheet("color: #666; padding-bottom: 20px;")
        main_layout.addWidget(subtitle)
        
        # Splitter for main content
        splitter = QSplitter(Qt.Orientation.Horizontal)
        main_layout.addWidget(splitter)
        
        # Left panel - Steps
        left_panel = self.create_left_panel()
        splitter.addWidget(left_panel)
        
        # Right panel - Preview
        right_panel = self.create_right_panel()
        splitter.addWidget(right_panel)
        
        # Set splitter sizes
        splitter.setSizes([700, 500])
        
        # Status bar
        self.statusBar().showMessage("Siap. Silakan pilih file Excel.")
        
    def create_left_panel(self) -> QWidget:
        """Create left panel with steps."""
        panel = QWidget()
        layout = QVBoxLayout(panel)
        layout.setSpacing(15)
        
        # Step 1: File Selection
        step1_group = QGroupBox("Langkah 1: Pilih File Excel")
        step1_layout = QVBoxLayout(step1_group)
        
        file_layout = QHBoxLayout()
        self.file_label = QLabel("Belum ada file dipilih")
        self.file_label.setStyleSheet("color: #666; font-style: italic;")
        file_layout.addWidget(self.file_label)
        
        self.browse_btn = QPushButton("📁 Browse...")
        self.browse_btn.setStyleSheet("""
            QPushButton {
                background-color: #4CAF50;
                color: white;
                padding: 8px 16px;
                border: none;
                border-radius: 4px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #45a049;
            }
        """)
        self.browse_btn.clicked.connect(self.browse_file)
        file_layout.addWidget(self.browse_btn)
        
        step1_layout.addLayout(file_layout)
        layout.addWidget(step1_group)
        
        # Step 2: Category Selection
        step2_group = QGroupBox("Langkah 2: Pilih Kategori")
        step2_layout = QVBoxLayout(step2_group)
        
        # Select/Deselect all buttons
        btn_layout = QHBoxLayout()
        select_all_btn = QPushButton("Pilih Semua")
        select_all_btn.clicked.connect(self.select_all_categories)
        btn_layout.addWidget(select_all_btn)
        
        deselect_all_btn = QPushButton("Batal Pilih Semua")
        deselect_all_btn.clicked.connect(self.deselect_all_categories)
        btn_layout.addWidget(deselect_all_btn)
        btn_layout.addStretch()
        
        step2_layout.addLayout(btn_layout)
        
        # Category checkboxes
        categories = [
            ("Pertumbuhan_Ekonomi", "📈 Pertumbuhan Ekonomi"),
            ("Inflasi", "📉 Inflasi"),
            ("Tenaga_Kerja", "👷 Tenaga Kerja"),
            ("Kemiskinan", "🏠 Kemiskinan"),
            ("Penduduk", "👥 Penduduk"),
            ("Pendidikan", "🎓 Pendidikan"),
            ("IPM", "📊 IPM"),
            ("IPG", "👫 IPG"),
            ("IDG", "⚖️ IDG"),
            ("SDGs", "🎯 SDGs")
        ]
        
        categories_layout = QVBoxLayout()
        for cat_key, cat_label in categories:
            checkbox = QCheckBox(cat_label)
            checkbox.setEnabled(False)  # Enable after file loaded
            self.category_checkboxes[cat_key] = checkbox
            categories_layout.addWidget(checkbox)
        
        step2_layout.addLayout(categories_layout)
        layout.addWidget(step2_group)
        
        # Step 3: Validation & Preview
        step3_group = QGroupBox("Langkah 3: Validasi & Preview")
        step3_layout = QVBoxLayout(step3_group)
        
        self.validate_btn = QPushButton("✅ Validasi Data")
        self.validate_btn.setEnabled(False)
        self.validate_btn.setStyleSheet("""
            QPushButton {
                background-color: #2196F3;
                color: white;
                padding: 10px;
                border: none;
                border-radius: 4px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #1976D2;
            }
            QPushButton:disabled {
                background-color: #cccccc;
            }
        """)
        self.validate_btn.clicked.connect(self.validate_data)
        step3_layout.addWidget(self.validate_btn)
        
        layout.addWidget(step3_group)
        
        # Step 4: GitHub Upload
        step4_group = QGroupBox("Langkah 4: Upload ke GitHub")
        step4_layout = QVBoxLayout(step4_group)
        
        # GitHub Token
        token_layout = QHBoxLayout()
        token_layout.addWidget(QLabel("GitHub Token:"))
        self.token_input = QLineEdit()
        self.token_input.setEchoMode(QLineEdit.EchoMode.Password)
        self.token_input.setPlaceholderText("ghp_xxxxxxxxxxxx")
        token_layout.addWidget(self.token_input)
        step4_layout.addLayout(token_layout)
        
        # Commit Message
        msg_layout = QHBoxLayout()
        msg_layout.addWidget(QLabel("Pesan Commit:"))
        self.commit_msg = QLineEdit()
        self.commit_msg.setPlaceholderText("Contoh: Update data Februari 2024")
        default_msg = f"Update data {datetime.now().strftime('%B %Y')}"
        self.commit_msg.setText(default_msg)
        msg_layout.addWidget(self.commit_msg)
        step4_layout.addLayout(msg_layout)
        
        # Upload Button
        self.upload_btn = QPushButton("🚀 Upload ke GitHub")
        self.upload_btn.setEnabled(False)
        self.upload_btn.setStyleSheet("""
            QPushButton {
                background-color: #FF9800;
                color: white;
                padding: 12px 24px;
                border: none;
                border-radius: 4px;
                font-weight: bold;
                font-size: 14px;
            }
            QPushButton:hover {
                background-color: #F57C00;
            }
            QPushButton:disabled {
                background-color: #cccccc;
            }
        """)
        self.upload_btn.clicked.connect(self.upload_to_github)
        step4_layout.addWidget(self.upload_btn)
        
        layout.addWidget(step4_group)
        
        # Progress Bar
        self.progress_bar = QProgressBar()
        self.progress_bar.setVisible(False)
        layout.addWidget(self.progress_bar)
        
        # Log Output
        self.log_output = QTextEdit()
        self.log_output.setReadOnly(True)
        self.log_output.setMaximumHeight(150)
        self.log_output.setPlaceholderText("Log aktivitas akan muncul di sini...")
        layout.addWidget(self.log_output)
        
        layout.addStretch()
        return panel
    
    def create_right_panel(self) -> QWidget:
        """Create right panel for data preview."""
        panel = QWidget()
        layout = QVBoxLayout(panel)
        
        preview_label = QLabel("📋 Preview Data")
        preview_label.setFont(QFont("Arial", 12, QFont.Weight.Bold))
        layout.addWidget(preview_label)
        
        # Tree widget for data preview
        self.preview_tree = QTreeWidget()
        self.preview_tree.setHeaderLabels(["Kategori", "Detail"])
        self.preview_tree.setColumnWidth(0, 200)
        self.preview_tree.setColumnWidth(1, 400)
        layout.addWidget(self.preview_tree)
        
        return panel
    
    def browse_file(self):
        """Open file dialog to select Excel file."""
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Pilih File Excel BPS",
            "",
            "Excel Files (*.xlsx *.xls);;All Files (*)"
        )
        
        if file_path:
            self.excel_file_path = file_path
            self.file_label.setText(Path(file_path).name)
            self.file_label.setStyleSheet("color: #4CAF50; font-weight: bold;")
            self.log(f"✅ File dipilih: {file_path}")
            
            # Enable category checkboxes
            for checkbox in self.category_checkboxes.values():
                checkbox.setEnabled(True)
                checkbox.setChecked(True)  # Select all by default
            
            self.validate_btn.setEnabled(True)
            self.upload_btn.setEnabled(True)
            
            # Load and preview data
            self.load_and_preview()
    
    def load_and_preview(self):
        """Load Excel file and preview data."""
        try:
            self.reader = BPSExcelReader(self.excel_file_path)
            self.data = self.reader.read_all_categories()
            self.update_preview_tree()
            self.statusBar().showMessage(f"✅ {len(self.data)} kategori dimuat")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Gagal membaca file:\n{str(e)}")
            self.log(f"❌ Error: {str(e)}")
    
    def update_preview_tree(self):
        """Update preview tree with loaded data."""
        self.preview_tree.clear()
        
        category_names = {
            'pertumbuhan_ekonomi': '📈 Pertumbuhan Ekonomi',
            'inflasi': '📉 Inflasi',
            'tenaga_kerja': '👷 Tenaga Kerja',
            'kemiskinan': '🏠 Kemiskinan',
            'penduduk': '👥 Penduduk',
            'pendidikan': '🎓 Pendidikan',
            'ipm': '📊 IPM',
            'ipg': '👫 IPG',
            'idg': '⚖️ IDG',
            'sdgs': '🎯 SDGs'
        }
        
        for category_key, category_data in self.data.items():
            cat_name = category_names.get(category_key, category_key)
            
            if category_key == 'sdgs':
                city_count = category_data.get('city_count', 0)
                years = category_data.get('years', [])
                detail = f"{city_count} kota, {len(years)} tahun"
            else:
                indicators = category_data.get('data', {})
                years = category_data.get('years', [])
                detail = f"{len(indicators)} indikator, {len(years)} tahun"
            
            item = QTreeWidgetItem([cat_name, detail])
            self.preview_tree.addTopLevelItem(item)
    
    def select_all_categories(self):
        """Select all category checkboxes."""
        for checkbox in self.category_checkboxes.values():
            checkbox.setChecked(True)
    
    def deselect_all_categories(self):
        """Deselect all category checkboxes."""
        for checkbox in self.category_checkboxes.values():
            checkbox.setChecked(False)
    
    def get_selected_categories(self) -> List[str]:
        """Get list of selected category keys."""
        selected = []
        for cat_key, checkbox in self.category_checkboxes.items():
            if checkbox.isChecked():
                selected.append(cat_key)
        return selected
    
    def validate_data(self):
        """Validate selected categories."""
        selected = self.get_selected_categories()
        if not selected:
            QMessageBox.warning(self, "Peringatan", "Pilih minimal satu kategori!")
            return
        
        self.log("🔍 Memvalidasi data...")
        
        all_valid = True
        for category in selected:
            result = self.reader.validate_data(category)
            if result.is_valid:
                self.log(f"✅ {category}: Valid")
                if result.warnings:
                    for warning in result.warnings[:5]:  # Show first 5 warnings
                        self.log(f"   ⚠️  {warning}")
            else:
                all_valid = False
                self.log(f"❌ {category}: Error")
                for error in result.errors:
                    self.log(f"   - {error}")
        
        if all_valid:
            QMessageBox.information(self, "Validasi", "✅ Semua data valid!")
        else:
            QMessageBox.warning(self, "Validasi", "❌ Ada error pada data. Periksa log.")
    
    def upload_to_github(self):
        """Upload data to GitHub."""
        selected = self.get_selected_categories()
        if not selected:
            QMessageBox.warning(self, "Peringatan", "Pilih minimal satu kategori!")
            return
        
        token = self.token_input.text().strip()
        if not token:
            QMessageBox.warning(self, "Peringatan", "Masukkan GitHub Token!")
            return
        
        commit_msg = self.commit_msg.text().strip()
        if not commit_msg:
            commit_msg = f"Update data {datetime.now().strftime('%Y-%m-%d')}"
        
        # Confirmation dialog
        reply = QMessageBox.question(
            self,
            "Konfirmasi Upload",
            f"Anda akan mengupload {len(selected)} kategori ke GitHub.\n\n"
            f"Kategori: {', '.join(selected)}\n"
            f"Pesan: {commit_msg}\n\n"
            f"Lanjutkan?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        
        if reply == QMessageBox.StandardButton.Yes:
            self.log("🚀 Memulai upload ke GitHub...")
            self.progress_bar.setVisible(True)
            self.progress_bar.setRange(0, 0)  # Indeterminate progress
            
            # Start worker thread
            self.worker = UploadWorker(
                self.excel_file_path,
                selected,
                token,
                commit_msg
            )
            self.worker.progress.connect(self.log)
            self.worker.finished.connect(self.upload_finished)
            self.worker.start()
    
    def upload_finished(self, success: bool, message: str):
        """Handle upload completion."""
        self.progress_bar.setVisible(False)
        
        if success:
            self.log(f"✅ {message}")
            QMessageBox.information(self, "Sukses", message)
        else:
            self.log(f"❌ {message}")
            QMessageBox.critical(self, "Error", message)
    
    def log(self, message: str):
        """Add message to log output."""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_output.append(f"[{timestamp}] {message}")
        # Scroll to bottom
        scrollbar = self.log_output.verticalScrollBar()
        scrollbar.setValue(scrollbar.maximum())

def main():
    """Main entry point."""
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    
    # Set application font
    font = QFont("Segoe UI", 10)
    app.setFont(font)
    
    # Create and show main window
    window = BPSDataUploader()
    window.show()
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
