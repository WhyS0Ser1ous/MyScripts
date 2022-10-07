import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

Set-Location C:

#TXT file that has one computer name per line. Be sure to remove spaces
$computers = Get-Content "C:\Users\jene9505\Documents\HostName.txt"

#Set to use CNX (SCCM1) or CAS (SCCM2)
#Set-Location CNX:
Set-Location CAS:

#Collection you wish to add these machines to
$collectionName = "PIP GLOBE Globe MyBSS CRM JAR 3.7 BAU 6/14/2022"

ForEach($computer in $computers){
    $resource = $null
    $resource = Get-CMDevice -Name $computer
    
   If($resource -ne $null){
    $resource.name
   Add-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName -Resource $resource -verbose}

}