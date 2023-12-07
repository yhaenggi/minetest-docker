These images have been built and tested on docker i386, amd64, arm32v7 and arm64v8. This is a multi platform image.

## Usage ##

    docker run -d -p 30000:30000/udp yhaenggi/minetest:5.8.0
Extra arguments go to minetest server directly.

## Build ##

If you want to build the images yourself, you'll have to adapt the registry file, copy qemu and enable binfmt.

    cp /usr/bin/qemu-{i386,x86_64,arm,aarch64}-static .

In case you want other arches, just add them in the ARCHES files and copy the corresponding qemu user static binary. If you want support for another archtitecture, open an issue.

You can verify binfmt support for multiarch builds with (should show enabled):

    grep -E "arm|aarch" -A1 -R /proc/sys/fs/binfmt_misc/

## Tags ##
   * 5.8.0
   * 5.7.0
   * 5.6.1
   * 5.6.0
   * 5.4.1
   * 5.4.0
   * 5.3.0
   * 5.2.0
   * 5.1.1
   * 5.1.0
   * 5.0.1
