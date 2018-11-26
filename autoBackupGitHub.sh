RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'
PURPLE='\033[35m'

checkMount=$(cat /proc/mounts | grep /dev/sda2)
echo -e "check hard disk status"
if [[ ! -z ${checkMount} ]]; then
	echo -e "\t${GREEN}/dev/sda2 mounted${NC}"
else
	echo -e "\t${RED}/dev/sda2 unmount , mounting...${NC}"
	sudo mount -t ntfs /dev/sda2 /media/ambersun
	checkMount=$(cat /proc/mounts | grep /dev/sda2)
	if [[ ! -z ${checkMount} ]]; then
		echo -e "\t${GREEN}/dev/sda2 mounted${NC}"
	else
		echo -e "\t${RED}error occurred!!${NC}"
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
checkSSH=$(echo "$checkSSH" | grep authenticated 2>&1)
if [[ ! -z checkSSH ]]; then
	echo -e "\t${GREEN}ssh check done${NC}"
else
	echo -e "\t${RED}ssh check failed${NC}"
fi
