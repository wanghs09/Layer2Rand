#!/bin/bash
# bash layer2rand.sh

echo "randomly generate two private keys!"
sk1="$(openssl rand -hex 50)"
sk2="$(openssl rand -hex 50)"
echo "user1-sk1: $sk1"
printf "user2-sk2: $sk2\n\n"

# the rand seed
msg="$(openssl rand -hex 32)" 
printf "seed: $msg\n"
pout1="$(./pcl -p $sk1 $msg)"
IFS=';' read -ra data <<< "$pout1"

i=1
# 4 rounds
while [ $i -le 4 ] 
do
	let i++
	printf "user1's message:\n"
	printf "msg: ${data[3]}\npk: ${data[0]} \nproof: ${data[1]}\n"  

	vout2="$(./pcl -v ${data[0]} ${data[1]} ${data[2]})"
	echo "verfication result: $vout2"
	msg=${data[3]}
	pout2="$(./pcl -p $sk2 $msg)"
	IFS=';' read -ra data <<< "$pout2"

	printf "user2's turn:\n"
	printf "msg: ${data[3]}\npk: ${data[0]} \nproof: ${data[1]}\n"  

	vout2="$(./pcl -v ${data[0]} ${data[1]} ${data[2]})"
	echo "verfication result: $vout2"
	msg=${data[3]}
	pout2="$(./pcl -p $sk1 $msg)"
	IFS=';' read -ra data <<< "$pout2"
done
