![This is an image](https://github.com/noobElias/AutoAutopilto/blob/main/logo.png)
# AutoAutopilto

A demo that can be deployed in any tenant. Meant to easily enroll unknown clients into autopilot without needing to auth into each individual client. Can be used 	together with MDT or may be deployed from SCCM to pre-reg clients before migration starts.

## How to:

  To implement  one needs to simply deploy the two functions (Maybe we make bicep later) into ones tenant, set the function app up with the appropriate permission (in this case "DeviceManagementServiceConfig.ReadWrite.All" is needed) and deploy the clientside script.

######  Function 1 [AddAutopilotObject](https://github.com/noobElias/AutoAutopilto/blob/main/AddAutopilotObject): 
  The function takes a json from the client, checks it for serialnumber and hardwarehash and posts it to the graph-api, if all is good it should return the output from     graph to the client 
  
######  Function 2 [PingAutopilot](https://github.com/noobElias/AutoAutopilto/blob/main/PingAutopilot.ps1): 
  Autopilot is sometimes slow to register and so its usefull for the client to know that its been properly enrolled (as of rigth now the check only asks if the object     exists in autopilot but it can easily be changed to check that a profile has been added
###### [ClientSide script](https://github.com/noobElias/AutoAutopilto/blob/main/ClientSide.ps1): 
  The client that is to be enrolled in autopilot can run the premade enrollment script. This script first takes the uris of the function-apps as variables and an optional variable for grouptag.
  It then installs the "getWindowsAutopilotInfo" script to extract hardwarehash. The hardwarehash gets posted to the "AddAutopilotObject" function wich returns status from graph.
  Afterwords the script waits for the "PingAutopilot" function for confirmation that the object exsist in autopilot before it exits (the default sleep-period i use is 180 secounds as autopilot sometimes is a bit slow to update)
  
## Errors!! 

###### autopiloterror 806  –  ZtdDeviceAlreadyAssigned: 
  During the testphase i enrolled the same VM a bunch of times but suddenly it would not enroll anymore. Both the AddAutopilotObject function and the graph-api   itself returned no errors but as i tried to upload the CSV for the device manualy it returned error 806, i found this blog [here](https://www.mdmandgpanswers.com/blogs/view-blog/how-i-scraped-a-device-out-of-autopilot-the-hard-way) but i did not have the exact same experience, my device did not apear in autopilot at all, but i did find it in Microsoft store for business and after deleting it from there autopilot enrollment functioned as expected again. 
## Thanks!!

###### Eldar!! 
[Eldars blog](https://eldar.cloud/2021/05/03/azure-logic-app-import-device-to-autopilot/)
The idea for this project originates in a design Eldar came up with while i was working with him!
Check out his artikle on the link above :)
