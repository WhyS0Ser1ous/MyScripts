import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

Set-Location C:

#Set to use CNX (SCCM1) or CAS (SCCM2)
Set-Location CAS:

$result = 'c:\device.txt'
$collMem = Get-CMCollectionMember -CollectionId "CAS0B077" | Select-Object Name,Domain,LastLogonUser,DeviceOS,DeviceOSBuild,MACAddress,SerialNumber
$collMem | Out-File -FilePath $result