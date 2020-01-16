#!bin/bash

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'
PURPLE='\033[35m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
UNDERLINE='\033[4m'

computeruser=$(whoami)

_help() {
	cols=$(tput cols)
	title="autoBackupGithub help manual"
	printf "${BOLD}%*s${NORMAL}" $(((${#title}+$cols)/2)) "$title"

	echo -e "\n${BOLD}NAME${NORMAL}"
	echo -e "\tautoBackupGithub - backup all your public and private repository on github"

	echo -e "\n${BOLD}SYNOPSIS${NORMAL}"
	echo -e "\t./autoBackup -u [${UNDERLINE}username${NC}]... -l [${UNDERLINE}location${NC}]..."

	echo -e "\n${BOLD}DESCRIPTION${NORMAL}"
	echo -e "\tBackup all your github repository via github api."
	echo -e "\tIf you wish to backup your private repository ,"
	echo -e "\tyou need to go to github to generate Personal Access Token( PAT )."

	echo -e "\n\t${BOLD}-u, --user${NORMAL}"
	echo -e "\t\tgithub account's user name"

	echo -e "\n\t${BOLD}-t, --token( optional )${NORMAL}"
	echo -e "\t\tPersonal Access Token( PAT ) file location"

	echo -e "\n\t${BOLD}-l, --location${NORMAL}"
	echo -e "\t\tbackup storage device( e.g. /dev/sda2 )"

	echo -e "\n\t${BOLD}--help${NORMAL}"
	echo -e "\t\tbring up help manual"
}

while [[ $# -gt 0 ]]
	do
		key="$1"
		case $key in
			-u|--user)
			username="$2"
			shift
			shift
			;;
			-t|--token)
			token="$2"
			shift
			shift
			;;
			-l|--location)
			mountLocation="$2"
			shift
			shift
			;;
			--help)
			_help
			exit 0
			shift
			;;
			*)
			shift
			;;
		esac
	done

if [[ -z ${token} ]]; then
	token="-1"
else
	token=$(cat "$token" 2>&1)
fi

if [[ -z ${username} ]] || [[ -z ${token} ]] || [[ -z ${mountLocation} ]]; then
	echo -e "${RED}argument can not be empty${NC} , use ./autoGithubBackup --help to bring up help manual"
	exit 0
fi

time=$(date +"%Y/%m/%d-%H:%M:%S")
echo -e "\nexecute start time: ${time}\n"

checkCurl=$(apt-cache policy curl | grep Installed | cut -c14-)
echo -e "check curl"
if [[ ! -z ${checkCurl} ]]; then
	echo -e "\t${GREEN}curl checked${NC}"
else
	echo -e "\t${RED}curl not installed , please install it and re-run the program${NC}"
fi

checkMount=$(cat /proc/mounts | grep "$mountLocation")
echo -e "check hard disk status"
if [[ ! -z ${checkMount} ]]; then
	echo -e "\t${GREEN}${mountLocation} mounted${NC}"
else
	echo -e "\t${RED}${mountLocation} unmount , mounting...${NC}"
	check=$(sudo mount -t ntfs ${mountLocation} /media/${computeruser} 2>&1)
	checkMount=$(cat /proc/mounts | grep "$mountLocation")
	if [[ ! -z ${checkMount} ]]; then
		echo -e "\t${GREEN}${mountLocation} mounted${NC}"
	else
		echo -e "\t${RED}error occurred!!${NC}"
		exit 0
	fi
fi

checkInternet=$(ping -c 1 8.8.8.8 | grep 64\ bytes\ from)
echo -e "check internet connection"
if [ "$checkInternet" == "" ]; then
	echo -e "\t${RED}connection error${NC}"
	exit 1
else
	echo -e "\t${GREEN}connection okay${NC}"
fi

echo -e "check ssh"
checkSSH=$(ssh -T git@github.com 2>&1)
checkSSH=$(echo "$checkSSH" | grep -we "authenticated" | grep -we ""$username"")
if [[ ! -z ${checkSSH} ]]; then
	echo -e "\t${GREEN}ssh check done${NC}"
else
	echo -e "\t${RED}ssh check failed${NC}"
	echo -e "\t${YELLOW}use https instead${NC}"
fi

echo -e "check token"
if [[ ${token} == "-1" ]]; then
	echo -e "\t${YELLOW}token not specified , using username ${username} to get repository${NC}"
	repo=$(curl -s https://api.github.com/users/"$username"/repos 2>&1)
	temp=$(echo "$repo" | grep "\"message\"\: \"Not Found\"")
	if [[ ! -z ${temp} ]]; then
		echo -e "\t${RED}username not found , please check again${NC}"
		exit 0
	else
		echo -e "\t${GREEN}username checked${NC}"
		repo=$(echo "$repo" | grep -wE "\"full_name\"|\"private\"|\"clone_url\"")
	fi
else
	echo -e "\t${GREEN}token specified${NC}"
	repo=$(curl -sH "Authorization: token "$token"" https://api.github.com/user/repos 2>&1)
	temp=$(echo "$repo" | grep "\"message\"\: \"Bad credentials\"")
	if [[ ! -z ${temp} ]]; then
		echo -e "\t${RED}token not found , please check again${NC}"
		exit 0
	else
		echo -e "\t${GREEN}token checked${NC}"
		repo=$(echo "$repo" | grep -wE "\"full_name\"|\"private\"|\"ssh_url\"")
	fi
fi

echo -e "using github api querying user's repo"
privaeRepoCount=$(echo "$repo" | grep "\"private\": true" | wc -l)
repoCount=$(echo "$repo" | wc -l)
repoCount=$((repoCount/3))
echo -e "\t${username}'s total repo count = ${repoCount}"
echo -e "\t${username}'s ${YELLOW}private${NC} repo count = ${privaeRepoCount}"

echo -e "creating backup directory"
mkdir -p /media/${computeruser}/github_repo_backup
mkdir -p /media/${computeruser}/temp_dir

if [[ -d /media/${computeruser}/github_repo_backup ]]; then
	echo -e "\t${GREEN}/media/${computeruser}/github_repo_backup directory create successfully${NC}"
	temp=$(rm -rf /media/${computeruser}/github_repo_backup/* && rm -rf /media/${computeruser}/github_repo_backup/.* 2>&1)
else
	echo -e "\t${RED}/media/${computeruser}/github_repo_backup directory create failed${NC}"
	exit 0
fi
if [[ -d /media/${computeruser}/temp_dir ]]; then
	echo -e "\t${GREEN}/media/${computeruser}/temp_dir directory create successfully${NC}"
	temp=$(rm -rf /media/${computeruser}/github_repo_backup/* && rm -rf /media/${computeruser}/github_repo_backup/.* 2>&1)
else
	echo -e "\t${RED}/media/${computeruser}/temp_dir directory create failed${NC}"
	exit 0
fi

echo -e "backing up..."
# setting case-insensetive
shopt -s nocasematch

repo=$(echo "$repo" | sed 's/\"//g')
repo=$(echo "$repo" | sed 's/\,//g')
name=""
echo "$repo" | while IFS= read -r line; do
	IFS=' '
	count=0
	flag=0
	line=$(echo "$line" | sed 's/\://')

	for word in $line; do
		# check if full name
		if [[ ${word} = "full_name" ]]; then
			flag=1
		fi
		# the first word of each line does not need to output , just need to save it in to variable "name"
		if [[ count -eq 0 ]]; then
			((count++))
			continue
		else
			if [[ ${word} = ${username}/* ]] || [[ flag -eq 1 ]]; then
				# get repo name
				name=$(echo ${word} | cut -d '/' -f2-)
				flag=0
				continue
			fi
			if [[ ${word} == "false" ]] || [[ ${word} == "true" ]]; then
				echo -en "\tprivate: "
				if [[ ${word} == "true" ]]; then
					printf "${YELLOW}${word}${NC}"
				else
					printf "${word}"
				fi
			else
				# output url
				echo -e "\t${word}"
				# temp=$(git clone ${word} /media/${computeruser}/temp_dir/ 2>&1)
				temp=$(git clone ${word} /media/${computeruser}/temp_dir/)

				if [[ -d /media/"${computeruser}"/github_repo_backup/"${name}" ]]; then
					mkdir -p /media/${computeruser}/github_repo_backup/${name}
					shopt -s dotglob
					mv /media/${computeruser}/temp_dir/* /media/${computeruser}/github_repo_backup/${name}/
					shopt -u dotglob
					temp=$(rm -rf /media/${computeruser}/temp_dir/* /media/${computeruser}/temp_dir/.* 2>&1)
					
					echo -e "\t${GREEN}${name} clone done${NC}"
				else
					echo -e "\t${RED}${name} clone failed${NC}"
				fi
			fi
		fi
	done
done
rm -rf /media/${computeruser}/temp_dir
echo -e "done"

# set back case sensetive
shopt -u nocasematch
