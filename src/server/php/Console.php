<?php
function consoleLog($message)
{
    $now = new DateTime(strtotime(time()), new DateTimeZone(getenv("TZ")));
    echo  $now->format('Y-m-d H:i:s') . " : " . $message;
}
