# repoBackup
backup script for all your public & private repository on github
### Clone repo
```=1
git clone https://github.com/ambersun1234/repoBackup.git
```
### Flags
+ `-u, --user`: github account's user name
+ `-t, --token`: Personal Access Token( PAT ) file location
+ `-l, --location`: backup storage location( e.g. /mnt/mystorage/backup )
+ `--help`: bring up help manual
### Notes
+ make sure that `curl` is installed in your machine
    + install curl by `sudo apt install curl -y`
+ for backup `private` repository , please generate your `Personal Access Token(PAT)` first , store the PAT into your local machine , and add `-t` flag in execution. <br>[creating a personal access token for the command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
### Running
```=1
cd repoBackup
chmod +x autoBackupGitHub.sh
./autoBackupGitHub.sh -u YOUR_GITHUB_USER_NAME -l /PATH/TO/STORAGE -t ./YOUR_PERSONAL_ACCESS_TOKEN_FILE
```
### Auto Running
+ configure parameter
    + open `run.sh` file , in the final line , change **YOUR_GITHUB_USER_NAME** and **/PATH/TO/STORAGE** and **YOUR_PERSONAL_ACCESS_TOKEN_FILE**( if needed )
+ setup crontab to auto run backup script
```=1
crontab -e
0 0 * * 1 bash ./repoBackup/run.sh > /home/USER/.cron.log 2>&1
```
+ save and exit , no need to restart crontab
+ this will run for every monday at 00:00
+ the log file will be written to `/home/USER/.cron.log` , check it out using `cat ~/.cron.log`
### License
This project is licensed under GNU General Public License v3.0 License - see the [LICENSE](https://github.com/ambersun1234/repoBackup/blob/master/LICENSE) file for detail
