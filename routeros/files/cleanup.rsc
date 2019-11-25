:put "creating on-boot script..."
/system script add name="on-boot" source="/system reset-configuration skip-backup=yes no-defaults=yes keep-users=yes run-after-reset=firstboot.rsc"
:put "enabling on-boot script..."
/system scheduler add name="on-boot" on-event="on-boot" start-time="startup"
