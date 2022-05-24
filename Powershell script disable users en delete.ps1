Param( [Parameter(Mandatory=$true)][string]$delete_ja_of_nee)
# instellen van aantal dagen inactief om disabled te worden.
$dageninactief = 90
$datum = (Get-Date).Adddays(-($dageninactief))

# Hieronder wordt de lijst gemaakt met users die meer dan $dageninactief inactief zijn.
# Manier voor vinden van inactieve gebruikers.

$gebruikers = Get-ADUser -Filter { LastLogonDate -lt $dageninactief -and Enabled -eq $true } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

# disabelen van inactieve users
ForEach ($gebruiker in $gebruikers){
  $disablegebruiker = gebruiker.DistinguishedName
  Disable-ADAccount -Identity $disablegebruiker
  Get-ADUser -Filter { DistinguishedName -eq $disablegebruiker } | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, Enabled
}
if($delete_ja_of_nee -like 'ja?'){ 
    # Delete inactieve gebruikers
    ForEach ($gebruiker in $gebruikers){
    Remove-ADUser -Identity gebruiker.DistinguishedName -Confirm:$false
    Write-Output "$(gebruiker.Username) - gedeleted"
    }
}


#
## Voegt users toe die nog nooit hebben ingelogd 
#$gebruikers = Get-ADUser -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

# Voegt users toe die ouder zijn dan $dageninactief en is geen service account.
#$gebruikers = Get-ADUser -Filter { LastLogonDate -lt $datum -and Enabled -eq $true -and SamAccountName -notlike "*svc*" } -Properties LastLogonDate | Select-Object @{ Name="Username"; Expression={$_.SamAccountName} }, Name, LastLogonDate, DistinguishedName

#