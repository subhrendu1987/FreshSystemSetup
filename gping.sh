#!/bin/bash

# Function to convert an IP address to binary
ip_to_binary() {
    local a b c d
    IFS=. read -r a b c d <<< "$1"
    printf "%08d.%08d.%08d.%08d\n" \
        "$(bc <<< "obase=2; $a")" \
        "$(bc <<< "obase=2; $b")" \
        "$(bc <<< "obase=2; $c")" \
        "$(bc <<< "obase=2; $d")"
}

binary_to_ip() {
    local a b c d
    IFS=. read -r a b c d <<< "$1"
    echo "$((2#$a)).$((2#$b)).$((2#$c)).$((2#$d))"
}

IP_and(){
    local a1 b1 c1 d1 a2 b2 c2 d2
    IFS=. read -r a1 b1 c1 d1 <<< "$1"
    IFS=. read -r a2 b2 c2 d2 <<< "$2"
    a=$(binary_and $a1 $a2)
    b=$(binary_and $b1 $b2)
    c=$(binary_and $c1 $c2)
    d=$(binary_and $d1 $d2)
    echo $a.$b.$c.$d
}

binary_and() {
    local bin1=$1
    local bin2=$2

    # Convert binary strings to integers
    local int1=$((2#$bin1))
    local int2=$((2#$bin2))

    # Perform binary AND operation
    local and_result=$((int1 & int2))

    # Convert the result back to binary
    echo "obase=2; $and_result" | bc
}


# Function to convert dotted decimal to integer
ip_to_int() {
    local a b c d
    IFS=. read -r a b c d <<< "$1"
    echo "$(( (a << 24) + (b << 16) + (c << 8) + d ))"
}

# Function to convert integer to dotted decimal
int_to_ip() {
    local ip=$1
    echo "$(( (ip >> 24) & 255 )).$(( (ip >> 16) & 255 )).$(( (ip >> 8) & 255 )).$(( ip & 255 ))"
}

# Calculate the network address given an IP and subnet mask
get_network_address() {
    local ip_int=$(ip_to_int $1)
    local mask_int=$(ip_to_int $2)
    echo "$((ip_int & mask_int))"
}

# Calculate the broadcast address given an IP and subnet mask
get_broadcast_address() {
    local net_addr_int=$(get_network_address $1 $2)
    local mask_int=$(ip_to_int $2)
    local wildcard_int=$(( ~mask_int & 0xFFFFFFFF ))
    echo "$(( net_addr_int | wildcard_int ))"
}

# Main logic to generate IP range
generate_ips_in_range() {
    local base_ip=$1
    local subnet_mask=$2

    local network_address=$(get_network_address $base_ip $subnet_mask)
    local broadcast_address=$(get_broadcast_address $base_ip $subnet_mask)

    echo "Network Address:"$network_address
    echo "Broadcast Address:"$broadcast_address

    local network_int=$(ip_to_int $network_address)
    local broadcast_int=$(ip_to_int $broadcast_address)

    echo "Generating IPs between $network_address and $broadcast_address"

    ip_range=() # Initialize array to store the IPs
    for (( ip_int=network_int+1; ip_int<broadcast_int; ip_int++ )); do
        ip=$(int_to_ip $ip_int)
        ip_range+=($ip)
        #echo "+ "$ip
    done

    echo "Total IPs generated: ${#ip_range[@]}"
    echo "${ip_range[@]}"
}

# Example usage
BASE_IP=$1
SUBNET_MASK=$2

IP_BIN=$(ip_to_binary $BASE_IP)
MASK_BIN=$(ip_to_binary $SUBNET_MASK)
NET_BIN=$(IP_and $IP_BIN $MASK_BIN)
NET_IP=$(binary_to_ip $NET_BIN)
# Generate IPs in the given range
#generate_ips_in_range $BASE_IP $SUBNET_MASK

echo $IP_BIN
echo $MASK_BIN
echo $NET_BIN
echo $NET_IP
