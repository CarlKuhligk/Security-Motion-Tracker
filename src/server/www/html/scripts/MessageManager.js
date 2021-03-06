export class MessageManager {
  constructor() {
    this.listeners = {};
    this.websocket = {};
  }

  connect() {
    $.get("../lib/getServerIP.php").done((serverIp) => {
      // create a new WebSocket.
      this.openWebsocket(serverIp);
    });
  }

  openWebsocket(serverIp) {
    this.websocket = new WebSocket("ws://" + serverIp + ":8080");

    this.websocket.addEventListener("open", (event) => {
      this.onOpen(event);
    });

    this.websocket.addEventListener("message", (event) => {
      this.onMessage(event);
    });

    this.websocket.addEventListener("close", (event) => {
      this.onClose(event);
    });
  }

  onOpen(event) {
    var messageObject = {};
    messageObject.t = "s";
    messageObject.s = 1;
    var subscribeMessage = JSON.stringify(messageObject);
    this.websocket.send(subscribeMessage);
  }

  onMessage(event) {
    var message = JSON.parse(event.data);

    switch (message.t) {
      case "uc":
        console.log("UpdateConnection received: %o", message);
        this.callback("handleUpdateConnection", message);
        break;

      case "M":
        console.log("Add measurement received: %o", message);
        this.callback("handleAddMeasurement", message);
        break;

      case "e":
        console.log("Add event received: %o", message);
        this.callback("handleAddEvent", message);
        break;

      case "su":
        console.log("Settings update received: %o", message);
        this.callback("handleSettingsUpdate", message);
        break;

      case "ad":
        console.log("Add device received: %o", message);
        message.d.forEach((element) => {
          this.callback("handleAddDevice", element);
        });
        break;

      case "rd":
        console.log("Remove device received: %o", message);
        this.callback("handleRemoveDevice", message);
        break;
    }
  }

  onClose(e) {
    console.log("Connection closed!");
  }

  sendNewSettings(device) {
    var updateMessage = {
      t: "S",
      i: device.id,
      it: document.getElementById("idleTimeoutInput").value,
      b: document.getElementById("batteryWarningInput").value,
      c: document.getElementById("connectionTimeoutInput").value,
      m: document.getElementById("measurementIntervalInput").value,
      ai: document.getElementById("accelerationMinInput").value,
      a: document.getElementById("accelerationMaxInput").value,
      ri: document.getElementById("rotationMinInput").value,
      r: document.getElementById("rotationMaxInput").value,
    };
    this.websocket.send(JSON.stringify(updateMessage));
  }

  addEventListener(method, callback) {
    this.listeners[method] = callback;
  }

  removeEventListener(method) {
    delete this.listeners[method];
  }

  callback(method, payload = null) {
    const callback = this.listeners[method];
    if (typeof callback === "function") {
      callback(payload);
    }
  }
}
