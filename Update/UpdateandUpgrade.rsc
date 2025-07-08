{
    #Script must be named "UpdateandUpgrade"
    :global currentOS [/system package update get installed-version];
    :global latestOS [/system package update get latest-version];

    :global currentFirmware [/system routerboard get current-firmware];
    :global latestFirmware [/system routerboard get upgrade-firmware];

    :if ($latestOS != $currentOS) do={
        :log info ("New RouterOS version available: " . $latestOS . " (current: " . $currentOS . ")");
        :delay 2s;
        :log info "Checking if firmware upgrade is available...";

        :if ($latestFirmware != $currentFirmware) do={
            :log info ("New firmware version available: " . $latestFirmware . " (current: " . $currentFirmware . ")");
            /system scheduler add name="UpdateandUpgradeRerun" start-time=startup on-event=\
            "{\r\
            \n:delay 20s;\r\
            \n/system scheduler remove UpdateandUpgradeRerun;\r\
            \n/system script run UpdateandUpgrade;\r\
            \n}";

            :delay 3s;
            /system routerboard upgrade;
            :log info "Routerboard firmware upgrade initiated. Rebooting in 10 seconds...";
            :delay 10s;
            /system reboot;
        } else={
            :log info ("Routerboard is up to date: " . $currentFirmware);
        }

        :log info "Starting update process...";
        :delay 3s;
        /system scheduler add name="UpdateandUpgradeRerun" start-time=startup on-event=\
        "{\r\
        \n:delay 20s;\r\
        \n/system scheduler remove UpdateandUpgradeRerun;\r\
        \n/system script run UpdateandUpgrade;\r\
        \n}";
        /system package update check-for-updates; /system package update install;
    } else={
        :log info ("RouterOS is up to date: " . $currentOS);

        :if ($latestFirmware != $currentFirmware) do={
            :log info ("New firmware version available: " . $latestFirmware . " (current: " . $currentFirmware . ")");
            /system scheduler add name="UpdateandUpgradeRerun" start-time=startup on-event=\
            "{\r\
            \n:delay 20s;\r\
            \n/system scheduler remove UpdateandUpgradeRerun;\r\
            \n/system script run UpdateandUpgrade;\r\
            \n}";

            :delay 3s;
            /system routerboard upgrade;
            :log info "Routerboard firmware upgrade initiated. Rebooting in 10 seconds...";
            :delay 10s;
            /system reboot;
        } else={
            :log info ("Routerboard is up to date: " . $currentFirmware);
        }
        
    }
}