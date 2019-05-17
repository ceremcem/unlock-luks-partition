# Changing Server IP

If you need to change your server IP for some reason, follow the procedure: 

1. Obtain your `$server_ip`, `$netmask` and `$gateway_ip` (and get or calculate your `$network`)
2. Make the appropriate changes in `/etc/initramfs-tools/initramfs.conf` (see [the format](https://github.com/ceremcem/unlock-luks-partition#4-create-a-static-ip-or-skip-this-step-to-use-dhcp))
3. [Update `initramfs`](https://github.com/ceremcem/unlock-luks-partition#5-update-initramfs)
4. Make the appropriate changes in `/etc/network/interfaces`
5. Reboot and verify your settings. 

# Verification 

1. Directly connect your laptop to your server via ethernet. 

2. Make your laptop a gateway with [`make-gateway`](https://github.com/aktos-io/aktos-nm/blob/master/make-gateway): 

    ```
    sudo ./make-gateway --wan wlp2s0 --lan eth0 --ip $gateway_ip
    ```

3. Create a route to your server: 

    ```
    sudo ip route add $network/$netmask dev eth0
    ```

4. Add your `server_ip` to `/etc/hosts`: 

    ```
    server_ip     example.com
    ```
    
5. Try to connect over ssh without using an IP. 
