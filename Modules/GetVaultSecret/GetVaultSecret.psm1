function GetVaultSecret() {
  # gets values/secrets from azure key vault
  param($VaultSecretName)

  $vaultName = $ENV:key_vault_name # need to change the env var name
  $vaultSecret = Get-AzKeyVaultSecret -VaultName $vaultName -Name $vaultSecretName -AsPlainText
  return $vaultSecret
}