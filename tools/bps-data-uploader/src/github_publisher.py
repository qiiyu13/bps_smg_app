#!/usr/bin/env python3
"""
GitHub Publisher Module
Handles uploading data to GitHub with lock mechanism.
"""

import base64
import json
import requests
from datetime import datetime
from typing import Dict, Optional, List
from github import Github
from github.Repository import Repository

class GitHubPublisher:
    """Publisher for uploading BPS data to GitHub."""
    
    # GitHub repository details
    REPO_OWNER = "ZekeHyperByte"
    REPO_NAME = "bps-semarang-data"
    LOCK_FILE = ".upload_lock"
    
    def __init__(self, token: str):
        self.token = token
        self.github = Github(token)
        self.repo = self.github.get_repo(f"{self.REPO_OWNER}/{self.REPO_NAME}")
        
    def check_lock(self) -> tuple[bool, Optional[str]]:
        """Check if someone else is uploading.
        
        Returns:
            (is_locked, lock_info) - is_locked=True if locked, lock_info has details
        """
        try:
            # Try to get lock file
            contents = self.repo.get_contents(self.LOCK_FILE)
            lock_data = json.loads(base64.b64decode(contents.content).decode('utf-8'))
            
            # Check if lock is stale (older than 10 minutes)
            lock_time = datetime.fromisoformat(lock_data['timestamp'])
            elapsed = (datetime.now() - lock_time).total_seconds()
            
            if elapsed > 600:  # 10 minutes
                # Lock is stale, remove it
                self.repo.delete_file(
                    self.LOCK_FILE,
                    "Remove stale upload lock",
                    contents.sha
                )
                return False, None
            
            return True, lock_data
            
        except Exception as e:
            # Lock file doesn't exist
            return False, None
    
    def create_lock(self, user_info: str) -> bool:
        """Create upload lock.
        
        Args:
            user_info: Information about who's uploading (e.g., username or PC name)
        
        Returns:
            True if lock created successfully
        """
        try:
            lock_data = {
                "user": user_info,
                "timestamp": datetime.now().isoformat(),
                "message": "Upload in progress"
            }
            
            content = json.dumps(lock_data, indent=2)
            
            try:
                # Check if file exists
                existing = self.repo.get_contents(self.LOCK_FILE)
                # Update existing
                self.repo.update_file(
                    self.LOCK_FILE,
                    "Create upload lock",
                    content,
                    existing.sha
                )
            except:
                # Create new
                self.repo.create_file(
                    self.LOCK_FILE,
                    "Create upload lock",
                    content
                )
            
            return True
            
        except Exception as e:
            print(f"Error creating lock: {e}")
            return False
    
    def remove_lock(self) -> bool:
        """Remove upload lock."""
        try:
            contents = self.repo.get_contents(self.LOCK_FILE)
            self.repo.delete_file(
                self.LOCK_FILE,
                "Remove upload lock",
                contents.sha
            )
            return True
        except:
            return False
    
    def upload_category(self, category: str, data: Dict, commit_message: str) -> tuple[bool, str]:
        """Upload a single category to GitHub.
        
        Args:
            category: Category name (e.g., 'pertumbuhan_ekonomi')
            data: JSON-serializable data dictionary
            commit_message: Git commit message
        
        Returns:
            (success, message)
        """
        try:
            file_path = f"data/{category}.json"
            json_content = json.dumps(data, indent=2, ensure_ascii=False)
            
            try:
                # Check if file exists
                existing = self.repo.get_contents(file_path)
                # Update existing file
                self.repo.update_file(
                    file_path,
                    f"{commit_message} - {category}",
                    json_content,
                    existing.sha
                )
            except:
                # Create new file
                self.repo.create_file(
                    file_path,
                    f"{commit_message} - {category}",
                    json_content
                )
            
            return True, f"✅ {category}: Uploaded successfully"
            
        except Exception as e:
            return False, f"❌ {category}: Error - {str(e)}"
    
    def upload_multiple(self, categories_data: Dict[str, Dict], 
                       commit_message: str,
                       progress_callback=None) -> Dict[str, str]:
        """Upload multiple categories.
        
        Args:
            categories_data: Dictionary of {category: data}
            commit_message: Git commit message
            progress_callback: Function to call with progress updates
        
        Returns:
            Dictionary of {category: status_message}
        """
        results = {}
        total = len(categories_data)
        
        for idx, (category, data) in enumerate(categories_data.items(), 1):
            if progress_callback:
                progress_callback(f"Uploading {category} ({idx}/{total})...")
            
            success, message = self.upload_category(category, data, commit_message)
            results[category] = message
            
        return results
    
    def update_version_file(self, version: str) -> bool:
        """Update version.txt file."""
        try:
            try:
                existing = self.repo.get_contents("version.txt")
                self.repo.update_file(
                    "version.txt",
                    f"Update version to {version}",
                    version,
                    existing.sha
                )
            except:
                self.repo.create_file(
                    "version.txt",
                    f"Create version file {version}",
                    version
                )
            return True
        except Exception as e:
            print(f"Error updating version: {e}")
            return False
    
    def get_last_commit_info(self) -> Optional[Dict]:
        """Get information about last commit."""
        try:
            commits = self.repo.get_commits()
            if commits.totalCount > 0:
                last_commit = commits[0]
                return {
                    'sha': last_commit.sha[:7],
                    'message': last_commit.commit.message,
                    'author': last_commit.commit.author.name,
                    'date': last_commit.commit.author.date.isoformat()
                }
        except:
            pass
        return None

