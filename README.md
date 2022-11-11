# AutoAutopilto

A demo that can be deployed in any tenant. Meant to easily enroll unknown clients into autopilot without needing to auth into each individual client. Can be used 	together with MDT or may be deployed from SCCM to pre-reg clients before migration starts.

## How to:

  To implement  one needs to simply deploy the two functions (Maybe we make bicep later) into ones tenant, set the function app up with the appropriate permission (in this case "DeviceManagementServiceConfig.ReadWrite.All" is needed) and deploy the clientside script.

### Function 1: AddAutopilotObject:
  The function takes a json from the client, checks it for serialnumber and hardwarehash and posts it to the graph-api, if all is good it should return the output from     graph to the client 
  
### Function 2: PingAutopilot: 
  Autopilot is sometimes slow to register and so its usefull for the client to know that its been properly enrolled (as of rigth now the check only asks if the object     exists in autopilot but it can easily be changed to check that a profile has been added
