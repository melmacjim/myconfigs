## PLACE RANDOM USEFUL BASH FUNCTIONS HERE

## THE FOLLOWING VARIABLES ARE SOURCED FROM PRIVATE FILES : `$GITHUB_REPO_LIST` and `$GITHUB_REPO_DIR`


## NETWORKING START ##

ipinfo () {
  if ! ping -c1 -q ipinfo.io > /dev/null ; then
    echo "Can't ping ipnfo.io, check your internet connection."
  else
    if ! jq -h > /dev/null ; then
      echo "jq is not installed :("
    elif ! curl -h > /dev/null ; then
      echo "curl is not installed :("
    else
      local TEMPFILE="/tmp/ipinfo"
      curl -s ipinfo.io > $TEMPFILE
      if grep "error" "$TEMPFILE" > /dev/null ; then
        echo -e "\nSomething is worng!\n\nData from ipinfo.io:\n$(cat $TEMPFILE)\n"
      else
        local CITY="$(jq -r .city $TEMPFILE)"
        local REGION="$(jq -r .region $TEMPFILE)"
        local COUNTRY="$(jq -r .country $TEMPFILE)"
        local PUB_IP="$(jq -r .ip $TEMPFILE)"
        local PRI_IP="$(var=$(ip -br a s | grep -E "192.168.|172.|10." | awk '{print $3}') ; echo -n $var)"
        printf "\n$(date)\n\n"
        printf "IP Address Location -> ${CITY}, ${REGION}, ${COUNTRY}\n\n"
        printf "Public  IP Address -> ${PUB_IP}\n"
        printf "Private IP Address -> ${PRI_IP}\n\n"
        printf "Local Name Server -> $(echo $(grep nameserver /etc/resolv.conf | awk '{print $2}'))\n\n"
        if [ ! -z $1 ] && [ "$1" = "-a" ] ; then
          if uname -a | grep -i darwin ; then
            netstat -nr -f inet ; echo ""
          else
            netstat -nr ; echo ""
          fi
          if netstat -aW | grep -q "ESTABLISHED" ; then
            echo "Current established connections:"
            netstat -aW | grep -E "Address|ESTABLISHED"
            echo ""
          fi
        fi
      fi
      rm $TEMPFILE
    fi
  fi
}

sslcheck () {
  if nmap -h > /dev/null ; then
    local website="$1"
    if [ -z "$website" ] ; then
      printf "\nUsage: sslcheck google.com\n\n"
    else
      nmap --script=ssl-cert.nse -Pn -p443 $website | grep -v Nmap
    fi
  else
    printf "\nNmap isn't installed.\n\n"
  fi
}

sslcheck-full () {
  echo $1
  echo \
    | openssl s_client -showcerts -servername $1 -connect $1:443 2>/dev/null \
    | openssl x509 -inform pem -noout -text
}

pingport () {
  if sudo hping3 -h > /dev/null ; then
    if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
      echo -e "Usage:\n\tpingport 80 example.com\n"
    elif [ -z "$1" ] ; then
      echo "No port number was given."
    elif [ -z "$2" ] ; then
      echo "No host was given."
    else
      sudo hping3 -S -p $2 $1
    fi
  else
    printf "\nhping3 isn't installed.\n\n"
  fi
}

## NETWORKING END ##


## OTHER START ##

bk () {
  if [ -z $1 ] ; then
    echo "Usage: bk filename"
  else
    cp -a ${1} ${1}_$(date +'%Y%m%d')
  fi
}

update-git-local-repos () {
  local ORG_DIR="$(pwd)"
  for repo in $GITHUB_REPO_LIST ; do
    echo "========================================================="
    echo "Checking on $GITHUB_REPO_DIR/$repo"
    cd $GITHUB_REPO_DIR/$repo
    if git status | grep -q "Changes not staged for commit:\|Untracked files:" ; then
      git status
      git diff
    else
      git pull origin master
    fi
    echo ""
  done
  cd $ORG_DIR
}

listdrives () {
  if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    echo "list-drives - will list all block devices connected"
  else
    for char in $(echo {a..z} {0..9}) ; do
        if [ -e /dev/sd$char ] ; then
          DRIVE_PATH="/dev/sd$char"
          printf "\n$DRIVE_PATH:\n$(sudo smartctl -i $DRIVE_PATH | grep -i "model\|capacity")\n"
        fi
        if [ -e /dev/nvme$char ] ; then
          DRIVE_PATH="/dev/nvme$char"
          printf "\n$DRIVE_PATH:\n$(sudo smartctl -i $DRIVE_PATH | grep -i "model\|capacity")\n"
        fi
    done
  fi
  echo ""
}

## OTHER END ##
