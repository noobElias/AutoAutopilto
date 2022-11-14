#Api for enrollment will not function unless given atleast serial and hardwarehash in json format
#Api for pinging will not function unless given serialnumber in json format

#set some params :) 
$uri = '' # Function app URL for enrolling into autopilto
$GroupTag = '' #optional autopilot grouptag 
$pinguri = '' # function app URL for pinging autopilot

#install "getautopiltoinfo" script to get the hardwarehash
if(-not(test-path "C:\HWID")){
    New-Item -Type Directory -Path "C:\HWID"
}
Set-Location -Path "C:\HWID"
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
Install-Script -Name Get-WindowsAutopilotInfo

#if $grouptag variable is defined include it 
if($GroupTag){
    $hwid = Get-WindowsAutopilotInfo -GroupTag $GroupTag
}
else{
    $hwid = Get-WindowsAutopilotInfo
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

#json for pinging autopilto
$json = @{
    serialNumber = $res.serialNumber
    
} | ConvertTo-Json

$apres = Invoke-RestMethod -Method Post -Uri $pinguri -Body $json -ContentType "application/json"

while($apres.'@odata.count'  -eq 0){
    Write-Host "ingen objekt, tar en blund"
    Start-Sleep -Seconds 180
    $apres = Invoke-RestMethod -Method Post -Uri $pinguri -Body $json -ContentType "application/json"

}
if($apres.'@odata.count' -eq 1){
    $apres.value

}

