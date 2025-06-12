# Enter your github username here. Your local git install must be authenticated with this account
# Eg. $githubUsername = "Cosmic-Infinity"
$githubUsername = "YOUR_USERNAME_HERE"
# Your merge destination repository. Create one and initialise it with the main branch atleast by adding, say, a text file.
# Eg. $destRepo = "Competitive-Programming-History"
$destRepo = "DESTINATION_REPO_NAME"
# The names of the repositories you want to merge. Add all of them separated by commas.
# Eg. $sourceRepos = @( "repo-name-1", "repo-name-2")
)
$sourceRepos = @(
    "REPOSITORY-1",
    "REPOSITORY-1"
)

Write-Host "This script will merge the following repositories into ${destRepo}:"
$sourceRepos | ForEach-Object { Write-Host "- $_" }
Write-Host ""
Write-Host "Please ensure you've created an empty repository called '${destRepo}' on GitHub under your account (${githubUsername})."
Read-Host "Press Enter to continue..."

# Clone the new destination repository
git clone "https://github.com/$githubUsername/$destRepo.git"
if ($LASTEXITCODE -ne 0) { Write-Host "Failed to clone $destRepo. Exiting."; exit 1 }
Set-Location $destRepo

# Ensure the main branch exists (initial commit if empty)
if (-not (git rev-parse --verify main 2>$null)) {
    Write-Host "Repo is empty, creating initial commit..."
    New-Item -ItemType File -Name "README.md" | Out-Null
    git add README.md
    git commit -m "Initial commit"
    git branch -M main
    git push origin main
}
git checkout main

foreach ($srcRepo in $sourceRepos) {
    $srcRemote = "remote_$srcRepo"
    $srcUrl = "https://github.com/$githubUsername/$srcRepo.git"
    $subfolder = $srcRepo

    Write-Host "`nMerging $srcRepo into subfolder $subfolder..."

    # Remove remote if it exists already
    if (git remote get-url $srcRemote 2>$null) {
        git remote remove $srcRemote
    }

    git remote add $srcRemote $srcUrl
    git fetch $srcRemote

    # Detect default branch (main or master)
    $defaultBranch = git remote show $srcRemote | Select-String "HEAD branch" | ForEach-Object {
        $_.ToString().Split(":")[-1].Trim()
    }
    if (-not $defaultBranch) {
        $defaultBranch = "main"
    }

    # Create a merge branch from main
    git checkout -b "merge-$srcRepo" main

    # Merge source repo (allow unrelated histories)
    git merge --allow-unrelated-histories "$srcRemote/$defaultBranch" -m "Merge $srcRepo into $subfolder"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Merge conflict or error detected! Resolve conflicts, then run:"
        Write-Host "git add ."
        Write-Host "git commit"
        Write-Host "git checkout main"
        Write-Host "git merge merge-$srcRepo"
        Write-Host "Then re-run the script to continue."
        exit 1
    }

    # Create subfolder if not exists
    if (-not (Test-Path $subfolder)) {
        New-Item -ItemType Directory -Path $subfolder | Out-Null
    }

    # Exclude .git, .gitignore, and all repo subfolders from being moved
    $exclude = @(".git", ".gitignore") + $sourceRepos

    # Move only the files/folders not in $exclude into $subfolder
    Get-ChildItem -Force | Where-Object {
        $exclude -notcontains $_.Name
    } | ForEach-Object {
        try {
            Move-Item $_.Name $subfolder -Force -ErrorAction Stop
        } catch {
            Write-Host "Could not move $($_.Name) - $($_.Exception.Message)"
        }
    }

    git add .
    git commit -m "Move $srcRepo files into $subfolder/" 2>$null

    # Switch back to main branch and merge
    git checkout main
    git merge "merge-$srcRepo" -m "Integrate $srcRepo history and files"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Merge conflict or error detected while integrating! Resolve conflicts, then continue."
        exit 1
    }

    # Cleanup
    git branch -D "merge-$srcRepo"
    git remote remove $srcRemote
}

Write-Host "`nAll repositories have been merged. Pushing to remote..."
git push origin main

Write-Host "`nDone! Each repo's history and files are now in subfolders of $destRepo."