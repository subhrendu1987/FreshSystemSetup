#!/bin/bash

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

# Generate IPs in the given range
generate_ips_in_range $BASE_IP $SUBNET_MASK
