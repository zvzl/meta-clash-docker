
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p

echo -e "======================== 0.1 判断是否安装clash文件 ========================\n"
if [ ! -e '/usr/bin/clash' ]; then

    clash=$(curl -s --connect-timeout 5 https://api.github.com/repos/MetaCubeX/mihomo/releases | jq -r .[]."name" | grep -m1 -E "([0-9]{1,2}\.?){3,4}$")
    if [ -z "$clash" ]; then
        echo 'failed to get clash version online, set clash version to v1.14.0'
        clash="v1.14.0"
    fi

    echo "当前获取clash版本为$clash"
    if [ $(arch) == aarch64 ]; then     wget -P /usr/bin https://ghproxy.com/https://github.com/MetaCubeX/mihomo/releases/download/$clash/mihomo-linux-arm64-$clash.gz;     gunzip /usr/bin/Clash.Meta-linux-arm64-$clash.gz;     mv /usr/bin/Clash.Meta-linux-arm64-$clash /usr/bin/clash;     chmod +x /usr/bin/clash; fi
    # if [ $(arch) == x86_64 ]; then     wget -P /usr/bin https://mirror.ghproxy.com/https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-$clash.gz;     gunzip /usr/bin/clash-linux-amd64-$clash.gz;     mv /usr/bin/clash-linux-amd64-$clash /usr/bin/clash;     chmod +x /usr/bin/clash; fi
    
    echo "下载clash完成"
fi
echo -e "======================== 0.2 判断目录是否存在文件 ========================\n"
if [ ! -e '/root/.config/clash/dashboard/index.html' ]; then
    echo "开始移动面板文件到dashboard目录"
    rm -rf /root/.config/clash/dashboard
    mkdir -p /root/.config/clash/dashboard
    curl -kfSL -o meta_yacd.zip  https://ghproxy.com/https://github.com/MetaCubeX/Yacd-meta/archive/gh-pages.zip
    unzip -o meta_yacd.zip > /dev/null
    mv /Yacd-meta-gh-pages/* /root/.config/clash/dashboard
#     yacd=$(curl -s --connect-timeout 5 https://api.github.com/repos/haishanh/yacd/releases | jq -r .[]."name" | grep -m1 -E "([0-9]{1,2}\.?){3,4}$")
#     if [ -z "$yacd" ]; then
#         echo 'failed to get yacd version'
#         yacd="v0.3.8"
#     fi
#     wget https://ghproxy.com/https://github.com/haishanh/yacd/releases/download/$yacd/yacd.tar.xz
#     tar -xvf yacd.tar.xz
#     mv /public/* /root/.config/clash/dashboard
fi

if [ ! -e '/root/.config/clash/Country.mmdb' ]; then
    echo "下载Country.mmdb文件"
    wget -P /root/.config/clash https://ghproxy.com/https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
fi

if [ ! -e '/root/.config/clash/iptables.sh' ]; then
    echo "移动iptables.sh文件"
    cp /tmp/iptables.sh /root/.config/clash/iptables.sh
fi

# echo "更新geodata文件"
# wget -O /root/.config/clash/geosite.dat https://ghproxy.com/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat
# wget -O /root/.config/clash/geoip.dat https://ghproxy.com/https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
# if [ ! -e '/root/.config/clash/geosite.dat' ]; then
#     echo "创建geosite.dat文件"
#     touch /root/.config/clash/geosite.dat
# fi

# if [ ! -e '/root/.config/clash/geoip.dat' ]; then
#     echo "创建geoip.dat文件"
#     touch /root/.config/clash/geoip.dat
# fi

echo -e "======================== 1. 开始自义路由表 ========================\n"
if [[ $iptables == true ]]; then
    bash /root/.config/clash/iptables.sh
    echo -e "自定义iptables路由表成功..."
fi
echo -e "======================== 2. 是否内核开启tun ========================\n"
if [[ $tun == true ]]; then
    mkdir -p /lib/modules/$(uname -r)
    modprobe tun
    echo -e "如果没有报错就成功开启tun"
elif [[ $tun == false ]]; then
    echo -e "你没有设置开启tun变量"
fi
echo -e "======================== 3. 启动clash程序 ========================\n"
clash
#pm2-docker start clash --name clash
