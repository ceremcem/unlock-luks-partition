# Description 

These are the tools to examine and make quick-n-dirty tests with initramfs. 

# Usage 

Extract an initramfs: 

```cmd
$ cd unlock-luks-partition/initramfs-helpers/
$ ./unpack /boot/initrd.img-5.6.0-2-amd64 
5868 blocks
371820 blocks
$ ls initrd.d/
bin   cryptroot  init    lib    lib64        run   scripts  var
conf  etc        kernel  lib32  root-70xplQ  sbin  usr
$ ./repack 
Packing ./initrd.d as ./initrd.img-5.6.0-2-amd64.new
```
