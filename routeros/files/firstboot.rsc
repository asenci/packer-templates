:put "enabling DHCP on all interfaces..."
/ip dhcp-client add interface=[find] disabled="no"

:put "removing startup script..."
/file remove "boot.rsc"
