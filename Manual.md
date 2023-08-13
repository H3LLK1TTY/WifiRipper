# Manual
## Running the Tool:
   Open a terminal on your Linux system.
        Navigate to the directory where you have saved the shell script using the cd command.
        Make sure the script has executable permissions using the command: chmod +x wifiripper.sh
        Run the script using: ./wifiripper.sh

## Installation Check:
  The script will check if aircrack-ng is installed. If not, it will attempt to install it.
        You might need to enter your password during the installation process.

## Wi-Fi Interface Selection:
  The tool will display a list of available wireless interfaces on your system.
        Select the number corresponding to the desired wireless interface you want to use for scanning and deauthentication.

## Monitor Mode Activation:
 The script will switch the selected interface to monitor mode (if not already) using airmon-ng.
        If the interface name changes to wlan0mon (or similar), the script will automatically detect and use it.

## Scanning for Wi-Fi Networks:
  The tool will use airodump-ng to scan for nearby Wi-Fi networks.
        This will display a list of Wi-Fi networks, their BSSIDs (MAC addresses), and other information.

## Deauthentication Attack:
   You will be prompted to enter the number of MAC addresses you want to deauthenticate.
        For each MAC address, enter the MAC address of the client/device you want to deauthenticate from the target network.

## Custom Deauthentication Packets:    You will be asked if you want to set a custom number of deauthentication packets or use the default (0).
  If you choose custom, enter the desired number of deauthentication packets to send.

## Deauthentication Process:
   The tool will start the deauthentication process using aireplay-ng for each provided MAC address.
        A new terminal window will open for each deauthentication attempt.
        Once deauthentication is complete, you can press Enter to close the terminal.

## Repeating the Process:
   After deauthenticating the selected MAC addresses, you will be asked if you want to deauthenticate again.
        If you choose "y," the tool will repeat the process for another round of deauthentication.

## Exiting the Tool:
 To exit the tool, choose "n" when prompted to repeat the deauthentication process.
    The script will stop monitor mode using airmon-ng and exit.
