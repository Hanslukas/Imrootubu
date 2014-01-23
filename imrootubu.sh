#!/bin/bash

#Developer Gianluca La Manna (Hanslukas) 2013
#License GPL 

if [ `id -u` -eq 0 ]; then #controllo se sono root
	echo "Ok! You're root!"

#	mount -n -o remount,rw / #Rimonto il file-system in lettura scrittura
	cat /etc/passwd | grep /home | cut -d: -f1 > user #prendo gli utenti che non posseggono i permessi di root e rediriggo l'output sul file user
	num_user=`wc --lines user | egrep -o '[0-9]*'` #conto le righe per vedere il numero degli utenti

	#Questo if controlla se c'è un solo utente nel file
	if [ "$num_user" -eq "1" ]; then
		utente=`grep -e "^" user` #mi prende l'unico utente del file
		sed -i '/^root/i '"$utente"' ALL=(ALL) ALL' /etc/sudoers #aggiunge l'utente appena preso al file sudoers prima di "root"
	else #se gli utenti sono più di 1
		for ((i=1; i<= num_user; i++))
		do
			utente=`sed '1,1!d' user ` #prende la prima linea del file utenti
			sed -i '/^root/i '"$utente"' ALL=(ALL) ALL' /etc/sudoers #aggiunge l'utente appena preso al file sudoers prima di "root"
			sed  -i "/$utente/d" user > /dev/null #elimina la riga del file in questione e redirige l'output a /dev/null
		done
	fi

		echo "Ok! You got root permissions"
		rm -f user
		exit 0
else
	echo "You aren't root. Go away, miserable!" 
	exit 1
fi
