#!/bin/bash

# Variables
REMOTE_SERVER=""

# Check dependencies

# Check if usbip is available, and exit with an error message if not found
if ! command -v usbip &>/dev/null; then
  echo "Error: usbip could not be found. Please install it first." >&2
  secho "sudo apt install linux-tools-generic" >&2
  exit 1
fi

# Load vhci-hcd kernel module if it's not already loaded or present in /etc/modules
if ! (lsmod | grep -q "vhci_hcd" || grep -q "vhci-hcd" /etc/modules); then
  sudo modprobe vhci-hcd
  echo "vhci-hcd loaded."
else
  if ! grep -q "vhci-hcd" /etc/modules; then
    # Add vhci-hcd to /etc/modules for permanent loading on boot
    echo "Adding vhci-hcd to /etc/modules..."
    sudo sed -i '$ i\\n\tvhci-hcd' /etc/modules
    echo "vhci-hcd added to /etc/modules."
  fi
fi

# Get lines that contain IDs.
regex1="^\s*(\d{1,3}-[^:]+).+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\)"
# Capture the groups that contain the Bus ID, Vendor ID and Device ID
regex2="([0-9]{1,3}-[^:]+).+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})"

# Command output
result=$(usbip list -r $REMOTE_SERVER | grep -oP "$regex1")
# Use grep with PCRE to extract matching groups
echo "$result" | while read -r line; do
   echo "This line: $line"
   # Extract and store matching groups
    if [[ "$line" =~ $regex2 ]]; then
        echo "Group 1: Bus ID: ${BASH_REMATCH[1]}"
        echo "Group 2: Ven ID: ${BASH_REMATCH[2]}"
        echo "Group 3: Dev ID: ${BASH_REMATCH[3]}"
	echo "Attach ${BASH_REMATCH[1]} from $REMOTE_SERVER"
        usbip attach -r "$REMOTE_SERVER" -b "${BASH_REMATCH[1]}"
    fi
done

