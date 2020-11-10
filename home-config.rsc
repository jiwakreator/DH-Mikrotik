# nov/10/2020 11:10:18 by RouterOS 6.47.7
# software id = W326-EUC6
#
# model = 951Ui-2HnD
# serial number = 815707DA1846
/interface ethernet
set [ find default-name=ether1 ] name=ether1-POE
set [ find default-name=ether2 ] name=ether2-Internet
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa-psk,wpa2-psk eap-methods="" group-ciphers=\
    tkip,aes-ccm mode=dynamic-keys name=utama supplicant-identity="" \
    unicast-ciphers=tkip,aes-ccm wpa-pre-shared-key=pastiberkah \
    wpa2-pre-shared-key=pastiberkah
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n disabled=no mode=ap-bridge \
    name=wlan1-home security-profile=utama ssid="Dree Hardware" \
    station-roaming=enabled
/ip pool
add name=dhcp_pool0 ranges=192.168.100.2-192.168.100.100
add name=dhcp_pool1 ranges=192.168.200.2-192.168.200.100
add name=dhcp_pool2 ranges=192.168.200.2-192.168.200.254
/ip dhcp-server
add address-pool=dhcp_pool2 disabled=no interface=wlan1-home lease-time=1d \
    name=dhcp1
/queue simple
add max-limit=20M/20M name="TOTAL BANDWIDTH" queue=default/default target=\
    192.168.200.0/24
add name="1.GAME ONLINE" packet-marks=Game-Upload,Game-Download parent=\
    "TOTAL BANDWIDTH" priority=1/1 queue=\
    pcq-upload-default/pcq-download-default target=192.168.200.0/24
add name="2.ICMP DNS" packet-marks=ICMP-DNS-Upload,ICMP-DNS-Download parent=\
    "TOTAL BANDWIDTH" queue=pcq-upload-default/pcq-download-default target=\
    192.168.200.0/24
add name="3.ALL TRAFFIC" packet-marks="Umum-Upload,Umum-Download,Youtube-Uploa\
    d,Youtube-Download,Sosmed-Upload,Sosmed-Download" parent=\
    "TOTAL BANDWIDTH" queue=default/default target=192.168.200.0/24
/queue tree
add name="GLOBAL ALL" parent=global queue=default
add max-limit=20M name="TOTAL DOWNLOAD" parent="GLOBAL ALL" queue=\
    pcq-download-default
add max-limit=20M name="TOTAL UPLOAD" parent="GLOBAL ALL" queue=\
    pcq-upload-default
add name="1.GAME DOWNLOAD" packet-mark=Game-Download parent="TOTAL DOWNLOAD" \
    priority=1 queue=pcq-download-default
add name="1.GAME UPLOAD" packet-mark=Game-Upload parent="TOTAL UPLOAD" \
    priority=1 queue=pcq-upload-default
add name="2.ICMP DNS DOWNLOAD" packet-mark=ICMP-DNS-Download parent=\
    "TOTAL DOWNLOAD" queue=pcq-download-default
add name="2.ICMP DNS UPLOAD" packet-mark=ICMP-DNS-Upload parent=\
    "TOTAL UPLOAD" queue=pcq-upload-default
add max-limit=18M name="3.ALL TRAFFIC DOWNLOAD" parent="TOTAL DOWNLOAD" \
    queue=pcq-download-default
add max-limit=18M name="3.ALL TRAFFIC UPLOAD" parent="TOTAL UPLOAD" queue=\
    pcq-upload-default
add name="1.UMUM DOWNLOAD" packet-mark=Umum-Download parent=\
    "3.ALL TRAFFIC DOWNLOAD" priority=7 queue=pcq-download-default
add name="1.UMUM UPLOAD" packet-mark=Umum-Upload parent=\
    "3.ALL TRAFFIC UPLOAD" priority=7 queue=pcq-upload-default
add name="2.YOUTUBE DOWNLOAD" packet-mark=Youtube-Download parent=\
    "3.ALL TRAFFIC DOWNLOAD" priority=3 queue=pcq-download-default
add name="2.YOUTUBE UPLOAD" packet-mark=Youtube-Upload parent=\
    "3.ALL TRAFFIC UPLOAD" priority=3 queue=pcq-upload-default
