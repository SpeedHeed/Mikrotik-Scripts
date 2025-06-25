{
:local threshold "1Gbps";
:local interface "ether4-SALTO";

:local result [/interface ethernet monitor $interface once as-value]
:local intspeed ($result->"rate")

:if ($intspeed != $threshold) do={ 
    :log info ($interface . " is below threshold: " . $intspeed . " Resetting interface")
    /interface ethernet disable $interface
    :delay 5s;
    /interface ethernet enable $interface
    :log info ($interface . " has been reset")
 }

}