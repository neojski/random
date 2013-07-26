tail -n 200 /var/log/pacman.log | grep upgraded |  cut -f5-6 -d' ' | sed 's/ (/-/'
