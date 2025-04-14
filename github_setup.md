# GitHub Repository Setup Instructions

Follow these steps to push your Weather Data Service project to GitHub:

## 1. Initialize a Git Repository

```bash
# Navigate to your project directory if you're not already there
cd "c:\Omer Work\microsoft_hw\weather-data-azure"

# Initialize a new Git repository
git init
```

## 2. Add All Files to the Repository

```bash
# Add all files to the staging area
git add .
```

## 3. Commit the Changes

```bash
# Commit the changes with a descriptive message
git commit -m "Initial commit: Weather Data Service project"
```

## 4. Create a GitHub Repository

1. Go to [GitHub](https://github.com/) and sign in to your account
2. Click on the "+" icon in the top-right corner and select "New repository"
3. Enter a repository name (e.g., "weather-data-azure")
4. Add a description (optional): "A service that collects, stores, and analyzes weather data using Azure services"
5. Choose whether the repository should be public or private
6. Do NOT initialize the repository with a README, .gitignore, or license
7. Click "Create repository"

## 5. Link Your Local Repository to GitHub

```bash
# Add the GitHub repository as a remote
git remote add origin https://github.com/YOUR-USERNAME/weather-data-azure.git

# Push your code to GitHub
git push -u origin main
```

Note: If your default branch is named "master" instead of "main", use:

```bash
git push -u origin master
```

## 6. Verify the Repository

1. Refresh your GitHub repository page
2. You should see all your files and directories listed
3. The README.md file should be displayed below the file list

## 7. Additional Git Commands for Future Updates

```bash
# Check the status of your repository
git status

# Pull the latest changes from GitHub
git pull

# Add specific files
git add filename

# Commit changes
git commit -m "Description of changes"

# Push changes to GitHub
git push
```