def upload_with_lock(github_token: str, 
                    categories_data: Dict[str, Dict],
                    commit_message: str,
                    user_info: str,
                    progress_callback=None) -> tuple[bool, str, Dict]:
    """Upload data with lock mechanism.
    
    Args:
        github_token: GitHub personal access token
        categories_data: Dictionary of category data
        commit_message: Git commit message
        user_info: Information about user uploading
        progress_callback: Function for progress updates
    
    Returns:
        (success, message, results)
    """
    publisher = GitHubPublisher(github_token)
    
    # Check for existing lock
    is_locked, lock_info = publisher.check_lock()
    if is_locked:
        return False, f"⚠️ Upload sedang berlangsung oleh {lock_info.get('user', 'unknown')}. Silakan tunggu.", {}
    
    # Create lock
    if not publisher.create_lock(user_info):
        return False, "❌ Gagal membuat upload lock. Coba lagi.", {}
    
    try:
        if progress_callback:
            progress_callback("🔒 Lock dibuat, memulai upload...")
        
        # Upload all categories
        results = publisher.upload_multiple(
            categories_data, 
            commit_message,
            progress_callback
        )
        
        # Update version
        version = datetime.now().strftime("%Y.%m.%d-%H%M%S")
        publisher.update_version_file(version)
        
        # Check results
        success_count = sum(1 for msg in results.values() if "✅" in msg)
        total_count = len(results)
        
        if success_count == total_count:
            message = f"✅ Berhasil mengupload {success_count}/{total_count} kategori!"
        elif success_count > 0:
            message = f"⚠️ {success_count}/{total_count} kategori berhasil. Beberapa gagal."
        else:
            message = f"❌ Semua upload gagal."
        
        return True, message, results
        
    finally:
        # Always remove lock
        publisher.remove_lock()
        if progress_callback:
            progress_callback("🔒 Lock dihapus.")

if __name__ == "__main__":
    # Test
    import os
    
    token = os.getenv("GITHUB_TOKEN", "your_token_here")
    
    if token == "your_token_here":
        print("Please set GITHUB_TOKEN environment variable")
    else:
        publisher = GitHubPublisher(token)
        
        # Test lock
        locked, info = publisher.check_lock()
        print(f"Lock status: {locked}")
        if locked:
            print(f"Locked by: {info}")
        else:
            # Test upload
            test_data = {
                "version": "1.0.0",
                "test": "data",
                "timestamp": datetime.now().isoformat()
            }
            success, msg = publisher.upload_category("test", test_data, "Test upload")
            print(f"Upload result: {success} - {msg}")
