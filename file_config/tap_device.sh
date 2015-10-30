##################################################################
#
# Add tap device and write to config, in case of system reboot
#
##################################################################
auto_add_tap_device() {
    if [ `ifconfig -a | grep $TAPDEV | wc -l` -eq 0 ] ; then
        echo '$TAPDEV already exist. Check your device'
        exit 1
    fi

    # Add tap device
    tunctl -t $TAPDEV
    ifconfig $TAPDEV up

    # Add device into /etc/network/interfaces
    write_file $FILE
}

write_file() {
    cat <<_EOF
auto $TAPDEV
iface $TAPDEV inet manual
    pre-up tunctl -t \$IFACE
    pre-up ifconfig \$IFACE up
    post-down ifconifg \$IFACE down
    post-down tunctl -d \$IFACE

_EOF
}


##################################################################
#
# Delete tap device and remove from config file
#
##################################################################
del_tap_device() {
    if [ `ifconfig -a | grep $TAPDEV | wc -l` -ne 0 ] ; then
        ifconfig $TAPDEV down
        tunctl -d $TAPDEV
    fi
}


del_tap_from_conffile() {
    LINE_START=0
    while read line
    do
        LINE_START=$[$LINE_START + 1]
        if [[ ${line}x == "auto $TAPDEV"x ]] ; then
            LINE_END=$[$LINE_START + 6]
            sed -i "${LINE_START},${LINE_END}d" $FILE
            break
        fi
    done < $FILE
}
