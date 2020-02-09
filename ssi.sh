#!/bin/bash

#Boxes array can be modified an needed, this would dinamycally change the amount of servers created.
IP=$2
boxes=( boxOne boxTwo boxThree )
dck_checker=`docker ps | grep box > /dev/null ; echo $?`

#Creates LinuxVMs based on the size of the boxes array
create () {
if [[ $dck_checker -eq 0 ]]
then
        echo "You already have your LinuxVMs running!"
	exit 1
else
	for i in "${boxes[@]}"
	do
		docker run -d --name $i centos tail -f /dev/null >> /dev/null
		echo "LinuxVM created with IP: "; docker exec $i hostname -I
	done
	exit 0
fi
}

#This query should be executed against the LinuxVMs to return all VM details as a file in the current working directory.
query () {
if [ -z $IP ]
then
	echo "Usage example: $0 query 172.17.0.1"
	exit 1
fi

if [[ ! $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
	echo "That's not an IP!"
	exit 1
fi

if [[ $dck_checker -ne 0 ]]
then
	echo "Create a LinuxVM before running a query. Run '$0 usage' for more details."
	exit 1
else
	queryIP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}{{ .Name }}' $(docker ps -q) | grep $IP | cut -d/ -f2`
	rm ./$queryIP.log 2> /dev/null
	a=`docker exec $queryIP hostname -I`
       		printf "> Server IP: $a \n \n \n" >> ./$queryIP.log
	b=`docker exec $queryIP ps aux`
       		printf "> Currently running processes: \n \n" >> ./$queryIP.log; printf '%s\n' "$b" >> ./$queryIP.log
	c=`docker exec $queryIP ps aux --sort=-pcpu | head -n 4`
       		printf "\n> Top 3 CPU usage processes: \n \n" >> ./$queryIP.log; printf '%s\n' "$c" >> ./$queryIP.log
	d=`docker exec $queryIP ps aux --sort -rss | head -n 4`
       		printf "\n> Top 3 Memory usage processes: \n \n" >> ./$queryIP.log; printf '%s\n' "$d" >> ./$queryIP.log
	e=`docker exec $queryIP top -b -n 1`
		printf "\n> LinuxVM CPU capacity as human redable: \n \n" >> ./$queryIP.log; printf '%s\n' "$e" >> ./$queryIP.log
	f=`docker exec $queryIP cat /proc/stat`
		printf "\n> LinuxVM CPU capacity as machine redable: \n \n" >> ./$queryIP.log; printf '%s\n' "$f" >> ./$queryIP.log
	g=`docker exec $queryIP free -m`
		printf "\n> LinuxVM Memory capacity as human redable: \n \n" >> ./$queryIP.log; printf '%s\n' "$g" >> ./$queryIP.log
	h=`docker exec $queryIP cat /proc/meminfo`
		printf "\n> LinuxVM Memory capacity as machine redable: \n \n" >> ./$queryIP.log; printf '%s\n' "$h" >> ./$queryIP.log
fi

if [ -f ./$queryIP.log ]
then
	echo "Successful query $queryIP.log file has been created!"
	exit 0
else
	echo "Sorry, something went wrong with your query... please try again"
	exit 1
fi
}

#If you can't recall the name or IP of your server use the listing function.
list () {
if [[ $dck_checker -ne 0 ]]
then
	echo "Create a LinuxVM before listing. Execute '$0 usage' for more details."
	exit 1
else
	echo "Available LinuxVMs are:"
	docker inspect --format '{{ .NetworkSettings.IPAddress }}{{ .Name }}' $(docker ps -q)
	exit 0
fi
}

#This is meant to delete all the VMs once you are done with your testing.
clean () {
if [[ $dck_checker -ne 0 ]]
then
        echo "Create a LinuxVM before running a clean-up. Exexute '$0 usage' for more details."
	exit 1
else
	for i in "${boxes[@]}"
	do
		docker kill $i > /dev/null
		docker rm $i > /dev/null
	done
	echo "Clean-up completed, LinuxVMs removed."
	exit 0
fi
}

#Help for users.
usage () {
	echo "Usage $0 {create|query|list|clean}"
}

#Case used to define what action the user would like to take.
case "$1" in
	create)
		create
	;;
	
	query)
		query
	;;

	list)
		list
	;;

	clean)
		clean
	;;

	*)
		usage
	;;
esac
