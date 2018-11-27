RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'
PURPLE='\033[35m'

computeruser=$(whoami)

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
			*)
			shift
			;;
		esac
	done

token=$(cat "$token")

if [[ -z ${username} ]] || [[ -z ${token} ]] || [[ -z ${mountLocation} ]]; then
	echo -e "${RED}argument can not be empty${NC}"
	exit 0
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
else
	echo -e "\t${GREEN}connection okay${NC}"
fi

echo -e "check ssh"
checkSSH=$(ssh -T git@github.com 2>&1)
checkSSH=$(echo "$checkSSH" | grep -we "authenticated" | grep -we ""$username"")
if [[ ! -z ${checkSSH} ]]; then
	echo -e "\t${GREEN}ssh check done${NC}"
	repo=$(curl -sH "Authorization: token "$token"" https://api.github.com/user/repos | grep -wE "full_name|private|ssh_url" 2>&1)
else
	echo -e "\t${RED}ssh check failed${NC}"
	echo -e "\t${YELLOW}use https instead${NC}"
	repo=$(curl -sH "Authorization: token "$token"" https://api.github.com/user/repos | grep -wE "full_name|private|clone_url" 2>&1)
fi

echo -e "using github api querying user's repo"
privaeRepoCount=$(echo "$repo" | grep "\"private\": true" | wc -l)
repoCount=$(echo "$repo" | wc -l)
repoCount=$((repoCount/3))
echo -e "\t${username}'s total repo count = ${repoCount}"
echo -e "\t${username}'s ${YELLOW}private${NC} repo count = ${privaeRepoCount}"

echo -e "creating backup directory"
mkdir -p /media/${computeruser}/github_repo_backup 
if [[ -d /media/${computeruser}/github_repo_backup ]]; then
	echo -e "\t${GREEN}/media/${computeruser}/github_repo_backup directory create successfully${NC}"
else
	echo -e "\t${RED}/media/${computeruser}/github_repo_backup directory create failed${NC}"
fi

echo -e "backing up..."
repo=$(echo "$repo" | sed 's/\"//g')
repo=$(echo "$repo" | sed 's/\,//g')
repo=$(echo "$repo" | sed 's/\://g')
counter=0
name=""
echo "$repo" | while IFS= read -r line; do
	IFS=' '
	if [[ $(($counter % 3)) -eq 0 ]]; then
		echo -e "\t---"
	fi
	count=0
	for word in $line; do
		if [[ count -eq 0 ]]; then
			((count++))
			continue
		else
			if [[ ${word} = ${username}/* ]]; then
				name=$(echo ${word} | cut -d '/' -f2-)
			fi
			if [[ ${word} == "false" ]] || [[ ${word} == "true" ]]; then
				echo -en "\tprivate: "
				if [[ ${word} == "true" ]]; then
					echo -e "${YELLOW}${word}${NC}"
				else
					echo -e "${word}"
				fi
			else
				echo -e "\t${word}"
			fi
		fi
	done
	if [[ $(($counter % 3)) -eq 2 ]]; then
		echo -e "\tname = ${name}"
	fi
	((counter++))
done
