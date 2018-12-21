echo "INSTALL SURICATA FORM APT"

apt-get install -y libpcre3-dbg libpcre3-dev autoconf automake libtool libpcap-dev libnet1-dev libyaml-dev libjansson4 libcap-ng-dev libmagic-dev libjansson-dev zlib1g-dev

apt-get install -y libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev

add-apt-repository ppa:oisf/suricata-stable -y

apt-get update -y

apt-get install suricata suricata-dbg -y

echo "TURN OFF GRO"

ethtool -K eth0 gro off

echo "CREATE TEST.RULES"

cat > /etc/suricata/rules/test.rules <<\EOF
alert icmp any any -> $HOME_NET any (msg:"ICMP connection attempt"; sid:1000002; rev:1;) 
alert tcp any any -> $HOME_NET 23 (msg:"TELNET connection attempt"; sid:1000003; rev:1;)
EOF

sed -i "s|default-rule-path: /var/lib/suricata/rules|default-rule-path: /etc/suricata/rules|" /etc/suricata/suricata.yaml
sed -i "s| - suricata.rules| - test.rules|" /etc/suricata/suricata.yaml
a=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
sed -i "s| HOME_NET:| HOME_NET:  \"[$a]\"\n #HOME_NET:|" /etc/suricata/suricata.yaml

echo "EDIT CONFIG FLOW"
echo "chinh sua file /etc/suricata/suricata.yaml:
- HOME_NET: IP cua may
- default-rule-path: /etc/suricata/rules
- rule-files: - test.rules
Chay chuong trinh: (rm -rf /var/run/suricata.pid) /usr/bin/suricata -D -c /etc/suricata/suricata.yaml -i  eth0
Xem log: tail -50f /var/log/suricata/fast.log
"