add name="3.SOSMED DOWNLOAD" packet-mark=Sosmed-Download parent=\
    "3.ALL TRAFFIC DOWNLOAD" priority=5 queue=pcq-download-default
add name="3.SOSMED UPLOAD" packet-mark=Sosmed-Upload parent=\
    "3.ALL TRAFFIC UPLOAD" priority=5 queue=pcq-upload-default
/tool user-manager customer
set admin access=\
    own-routers,own-users,own-profiles,own-limits,config-payment-gw
/user group
set full policy="local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,pas\
    sword,web,sniff,sensitive,api,romon,dude,tikapp"
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip address
add address=192.168.200.1/24 interface=wlan1-home network=192.168.200.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add !dhcp-options disabled=no interface=ether2-Internet
/ip dhcp-server network
add address=192.168.200.0/24 gateway=192.168.200.1
/ip dns
set servers=8.8.8.8,8.8.4.4
/ip firewall address-list
add address=192.168.200.0/24 list=IP-WLAN
/ip firewall mangle
add action=mark-connection chain=prerouting comment="ICMP DNS" \
    dst-address-list=!IP-WLAN new-connection-mark=ICMP-DNS passthrough=yes \
    protocol=icmp src-address-list=IP-WLAN
add action=mark-connection chain=prerouting dst-address-list=!IP-WLAN \
    dst-port=53 new-connection-mark=ICMP-DNS passthrough=yes protocol=udp \
    src-address-list=IP-WLAN
add action=mark-packet chain=forward connection-mark=ICMP-DNS in-interface=\
    ether2-Internet new-packet-mark=ICMP-DNS-Download passthrough=no
add action=mark-packet chain=forward connection-mark=ICMP-DNS \
    new-packet-mark=ICMP-DNS-Upload out-interface=ether2-Internet \
    passthrough=no
add action=mark-connection chain=postrouting comment="GAME ONLINE" \
    dst-address-list=IP-Game new-connection-mark=Game-Online passthrough=yes \
    src-address-list=IP-WLAN
add action=mark-packet chain=forward connection-mark=Game-Online \
    in-interface=ether2-Internet new-packet-mark=Game-Download passthrough=no
add action=mark-packet chain=forward connection-mark=Game-Online \
    new-packet-mark=Game-Upload out-interface=ether2-Internet passthrough=no
add action=mark-connection chain=postrouting comment=\
    "ALIHKAN KONEKSI GAME KE KONEKSI UMUM" connection-rate=200k-100M \
    dst-address-list=IP-Game new-connection-mark=Koneksi-Umum passthrough=yes \
    src-address-list=IP-WLAN
add action=mark-connection chain=postrouting comment="KONEKSI UMUM" \
    dst-address-list=IP-UMUM new-connection-mark=Koneksi-Umum passthrough=yes \
    src-address-list=IP-WLAN
add action=mark-packet chain=forward connection-mark=Koneksi-Umum \
    in-interface=ether2-Internet new-packet-mark=Umum-Download passthrough=no
add action=mark-packet chain=forward connection-mark=Koneksi-Umum \
    new-packet-mark=Umum-Upload out-interface=ether2-Internet passthrough=no
add action=mark-connection chain=postrouting comment=YOUTUBE \
    dst-address-list=IP-YOUTUBE new-connection-mark=Koneksi-Youtube \
    passthrough=yes src-address-list=IP-WLAN
add action=mark-packet chain=forward connection-mark=Koneksi-Youtube \
    in-interface=ether2-Internet new-packet-mark=Youtube-Download \
    passthrough=no
add action=mark-packet chain=forward connection-mark=Koneksi-Youtube \
    new-packet-mark=Youtube-Upload out-interface=ether2-Internet passthrough=\
    no
add action=mark-connection chain=postrouting comment=SOSMED dst-address-list=\
    IP-SOSMED new-connection-mark=Koneksi-Sosmed passthrough=yes \
    src-address-list=IP-WLAN
add action=mark-packet chain=forward connection-mark=Koneksi-Sosmed \
    in-interface=ether2-Internet new-packet-mark=Sosmed-Download passthrough=\
    no
