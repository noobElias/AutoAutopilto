#Api for enrollment will not function unless given atleast serial and hardwarehash in json format
#Api for pinging will not function unless given serialnumber in json format

#set some params :) 
$uri = '' # Function app URL for enrolling into autopilto
$GroupTag = '' #optional autopilot grouptag 
$pinguri = '' # function app URL for pinging autopilot

Install-PackageProvider -Name 'NuGet' -Force
#install "getautopiltoinfo" script to get the hardwarehash
if(-not(test-path "C:\HWID")){
    New-Item -Type Directory -Path "C:\HWID"
}
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
Install-Script -Name Get-WindowsAutopilotInfo -Force

#if $grouptag variable is defined include it 
if($GroupTag){
    $hwid = Get-WindowsAutopilotInfo -GroupTag $GroupTag
}
else{
    $hwid = Get-WindowsAutopilotInfo
}

#Check to see if device is already in autopilot, this can be commented out if not needed
$json = @{
    serialNumber = $hwid.'Device Serial Number'
    
} | ConvertTo-Json

$apres = Invoke-RestMethod -Method Post -Uri $pinguri -Body $json -ContentType "application/json"
if($apres.'@odata.count'  -eq 1){
    Write-Host "Device allready enrolled"
    exit 0
}

#convert output to json
$hwid = $hwid | ConvertTo-Json

#if prev steps are OK and the $hwid -ne $null is present send to app, else throw error
if($hwid){
    #the app should return output from graph showing the object that was uploaded 
    $res = Invoke-RestMethod -Method Post -uri $uri -Body $hwid -ContentType "application/json"
}
else{
    Write-Error "HWID mangler, noe er galt..."
}

#Ping autopilot to find if device is there
$apres = Invoke-RestMethod -Method Post -Uri $pinguri -Body $json -ContentType "application/json"


while($apres.value.deploymentProfileAssignmentStatus -notmatch 'assigned'){
    Write-Host "ingen objekt, tar en blund"
    Start-Sleep -Seconds 270
    $apres = Invoke-RestMethod -Method Post -Uri $pinguri -Body $json -ContentType "application/json"

}
if($apres.value.deploymentProfileAssignmentStatus -match 'assigned'){
    $apres.value
}

