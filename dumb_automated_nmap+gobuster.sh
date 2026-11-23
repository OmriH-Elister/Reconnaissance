#!/bin/bash
msfdb init &
sleep 10
if [ -f domain_names ]; then
	for i in $(cat domain_names); do
		(nmap -p- -T4 $i -vvv -oA basicScan_$i | grep "Discovered open port" | grep -oP '\d+(?=/tcp)' | paste -sd,) > open_ports.md && \
		grep -q '[0-9]' open_ports.md && \
		nmap -A -p$(cat open_ports.md) --script=VULN,DISCOVERY,EXPLOIT -oA advancedScan_$i && \
		gobuster dir -u http://$i -r -b 401,402,403,404,405 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-words.txt -o "${i}_go_bust.txt" ;
		wait && msfconsole -r dbimporter.rc
	done;
else
	read -p "What is the Target's IP address? " Target
	(nmap -p- -T4 $Target -vvv -oA basicScan_$Target | grep "Discovered open port" | grep -oP '\d+(?=/tcp)' | paste -sd,) > open_ports.md
	grep -q '[0-9]' open_ports.md && \
		nmap -A -p$(cat open_ports.md) --script=VULN,DISCOVERY,EXPLOIT -oA advancedScan_$Target
	gobuster dir -u http://$Target -r -b 401,402,403,404,405 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-words.txt -o "${Target}_go_bust.txt"
	wait && msfconsole -r dbimporter.rc
fi
