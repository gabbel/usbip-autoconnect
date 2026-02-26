
# Description

These scripts help to automate usbip on the server and client side.

Please note that this project is WIP, the server side should be functional and  complete, the client side is functional but incomplete.

A copy of these notes has been added to: https://openwrt.org/docs/guide-user/services/usb.iptunnel

## What you need.

A server, in my case it is an old Router with openwrt and a firmware that includes usbip.
A client, in my case a pop! Linux (ubuntu based distribution).


## How it works on the Server side.

Within openwrt, during boot the file '/etc/rc.local' will be checked for custom commands.
And run the hotplug script '/etc/hotplug.d/usb/90-usbip' on boot.

Otherwise during normal operation the hotplug script will run everytime when a device is beeing plugged in or beeing removed.

### Setup server side:

Use scp to copy the files to openwrt.
```shell
scp 90-usbip root@openwrt.lan:/etc/hotplug.d/usb/90-usbip
scp usbip_share_these_devices.list root@openwrt.lan:/etc/usbip_share_these_devices.list
```

Connect to the server using ssh
```shell
ssh root@openwrt.lan
```

Setup the scripts
```shell
# Download and install usbip
opkg update && opkg install usbip-server usbip-client

# Make the script executable by adding
# these lines to: rc.local before the exit 0
[ -x /etc/hotplug.d/usb/90-usbip ] || chmod 750 /etc/hotplug.d/usb/90-usbip
/etc/hotplug.d/usb/90-usbip 1


# Run these commands, in order to keep your custom configurations when running sysupgrades of openwrt.
echo "/etc/hotplug.d/usb/90-usbip" >> /etc/sysupgrade.conf
echo "/etc/usbip_share_these_devices.list" >> /etc/sysupgrade.conf
echo "/etc/rc.local" >> /etc/sysupgrade.conf
```
## How it works on the Client side.

The script '/usr/local/bin/remote_connect_usbip.sh' gets executed once a minute using cron.
I checks if the server side does share devices over usbip and attaches all of them.

### Setup client side:

Setup the script

```shell
# Copy it somwehere that makes sense.
sudo cp remote_connect_usbip.sh /usr/local/bin/remote_connect_usbip.sh
# Make Script executable
sudo chmod +x /usr/local/bin/remote_connect_usbip.sh
# Run the script once not using cron to check the dependencies.
sudo /usr/local/bin/remote_connect_usbip.sh
```

Edit crontab
```shell
sudo crontab -e
```

Add this to crontab (script will execute once per minute)
```
# connect usb devices using usbip from remote server.
* * * * * /usr/local/bin/your_script.sh
```

Wait a minute
```shell
# check if script gets executed
grep CRON /var/log/syslog
```