add action=mark-packet chain=forward connection-mark=Koneksi-Sosmed \
    new-packet-mark=Sosmed-Upload out-interface=ether2-Internet passthrough=\
    no
/ip firewall nat
add action=masquerade chain=srcnat
/ip firewall raw
add action=add-dst-to-address-list address-list=IP-Game address-list-timeout=\
    12h chain=prerouting comment="MOBILE LEGENDS" dst-address-list=!IP-WLAN \
    dst-port=5000-5508,5551-5558,5601-5608,5651-5658,30097-30147,9000-9010 \
    protocol=tcp src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-Game address-list-timeout=\
    12h chain=prerouting dst-address-list=!IP-WLAN dst-port=\
    5000-5200,5500-5700,8001,30000-30300,9000-9010 protocol=udp \
    src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-UMUM address-list-timeout=\
    3h chain=prerouting comment="IP UMUM" dst-address-list=!IP-WLAN dst-port=\
    80,81,443,8000-8081,21,22,23,81,88,5050,843,182,53 protocol=tcp \
    src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-UMUM address-list-timeout=\
    3h chain=prerouting dst-address-list=!IP-WLAN dst-port=\
    80,81,443,8000-8081,21,22,23,81,88,5050,843,182,53 protocol=udp \
    src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-YOUTUBE \
    address-list-timeout=1h chain=prerouting comment="IP YOUTUBE" content=\
    googlevideo.com dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-Game address-list-timeout=\
    12h chain=prerouting comment="FREE FIRE" dst-address-list=!IP-WLAN \
    dst-port=10000-10007,7008,10000-10009,17000 protocol=udp \
    src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-Game address-list-timeout=\
    12h chain=prerouting dst-address-list=!IP-WLAN dst-port=\
    7006,14000,20561,39698,39779,39003 protocol=tcp src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-Game address-list-timeout=\
    12h chain=prerouting comment=PUBG dst-address-list=!IP-WLAN dst-port=\
    7889,10012,17500,18081 protocol=tcp src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-Game address-list-timeout=\
    12h chain=prerouting dst-address-list=!IP-WLAN dst-port=\
    8011,9030,10010-10650,11000-14000,17000,20000,20001,20002 protocol=udp \
    src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=5h chain=prerouting comment=INSTAGRAM content=\
    .cdninstagram.com dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=5h chain=prerouting content=\
    scontent-sin6-2.cdninstagram.com dst-address-list=!IP-WLAN \
    src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=5h chain=prerouting content=.instagram.com \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-src-to-address-list address-list=IP-SOSMED \
    address-list-timeout=3h chain=prerouting comment=FACEBOOK content=\
    .facebook.com dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=3h chain=prerouting content=.facebook.net \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=3h chain=prerouting content=.fbcdn.net \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=2h chain=prerouting comment=TIKTOK content=\
    tiktokcdn.com dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=2h chain=prerouting content=tiktokv.com \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=2h chain=prerouting content=.amemv.com \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=2h chain=prerouting content=.musical.ly \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=1d chain=prerouting comment=TELEGRAM content=\
    .telegram.org dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=1d chain=prerouting dst-address-list=!IP-WLAN \
    dst-port=5222,8443 protocol=tcp src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=1d chain=prerouting comment=WHATSAPP content=\
    .whatsapp.net dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=1d chain=prerouting content=.whatsapp.com \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=3h chain=prerouting comment=TWITTER content=\
    .twitter.com dst-address-list=!IP-WLAN src-address-list=IP-WLAN
add action=add-dst-to-address-list address-list=IP-SOSMED \
    address-list-timeout=3h chain=prerouting content=.twimg.com \
    dst-address-list=!IP-WLAN src-address-list=IP-WLAN
/ip proxy
set cache-administrator=admin@langkasa.id cache-on-disk=yes
/system clock
set time-zone-name=Asia/Jakarta
/system identity
set name=DH-MikroTik
/system logging
set 0 action=disk prefix="akses ke router -->"
/system ntp client
set enabled=yes primary-ntp=202.65.114.202 secondary-ntp=162.159.200.1
/tool user-manager database
set db-path=user-manager
