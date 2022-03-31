<?php

class DBController
{

    private $dbConnection;
    private $host;
    private $user;
    private $password;
    private $dbname;

    // initiate database connection with given parameters
    function __construct($host, $user, $password, $dbname)
    {
        $this->host = $host;
        $this->user = $user;
        $this->password = $password;
        $this->dbname = $dbname;
    }

    public function connect()
    {
        // create db connection
        $this->dbConnection = new mysqli($this->host, $this->user, $this->password, $this->dbname);
        if ($this->dbConnection->connect_error) {
            echo "Connection to " . $this->dbname . " failed: " . $this->dbConnection->connect_error;
        } else {
            return true;
        }
    }

    function __destruct()
    {
        unset($this->dbConnection);
    }

    private function dbQuery($sql)
    {
        if (isset($sql)) {
            return $this->dbConnection->query($sql);
        }
        return null;
    }

    private function dbRequest($sql)
    {
        if (isset($sql)) {
            $result = $this->dbConnection->query($sql);
            if ($result === false) {
                echo "Error: " . $sql . "\n Errormessage: " . $this->dbConnection->error;
            }
            return true;
        }
        return false;
    }

    public function validateApiKey($apiKey)
    {
        $result = $this->dbQuery("SELECT id, staff_id FROM devices WHERE apikey = '$apiKey';");
        $row = $result->fetch_row();
        if (isset($row)) {
            $device = (object)[
                'id' => $row[0],
                'stuff_id' => $row[1],

            ];
            return $device;
        }
        return false;
    }

    public function validatePin($pin, $callingDevice)
    {
        $result = $this->dbQuery("SELECT staff.id, staff.name FROM staff WHERE id = (SELECT devices.staff_id FROM devices WHERE devices.id =" . $callingDevice->id . ") AND staff.pin = '" . $pin . "';");
        if (isset($result)) {
            $row = $result->fetch_row();
            if (isset($row)) {
                $employee = (object)[
                    'id' => $row[0],
                    'name' => $row[1],
                ];
                return $employee;
            }
        }
        return false;
    }

    public function validateChannelId($id)
    {
        $result = $this->dbQuery("SELECT id, staff_id FROM devices WHERE id = '$id';");
        $row = $result->fetch_row();
        if (isset($row)) {
            $device = (object)[
                'id' => $row[0],
                'staff_id' => $row[1]
            ];
            return $device;
        }
        return false;
    }

    public function setDeviceOnlineState($id, $state)
    {
        if ($state) {
            $this->dbRequest("UPDATE devices SET online=1 WHERE id='$id';");
        } else {
            $this->dbRequest("UPDATE devices SET online=0 WHERE id='$id';");
        }
    }

    public function getDeviceOnlineState($id)
    {
        $result = $this->dbQuery("SELECT online FROM devices WHERE id='$id';");
        $row = $result->fetch_row();
        $row = filter_var($row['online'], FILTER_VALIDATE_BOOLEAN);
        return $row;
    }

    public function writeDeviceData($tableName, $data)
    {
        $acceleration = $data["a"];
        $rotation = $data["r"];
        $temperature = $data["tp"];
        $battery = $data["b"];

        return $this->dbRequest("INSERT $tableName (acceleration, rotation, temperature, battery) VALUES ($acceleration, $rotation,$temperature,$battery);");
    }

    public function loadDevices()
    {
        $result = $this->dbQuery("SELECT id, staff_id FROM devices;");
        if (isset($result)) {
            $resultCount = $result->num_rows;
            $channels = array();

            for ($i = 0; $i < $resultCount; $i++) {
                $channelRaw =  $result->fetch_row();
                $device = (object)[
                    'id' => $channelRaw[0],
                    'name' => $channelRaw[1],
                ];
                array_push($channels, $device);
            }
            return $channels;
        }
        return NULL;
    }

    public function resetDevices()
    {
        $this->dbRequest("UPDATE devices SET online=0 WHERE 1;");
    }
}
