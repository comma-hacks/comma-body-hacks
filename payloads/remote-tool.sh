#!/bin/bash
function acquire_body_ip() {
  BODY_INTERNAL_IP=""
  while [[ $BODY_INTERNAL_IP == "" ]]; do
    sleep 1
    BODY_INTERNAL_IP=$(cat /data/media/developer/body/dnsmasq.leases | awk '{print $3}')
    until ping -c1 $BODY_INTERNAL_IP >/dev/null 2>&1; do :; done
  done
  echo $BODY_INTERNAL_IP
}

function run_install() {
sudo mount -o remount,rw /

if [[ ! -d /data/media/developer/body ]]; then
  mkdir -p /data/media/developer/body
fi

cat <<EOF > /data/media/developer/body/dnsmasq.conf
port=0
interface=eth0
dhcp-range=192.168.27.50,192.168.27.150,2h
dhcp-leasefile=/data/media/developer/body/dnsmasq.leases
bind-dynamic
EOF

cat <<EOF > /data/media/developer/body/body-eth0.sh
#!/bin/bash
while :
do
  until [[ "\$(ip -4 -o addr show eth0)" =~ "192.168.27.1" ]]; do
    echo "Eth0 lost its IP. Assigning 192.168.27.1"
    ip addr add 192.168.27.1/24 dev eth0
    sleep 1
  done
  sleep 10
done
EOF

chmod +x /data/media/developer/body/*.sh

chown -R comma:comma /data/media/developer/body

cat <<EOF > /etc/systemd/system/body-dnsmasq.service
[Unit]
Description=Body DHCP Server

[Service]
Type=simple
Restart=always
ExecStart=/usr/sbin/dnsmasq -d -C /data/media/developer/body/dnsmasq.conf

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/body-eth0.service
[Unit]
Description=Body Ethernet Manager

[Service]
Type=simple
Restart=always
ExecStart=/data/media/developer/body/body-eth0.sh

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable body-dnsmasq body-eth0

sudo mount -o remount,ro /

systemctl restart body-dnsmasq body-eth0
echo "Done"
}

function body_ssh() {
  if [[ ! -f /data/media/developer/body/body_ssh_key ]]; then
    sudo -u comma ssh-keygen -f /data/media/developer/body/body_ssh_key -N ''
    echo "Installing public key /data/media/developer/body_ssh_key into body... Enter password when prompted:"

    # Waiting for a lease to appear...
    echo "Scanning DHCP leases for body internal IP..."
    BODY_INTERNAL_IP="$(acquire_body_ip)"
    echo "Body Internal IP: $BODY_INTERNAL_IP"

    sudo -u comma ssh-copy-id -i /data/media/developer/body_ssh_key body@$BODY_INTERNAL_IP
  fi

  sudo -u comma ssh -t -i /data/media/developer/body_ssh_key body@$(acquire_body_ip) $@
}

if [ -t 0 ] ; then
  while :
  do
    echo "1 - run install"
    echo "2 - comma shell"
    echo "3 - body shell"
    echo "4 - body wifi setup"
    echo "5 - body wifi ip"
    echo "6 - read leases"
    echo "7 - ping body"
    printf "Please make a selection or press Ctrl-C to quit: "
    read selection;
    case $selection in
      1) run_install ;;
      2) sudo -u comma bash ;;
      3) body_ssh ;;
      4) body_ssh nmtui ;;
      5) body_ssh ip -4 -o addr show wlp1s0 2>/dev/null | awk '{print $4}' | cut -d '/' -f 1 ;;
      6) cat /data/media/developer/body/dnsmasq.leases ;;
      7) ping $(cat /data/media/developer/body/dnsmasq.leases | awk '{print $3}') ;;
      *) echo "Invalid selection.";; 
    esac
  done
else
  echo "Not an interactive shell. Cannot present you with the interface. Goodbye."
  sleep infinity
fi

