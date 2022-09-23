function ConnectToExchange() {
  param($appId, $organization, $vaultCertificateName)

  # getting the certificate from the vault as a string
  $secretCertificateString = GetVaultSecret -VaultSecretName $vaultCertificateName

  Write-Host $secretCertificateString
  
  # creating a certificate object from vaultSecret
  $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2([System.Convert]::FromBase64String($secretCertificateString), "", "MachineKeySet")
  
  # ?? where to store the app id and the org value ??
  Connect-ExchangeOnline -AppId $appId -Organization $organization -Certificate $certificate
}
