# WifiRipper
Script Name: WifiRipper - Automated Wi-Fi Deauthentication Script

## Description:

"WifiRipper" is a powerful shell script designed to automate the process of scanning nearby Wi-Fi networks and performing deauthentication attacks on multiple networks. This script is intended for educational and testing purposes only and should be used responsibly and with proper authorization of network admins.

## Features:

Interface Selection: The script allows the user to choose a wireless network interface from the available options on their system. This ensures that the user is targeting the correct wireless interface for network scanning and deauthentication.

Network Scanning: WifiRipper initiates network scanning using the popular tool airodump-ng, which captures information about nearby Wi-Fi networks. The script displays a list of available networks along with their details, including BSSID, SSID, channel, encryption type, and signal strength.

MAC Address Selection: After scanning, the user is prompted to enter the number of MAC addresses they want to target for deauthentication. The user can then provide the MAC addresses of the specific Wi-Fi networks they wish to deauthenticate.

Deauthentication Attack: WifiRipper launches multiple terminal windows, each executing the aireplay-ng command to perform deauthentication attacks on the selected MAC addresses. 
Deauthentication attacks are simulated disassociation packets sent to the target network's clients, causing temporary network disruption.

Repeat Option: Once the deauthentication attacks are completed, the user is given the option to repeat the process. This allows for continuous testing and monitoring of Wi-Fi network security.

Dependency Check: Wifiripper checks if the required tools (airodump-ng and aireplay-ng) are installed on the system. If not, it offers to install them using the package manager.

## Disclaimer:

WifiRipper is intended for ethical and educational purposes only. Unauthorized use of this script to disrupt Wi-Fi networks without proper authorization is illegal and unethical. Users are encouraged to obtain the necessary permissions and follow ethical guidelines before using this script. The script authors and maintainers are not responsible for any misuse or harm caused by its usage.
