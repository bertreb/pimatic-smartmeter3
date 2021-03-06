pimatic-smartmeter3
===================

Reading "Smartmeter" energy (electricity and gas) usage through P1 port.
This plugin is a based on the smartmeter versions of saberone and rick00001. 
This plugin supports serialport version 6 (node v4 and v8) and gives the possibility to read ascii based Datagrams from Smartmeters (like the DSMR). You can change the regex formulas for the energy values in the device config. 
If this plugin doesn't fit, you could use the more advanced pimatic-smartmeter-obis plugin (https://github.com/bertreb/pimatic-smartmeter-obis).

Installation
------------
To enable the smartmeter plugin add this to the plugins in the config.json file.

```
...
{
  "plugin": "Smartmeter3"
}
...
```

and add the following to the devices

```
{
  "id": "smartmeter3",
  "class": "Smartmeter3Device",
  "name": "smartmeter3",
  "serialport": "/dev/ttyUSB0",
  "baudRate" : 115200,
  "dataBits" : 8,
  "parity" : "none",
  "stopBits" : 1,
  "flowControl" : true
}
```

Then install through the standard pimatic plugin install page.


Configuration
-------------
You can configure what serialport to use and the serialport settings.

The device provides the following 4 variables:
- $\<device id\>.actualusage (Actual usage in Watt)
- $\<device id\>.tariff1totalusage (Tariff 1 total usage in kWh) 
- $\<device id\>.tariff2totalusage (Tariff 2 total usage in kWh) 
- $\<device id>\.gastotalusage (Gas total usage in m3) 

The number of decimals in de Gui can be changed via xAttributeOptions.

Different smartmeter versions
---------------------------------------
The current version has been tested with a DSMR5.0 smartmeter.
If your smartmeter version uses different data field you can change the RegEx in de device config to meet your smartmeter.

A simple commandline tool can help to get your smartmeter data and build your RegExp. 
The tool is a node.js app/tool that dumps the P1 data straight to a file. 

Run the following commands from the root of this plugin.

```
npm install
chmod +x logP1.js
./logP1.js
```

RegEx configuration
---------------------------------------
Below the 5 customizable Regular Expression (RegEx) fields in the config.json device section. The RegEx is used to filter out the specific data. A RegEx string need double backslashes (escape character in strings). If you edit the RegEx in the Gui Device page, you can use the normal single backslashes.

```
{
  "t1TotalUsage": "^1-0:1\\.8\\.1\\(0+(\\d+\\.\\d+)\\*kWh\\)",
  "t2TotalUsage": "^1-0:1\\.8\\.2\\(0+(\\d+\\.\\d+)\\*kWh\\)",
  "activeTariff": "^0-0:96.14.0\\(0+(.*?)\\)",
  "actualUsage": "^1-0:1.7.0\\((.*?)\\*",
  "gasTotalUsage" : "^0-1:24\\.2\\.1\\(\\d{12}.\\)\\(0+(\\d+\\.\\d+)\\*m3\\)"
}
```
 
If you have issues, please create an issue overe here : https://github.com/bertreb/pimatic-smartmeter3/issues

