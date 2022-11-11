using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$serial = $Request.body.serialNumber

if(($serial -eq $null) -or ($serial -eq '')){
    write-host "Funker ikke"
    $out = "ingen serienummer, pinger IKKE"
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $out
    })
}
elseif( ($serial -ne $null) -and ($serial -ne '') ){
    $token = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token
    $encoded = [uri]::EscapeDataString($serial)
    $uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities?`$filter=contains(serialNumber,'$encoded')"
    $out= Invoke-RestMethod -Method Get -Uri $uri -Headers @{Authorization = "$token" }
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $out
    })
}

#Her gir det mening å skrive til Teams/slack/goolagen chat. på den måten kan man få logg over innrullerte enheter. kanskje man kan utvide funksjonalitet for å ta med objektets gamle navn? man får vel det i tasksequencen på en eller annen måte?
#på den måten har man log over innrullerte enheter (ofte blir brukere forvirret når ikke navnet som er skrevet på en lapp på dataen er riktig/)
