#!bin/bash

GREEN='\033[32m'
RED='\033[31m'
NC='\033[0m'

while :
	do
		status=$(ping -c 1 8.8.8.8 2>&1 | grep 64\ bytes\ from)
		if [ "$status" == "" ]; then
			echo -en "\r${RED}> waiting internet connection"
			time=0
			while [ $time -lt 3 ]
				do
					sleep 0.2
					echo -en "."
					((time++))
				done
			echo -en "${NC}"
		else
			echo -en "\r${GREEN}> internet connection established\n${NC}"
			break
		fi
		sleep 1
		echo -en "\r>                                          "
	done

bash ./autoBackupGitHub.sh -u YOUR_GITHUB_USER_NAME -t ./YOUR_PERSONAL_ACCESS_TOKEN_FILE -l /PAHT/TO/STORAGE
