# Checklist for changing link up server port

Checklist for changing a Link Up Server's SSHD port on WAN side from X to Y: 

1. On Link Up Server:
    1. Change WAN side SSHD port (the forwarding) from X to Y.
2. On client:
    1. Change `SSH_PORT=` from X to Y in `link-with-server/config.sh`
    2. Restart link-with-server. 
    3. See server connection works. 
    4. Change `LINK_UP_SERVER_PORT=` from X to Y in `/etc/initramfs-tools/scripts/init-premount/link-with-server.sh`
    5. Update initramfs: `update-initramfs -u`
