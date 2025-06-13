# Repo-Merge
A script to easily merge multiple published Git repositories into one. Makes use of git commands and powershell automation

## What you need
1. Have Git installed and authenticated with your github account.
2. Have powershell installed Execution policy configured to be able to run `.ps1` scripts. Your can also use this command to *temporarily allow `.ps1` execution* for the current session only.
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```
> Optional steps if you have GPG signing enabled and **misconfigured** (I had to break my head over this for a while)
3. Do you have Gpg4win (or an equivalent for your OS) installed? If not install it.
4. Do you have a key-pair generated? If not generate it.\[Use Kleopatra or similar\] Provide your **public key** to github in [Github Keys](https://github.com/settings/keys)
5. Launch `git bash` and check if your private key is already present. If your setup is misconfigured (like mine was) this command will give no output
   ```bash
    gpg --list-secret-keys --keyid-format=long
   ```
6. Now import your private key using this command
   ```bash
    gpg --import "location-of-your-private-key"
   ```
   ![sekret_key_here](https://github.com/user-attachments/assets/e23102ca-4e3a-4fa4-9d42-a9738ddb7bc0)
   </br>notice the part `gpg: key ABCD123456789: secret key imported` where the *ABCD123456789* is your secret key ID
7. Tell your install of Git to use your secret key using this command
   ```gitbash
   git config --global user.signingkey ABCD123456789-your-key-id-here
   ```
8. That's it. Your git install now knows your secret key, and your commits will be identified as verified.

## Run the script
1. Make a destinatiin repository in your GitHub account where you want to merge all the repos to. Add a readme file or anything to initialize the main branch (creating this main branch is strongly recommended)
2. Note down the name of this destination repo and the source repos you want to merge into this.
3. Open the `merge_repo.ps1` script and fill in these details in the top few lines.
> **Note:** You just need the repo names, not the whole link to the repo
4. Considering you can run powershell scripts, (if not refer to [step 2](#what-you-need)) navigate to the location of the script and run it with
   ```powershell
   .\merge_repos.ps1
   ```
5. Press Enter when prompted.
