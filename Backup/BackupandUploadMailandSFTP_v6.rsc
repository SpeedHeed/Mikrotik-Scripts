{
    :local sftpport 2222
    :local sftpaddress 10.10.15.10
    :local sftpUser "dev-backup";
    :local sftpPass "password";

    :local smtpmail "netzwerk@example.com";
    :local smtppassword "password";
    :local smtpreceiver "backup@example.com";
    :local smtpserver "smtp.example.com";
    :local smtpport 587;
    :local smtptls "yes"; #yes or no

    :log info "Setting mail settings"
    /tool e-mail set address=$smtpserver from=$smtpmail password=$smtppassword port=$smtpport start-tls=$smtptls user=$smtpmail

    :local date [/system clock get date];;
    :local day [:pick $date 4 6];
    :local month [:pick $date 0 3];
    :local year [:pick $date 7 11];

    :local monthNum
    :if ($month = "jan") do={:set monthNum "01"};
    :if ($month = "feb") do={:set monthNum "02"};
    :if ($month = "mar") do={:set monthNum "03"};
    :if ($month = "apr") do={:set monthNum "04"};
    :if ($month = "may") do={:set monthNum "05"};
    :if ($month = "jun") do={:set monthNum "06"};
    :if ($month = "jul") do={:set monthNum "07"};
    :if ($month = "aug") do={:set monthNum "08"};
    :if ($month = "sep") do={:set monthNum "09"};
    :if ($month = "oct") do={:set monthNum "10"};
    :if ($month = "nov") do={:set monthNum "11"};
    :if ($month = "dec") do={:set monthNum "12"};

    :local formattedDate ($day . "_" . $monthNum . "_" . $year);


    :local identity [/system identity get name];

    :local configFile ($formattedDate . "_" . $identity . ".rsc");
    :local backupFile ($formattedDate . "_" . $identity . ".backup");


    /export file="$configFile" hide-sensitive;
    :log info ("Config created: " . $configFile);

    /system backup save name="$backupFile";
    :log info ("Backup created: " . $backupFile);

    :delay 10s;

    :local ident [/system identity get name];
    :local sftpFolder [:pick $ident 0 3];
    :local pingResult [/ping $sftpaddress count=2];

    :if ($pingResult < 2) do={
        :log error ("Fehler: Host " . $sftpaddress . " ist nicht erreichbar");
    } else={
        :log info "Uploading config"
        /tool fetch upload=yes url=("sftp://" . $sftpaddress . ":" . $sftpport . "/" . $sftpFolder . "/" . $configFile) user="$sftpUser" password="$sftpPass" src-path=("/" . $configFile);

        :delay 10s

        :log info "Uploading Backup"
        /tool fetch upload=yes url=("sftp://" . $sftpaddress . ":" . $sftpport . "/" . $sftpFolder . "/" . $backupFile) user="$sftpUser" password="$sftpPass" src-path=("/" . $backupFile);
    }


    :log info "Sending Mail"
    :local files {$backupFile;$configFile}
    /tool e-mail send to=$smtpreceiver subject=$identity file=$files;


    :delay 10s;

    :log info "Removing Config";
    /file remove $configFile;

    :log info "Removing Backup";
    /file remove $backupFile;
}
