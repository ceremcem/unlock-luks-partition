


# Unlock LUKS Partition with SSH

Below instructions are for booting your SERVER by connecting and unlocking the encrypted partition via your CLIENT over SSH:

**WARNING**: Typing your crypto key over network might be secure (due to the secure nature of the SSH connection) **as long as** you are completely certain that the initramfs has not been subjugated so that there is no MITM attack taking place while you are typing your disk passphrase.

### 1. Install mandatory packages (on SERVER)

```
apt-get install dropbear initramfs-tools busybox
```

Check that Dropbear has disabled itself in `/etc/default/dropbear`
```
NO_START=1
```


### 2. Append your desired public keys into the SERVER's authorized_keys file

Just copy and paste your public key(s) into `/etc/dropbear-initramfs/authorized_keys` on SERVER


### 3. Create the unlock script 

Create following script as `/etc/initramfs-tools/hooks/crypt_unlock.sh`

```bash
#!/bin/sh

PREREQ="dropbear"

prereqs() {
  echo "$PREREQ"
}

case "$1" in
  prereqs)
    prereqs
    exit 0
  ;;
esac

. "${CONFDIR}/initramfs.conf"
. /usr/share/initramfs-tools/hook-functions

if [ "${DROPBEAR}" != "n" ] && [ -r "/etc/crypttab" ] ; then
cat > "${DESTDIR}/bin/unlock" << EOF
#!/bin/sh
if PATH=/lib/unlock:/bin:/sbin /scripts/local-top/cryptroot; then
kill \`ps | grep cryptroot | grep -v "grep" | awk '{print \$1}'\`
# following lines will be executed after the passphrase has been correctly entered
# kill the remote shell
kill -9 \`ps | grep "\-sh" | grep -v "grep" | awk '{print \$1}'\`
exit 0
fi
exit 1
EOF
  
  chmod 755 "${DESTDIR}/bin/unlock"
  
  mkdir -p "${DESTDIR}/lib/unlock"
cat > "${DESTDIR}/lib/unlock/plymouth" << EOF
#!/bin/sh
[ "\$1" == "--ping" ] && exit 1
/bin/plymouth "\$@"
EOF
  
  chmod 755 "${DESTDIR}/lib/unlock/plymouth"
  
  echo To unlock root-partition run "unlock" >> ${DESTDIR}/etc/motd
  
fi
```

Make it executable: 

```bash
chmod +x /etc/initramfs-tools/hooks/crypt_unlock.sh
```

Create the cleanup script as `/etc/initramfs-tools/scripts/init-bottom/cleanup.sh`:

```bash
#!/bin/sh
echo "Killing dropbear"
killall dropbear
exit 0
```

...and make it executable:

```bash
chmod +x /etc/initramfs-tools/scripts/init-bottom/cleanup.sh
```

### 4. Create a static IP (or skip this step to use DHCP)

Edit `/etc/initramfs-tools/initramfs.conf` to add (or change) the line: 

```
IP=192.168.1.254::192.168.1.1:255.255.255.0::eth0:off
```

    format [host ip]::[gateway ip]:[netmask]:[hostname]:[device]:[autoconf]

    ([hostname] can be omitted)
   
> In newer kernels `eth0` is renamed to `enp0s3` (or something like that). Check that out with `ifconfig` (or `ip a` if `ifconfig` is not available anymore, or `ls /sys/class/net`)

### 5. Update initialramfs 

```
update-initramfs -u
```


### 6. Test 

1. Reboot your server 
2. Connect to your server via `ssh root@192.168.1.254 [-i ~/.ssh/id_rsa]`


# Advanced configuration: Create a Reverse Tunnel

You may want your SERVER to connect your Link Up Server with SSH, create a reverse tunnel to its SSH Server, so you can connect your SERVER over your Link Up Server, which eliminates the need for firewall forwarding for above process.

(see [reverse-tunnel-setup.md](./reverse-tunnel-setup.md))
