#!/usr/bin/env bash

echo -e "\e[1;31mThese settings are created for Intel Corporation Ethernet Controller X710 for 10GbE SFP+\e[0m\n\e[1mCheck your ring buffer sizes using 'ethtool -g <iface>' and modify script accordingly\e[0m"

echo
read -rp "Do you want to continue? (y/n): " choice

IFACE="enp5s0f0np0"
RING_SIZE=8160

case "$choice" in
    [Yy])
        echo "Proceeding..."        
        # Sets ethtool to max ring buffers and enables frame pause
        sudo ethtool -G $IFACE rx $RING_SIZE tx $RING_SIZE
        sudo ethtool -A $IFACE tx on rx on
        sudo ethtool -K $IFACE gro off gso off tso off
        echo -e "\e[1;32mSet ring sizes to $RING_SIZE\e[0m"
        ;;
    [Nn])
        echo -e  "\e[1;31mExiting.\e[0m"
        exit 0
        ;;
    *)
        echo -e "\e[1;31mInvalid input. Please enter y or n.\e[0m"
        exit 1
        ;;
esac