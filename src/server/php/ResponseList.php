<?php
# responses
define("R_NOT_CONNECTED", 1);
define("R_CONNECTED", 2);
define("R_GLOBAL_UPDATE", 4);

define("R_DEVICE_LOGOUT_FAILED", 8);
define("R_DEVICE_LOGGED_OUT", 9);

define("R_DEVICE_REGISTERED", 10);
define("R_SUBSCRIBER_REGISTERED", 11);
define("R_SUBSCRIBER_UNREGISTERED", 12);

define("R_MISSING_PIN", 18);
define("R_MISSING_API_KEY", 19);
define("R_INVALID_API_KEY", 20);
define("R_DEVICE_ALREADY_REGISTERED", 21);
define("R_DEVICE_NOT_REGISTERED", 22);
define("R_INVALID_DEVICE_ID", 23);
define("R_SUBSCRIBER_ALREADY_REGISTERED", 24);
define("R_SUBSCRIBER_NOT_REGISTERED", 25);
define("R_MISSING_DEVICE_ID", 26);
define("R_SUBSCRIBER_MISSING_REGISTRATION_STATE", 27);
define("R_SUBSCRIBER_CANT_REGISTER_AS_STREAMER", 28);
define("R_STREAMER_CANT_REGISTER_AS_SUBSCRIBER", 29);
define("R_MISSING_TYPE", 30);
define("R_MISSING_DATA", 31);
define("R_UNKNOWN_DATA_TYPE", 32);
define("R_NOT_AUTHORIZED", 33);


define("R_SERVER_OFFLINE", 40);
define("R_UNKNOWN_ERROR", 42);



function createUpdateConnectionResponseMessage($id, $state)
{
    $message = (object)[
        't' => "uc",
        'i' => "{$id}",
        'c' => "{$state}"
    ];
    return json_encode($message);
}

function createResponseMessage($responseId)
{
    $response = (object)[
        't' => "r",
        'i' => "{$responseId}"
    ];
    return json_encode($response);
}

function createEventResponseMessage($deviceId, $eventId)
{
    $response = (object)[
        't' => "e",
        'e' => "{$eventId}",
        'i' => "{$deviceId}"
    ];
    return json_encode($response);
}

function createDeviceCreatedMessage($newApikey)
{
    $response = (object)[
        't' => "k",
        'a' => "{$newApikey}"
    ];
    return json_encode($response);
}

function createUpdateDeviceListMessage()
{
    $response = (object)[
        't' => "ud",
    ];
    return json_encode($response);
}
