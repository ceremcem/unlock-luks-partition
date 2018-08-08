# Reverse Tunnel Setup

You may want your SERVER to connect your Link Up Server with SSH, create a reverse tunnel to its SSH Server, so you can connect your SERVER over your Link Up Server, which eliminates the need for firewall forwarding for above process.


### 1. Create public/private key pair 

Create a key for Dropbear SSH client (`dbclient`) so that it can make ssh to the Link Up Server: 

```bash
# mkdir -p /etc/initramfs-tools/root/key
# dropbearkey -f /etc/initramfs-tools/root/key/id_rsa -t rsa -s 2048
Public key portion is: 
...
```

Note: You must register this public key to your Link Up Server's SSH account's `authorized_keys` file. You can obtain the public key anytime with: 

```bash
# dropbearkey -y -f /etc/initramfs-tools/root/key/id_rsa
```

### 2. Add an ssh client to the initramfs

To copy an ssh client, the key file and some other mandatory files upon `update-initramfs -u`, create the following script at `/etc/initramfs-tools/hooks/ssh-client.sh`: 

```bash
#!/bin/sh
PREREQ="dropbear"
prereqs()
{
     echo "$PREREQ"
}
 
case $1 in
prereqs)
     prereqs
     exit 0
     ;;
esac

. /usr/share/initramfs-tools/hook-functions
# Begin real processing below this line

copy_exec /usr/bin/dbclient /bin
SSH_DIR="${DESTDIR}/root/.ssh/"
mkdir -p $SSH_DIR
cp /etc/initramfs-tools/root/key/id_rsa $SSH_DIR


# For DNS functionality
# Output of `strace busybox ping google.com 2>&1 | grep open`
LIB=/lib/x86_64-linux-gnu
mkdir -p "$DESTDIR/$LIB"
cp $LIB/libnss_dns.so.2 \
  $LIB/libnss_files.so.2 \
  $LIB/libresolv.so.2 \
  $LIB/libc.so.6 \
  "${DESTDIR}/$LIB"
echo nameserver 8.8.8.8 > "${DESTDIR}/etc/resolv.conf"
```
...and make it executable: 

```bash
chmod +x /etc/initramfs-tools/hooks/ssh-client.sh
```

### 3. Create the reverse tunnel client script

Create a script in `/etc/initramfs-tools/scripts/init-premount/link-with-server.sh` 
```bash
#!/bin/sh

PREREQ="dropbear"
 
prereqs()
{
     echo "$PREREQ"
}
 
case $1 in
prereqs)
     prereqs
     exit 0
     ;;
esac
 
. /scripts/functions

LINK_UP_PORT=1234
LINK_UP_SERVER="example.com"
LINK_UP_USER="myuser"
LINK_UP_SERVER_PORT=22

check_internet(){
	if ping -c 1 ${LINK_UP_SERVER} > /dev/null 2>&1; then
	    echo "online"
	else
	    echo "offline"
	fi
}

create_link(){
	echo "LINK UP: Waiting for the network config"
	while :; do
		if [[ `check_internet` == "online" ]]; then 
			break
		fi
		sleep 2
	done
	echo "Creating link with server..."
	/sbin/ifconfig lo up
	dbclient -R ${LINK_UP_PORT}:127.0.0.1:22 ${LINK_UP_USER}@${LINK_UP_SERVER} -p ${LINK_UP_SERVER_PORT} -i /root/.ssh/id_rsa -N -f -y -y
}

watchdog(){
	echo "Watchdog started for network config"
	sleep 60

	if [[ `check_internet` == "online" ]]; then
		echo "Internet connection OK: stopping the short watchdog,"
		echo "...setting long watchdog (10 minutes)."
		sleep 600
	else
		echo "No internet connection, rebooting..."
		sleep 3
	fi
	/bin/reboot
}


create_link &
watchdog &
```

...and make it executable: 

```bash
chmod +x /etc/initramfs-tools/scripts/init-premount/link-with-server.sh
```

### 4. Update the initramfs

```bash 
update-initramfs -u
```

### 5. Test 
1. Reboot
2. Machine should connect to the LINK UP server while booting on `example.com:22` with `myuser` and put its SSHD port to the server so that you can make SSH to the target by:

```bash
something@example.com$ ssh root@localhost -p 1234
```
