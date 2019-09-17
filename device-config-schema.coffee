module.exports = {
  title: "pimatic-smartmeter3 device config schemas"
  Smartmeter3Device: {
    title: "Smartmeter config options"
    type: "object"
    extensions: ["xLink", "xAttributeOptions"]
    properties:
      serialPort:
        description: "Serialport name (e.g. /dev/ttyUSB0)"
        type: "string"
        default: "/dev/ttyUSB0"
      baudRate:
        description: "Baudrate to use for communicating over serialport (e.g. 9600)"
        type: "integer"
        default: 115200
      dataBits:
        description: "Number of databits to use for communication over serialport (e.g. 7)"
        type: "integer"
        default: 8
      parity:
        description: "Parity to use for communication over serialport (can be 'none', 'even', 'mark', 'odd', 'space')"
        type: "string"
        default: "none"
      stopBits:
        description: "Number of stopBits to use for communication over serialport (can be 1 or 2)"
        type: "integer"
        default: 1
      flowControl:
        description: "Use flowControl for communication over serialport (can be true or false)"
        type: "boolean"
        default: true
      t1TotalUsage:
        description: "RegEx for tariff 1 total usage (T1)"
        type: "string"
        default: "^1-0:1\\.8\\.1\\(0+(\\d+\\.\\d+)\\*kWh\\)"
      t2TotalUsage:
        description: "RegEx for tariff 2 total usage (T2)"
        type: "string"
        default: "^1-0:1\\.8\\.2\\(0+(\\d+\\.\\d+)\\*kWh\\)"
      activeTariff:
        description: "RegEx for active tariff "
        type: "string"
        default: "^0-0:96.14.0\\(0+(.*?)\\)"
      actualUsage:
        description: "RegEx for actual usage"
        type: "string"
        default: "^1-0:1.7.0\\((.*?)\\*"
      gasTotalUsage:
        description: "RegEx for gas total usage"
        type: "string"
        default: "^0-1:24\\.2\\.1\\(\\d{12}.\\)\\(0+(\\d+\\.\\d+)\\*m3\\)"
  }
} 
