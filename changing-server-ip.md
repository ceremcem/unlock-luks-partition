# Changing Server IP

If you need to change your server IP for some reason, follow the procedure: 

1. Obtain your `server_ip`, `netmask` and `gateway_ip`
2. Make the appropriate changes in `/etc/initramfs-tools/initramfs.conf` (see [the format](https://github.com/ceremcem/unlock-luks-partition#4-create-a-static-ip-or-skip-this-step-to-use-dhcp))
3. [Update `initramfs`](https://github.com/ceremcem/unlock-luks-partition#5-update-initramfs)
4. Make the appropriate changes in `/etc/network/interfaces`
5. Reboot and verify your settings. 
