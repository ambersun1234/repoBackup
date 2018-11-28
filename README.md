# repoBackup
backup script for all your public & private repository on github
### Clone repo
```=1
git clone https://github.com/ambersun1234/repoBackup.git .
```
### Flags
+ `-u, --user`: github account's user name
+ `-t, --token`: Personal Access Token( PAT ) file location
+ `-l, --location`: backup storage device( e.g. /dev/sda2 )
+ `--help`: bring up help manual
### Note
for backup `privae` repository , please generate your `Personal Access Token(PAT)` first , store the PAT in to your local machine , and add `-t` flag in execution. <br>[creating a personal access token for the command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)
### Running
```=1
cd repoBackup
chmod +x autoBackupGithub.sh
./autoBackupGithub.sh -u USERNAME -l /PATH/TO/STORAGE
```
### License
+ This project is licensed under GNU General Public License v3.0 License - see the [LICENSE](https://github.com/ambersun1234/repoBackup/blob/master/LICENSE) file for detail
