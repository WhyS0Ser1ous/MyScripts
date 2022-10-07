#region InitialCimOps
$DistributionPoint = "ASIFW004.PHIL.CONVERGYS.COM"
$SiteServer="MK2AW039.phil.convergys.com"

[System.Xml.XmlDocument]$settings = Get-Content -Path C:\Installers\OSD-Files\x64\Client_Highmark.xml
$settings.UIpp.Software.Application.Name


$cimSession = New-CimSession -ComputerName $SiteServer
$siteCode = (Get-CimInstance -CimSession $cimSession -Namespace root/SMS -ClassName __NAMESPACE).Name.Replace('site_','')
$cimSessionParam = @{
    CimSession = $cimSession
    Namespace = "root/SMS/site_$siteCode"
}

$systemResource = @()
foreach ($system in $DistributionPoint) {
    $_systemResource = Get-CimInstance @cimSessionParam -Query @"
    Select *
    From SMS_SystemResourceList
    Where ServerName Like '$system%' And RoleName = 'SMS Distribution Point'
"@
    if (!$_systemResource) { Write-Warning "Distribution Point: '$system' not found." }
    else { $systemResource += $_systemResource }
}

if ($systemResource) { $dpDictionary = [System.Collections.IDictionary]@{ SiteCode = @($systemResource.SiteCode); NALPath = @($systemResource.NALPath) } }




$contentPackage = @()
foreach ($application in $settings.UIpp.Software.Application.Name) {
    $_contentPackage = Get-CimInstance @cimSessionParam -Query "Select * From SMS_ContentPackage Where Name = '$application'"
    if (!$_contentPackage) { Write-Warning "Application Name: '$application' not found." }
    else { $contentPackage += $_contentPackage }
}


#region ProcessingApplications
foreach ($application in $contentPackage) {

    ## Adding Distribution Points to the ContentPackage instance.
    if ($dpDictionary) {
        $result = Invoke-CimMethod -InputObject $application -MethodName 'AddDistributionPoints' -Arguments $dpDictionary
        if ($result.ReturnValue -eq 0) { Write-Verbose "Successfully added Distribution Points to application '$($application.Name)'." }
        else { Write-Warning "Operation 'AddDistributionPoints' returned non-zero '$($result.ReturnValue)' for application '$($application.Name)'." }
    }
}