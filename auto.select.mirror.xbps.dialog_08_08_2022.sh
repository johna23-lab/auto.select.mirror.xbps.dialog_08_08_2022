#!/bin/bash
#https://www.reddit.com/r/voidlinux/comments/6xor9j/automatically_find_fastest_update_mirror_and_use/

sudo xbps-install -Suv xbps -y
sudo xbps-install -Suv -y

if type -p bc > /dev/null; then
echo
else
    sudo xbps-install bc -y
fi

if type -p dialog > /dev/null; then
echo
else
    sudo xbps-install dialog -y
fi

#TESTING 23 MIRRORS..WAIT#
declare -a arr=(
"mirror.ps.kz"
"mirrors.bfsu.edu.cn"
"mirrors.cnnic.cn"
"mirrors.tuna.tsinghua.edu.cn"
"mirror.sjtu.edu.cn"
"void.webconverger.org"
"mirror.aarnet.edu.au/pub"
"ftp.swin.edu.au"
"void.cijber.net"
"ftp.dk.xemacs.org"
"mirrors.dotsrc.org"
"quantum-mirror.hu/mirrors/pub"
"voidlinux.mirror.garr.it/"
"mirror.fit.cvut.cz"
"ftp.debian.ru/mirrors"
"mirror.yandex.ru/mirrors"
"cdimage.debian.org/mirror"
"ftp.acc.umu.se/mirror"
"ftp.lysator.liu.se/pub"
"ftp.sunet.se/mirror"
"void.sakamoto.pl"
"mirror.clarkson.edu"
"mirror.puzzle.ch"
)

    fping=10000
    frepo=""

    for repo in "${arr[@]}"
    do
       dialog --title 'ping' --infobox "Testing site: "$repo" , with an average ping: $ping ms" 4 60
       ping=`ping -c 4 $repo | tail -1| awk '{print $4}' | cut -d '/' -f 2 | bc -l`
       if (( $(bc <<< "$ping<$fping") ))
       then
            frepo=$repo
            fping=$ping
       fi
    done


    dialog --title 'ping' --infobox "Recommended repo is: $frepo with a ping of $ping ms, \n\nInsert the password to apply the changes" 5 60

    echo repository=https://$frepo/voidlinux/current >my-remote-repo.conf
    echo repository=https://$frepo/voidlinux/current/multilib/nonfree >>my-remote-repo.conf
    echo repository=https://$frepo/voidlinux/current/multilib >>my-remote-repo.conf
    echo repository=https://$frepo/voidlinux/current/nonfree >>my-remote-repo.conf

    if [[ -f "/etc/xbps.d/my-remote-repo.conf" ]]; then
    sudo mv "/etc/xbps.d/my-remote-repo.conf" "/etc/xbps.d/my-remote-repo.conf.bak"
else 
echo
fi
    sudo cp my-remote-repo.conf /etc/xbps.d/

    if [[ -f "/usr/share/xbps.d/00-repository-main.conf" ]]; then
    sudo mv "/usr/share/xbps.d/00-repository-main.conf" "/usr/share/xbps.d/00-repository-main.conf.bak"
else 
echo
fi

  sudo cp my-remote-repo.conf /usr/share/xbps.d/00-repository-main.conf
  sudo xbps-install -S    
    input=$(xbps-query -L | awk '{$1=""; print $0}')
    dialog --title 'Mirror List' --infobox "UPDATED FILES /etc/xbps.d/my-remote-repo.conf and /usr/share/xbps.d/00-repository-main.conf with this mirror list:\n\n$input" 15 60    
