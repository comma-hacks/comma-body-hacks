# Overview

Let's make the comma body do more than just balance

![comma body with auxiliary computer](https://www.keyvanfatehi.com/2023/01/15/Comma-Body-external-PC-direct-ethernet-networking/comma-body-external-pc.png)

# Features

- Auto-configure networking between the Comma device and the auxiliary computer using systemd and dnsmasq for a DHCP server.
- Allow control of the body computer through the Comma Prime LTE service (limited to SSH. Use it to connect the body computer to new Wifi networks)

# Prerequisites

- Subscribed to Comma Prime
- Comma device is connected directly to LTE and not a wifi network
- Comma device has a USB-ethernet adapter connected directly to another PC (the auxiliary body computer)
- The other PC has a wifi adapter


# Install

For your development machine where you want to SSH into the Comma device and auxiliary body computer.

Be sure that you have enabled GitHub SSH keys and this computer is one of them. Find this feature in the Comma device UI under advanced network settings.

```bash
pushd ~
test -d comma-body-hacks || git clone git@github.com:kfatehi/comma-body-hacks
PROFILE=$(case "$SHELL" in 
*/bash) echo "$HOME/.bashrc" ;;
*/zsh) echo "$HOME/.zprofile" ;;
esac)
source $PROFILE
which cbh > /dev/null || echo 'export PATH="$HOME/comma-body-hacks/bin:$PATH"' >> $PROFILE
source $PROFILE
popd
```

# Usage

1. Set your dongle id (find this in https://connect.comma.ai)

```bash
cbh set-dongle <DONGLE ID>
```

2. Run the tool to see the options.

```bash
cbh
```

3. Choose the install option:

```
1 - run install <----- select this option first. only need to do it once.
2 - comma shell
3 - body shell
4 - body wifi setup
5 - body wifi ip
6 - read leases
7 - ping body
Please make a selection or press Ctrl-C to quit:
```

This will temporarily make writable the read-only filesystem in order to setup a DHCP server on the USB NIC.

See the payloads/remote-tool.sh file for more detail on what this does.

Soon after, DHCP negotiation will occur and you'll be able to use the other options.

It is safe to run the install option again and again, should you wish to modify the script.

Also notice that you are placed into a long-lived tmux session.

It pays to know tmux well especially in the comma world, so I recommend reading up starting with the session switching hotkey, so that you can switch quickly to the tmux session that contains all the comma daemons.

As such, I use this command to quickly get to the comma wherever it is, and likewise, the body computer.