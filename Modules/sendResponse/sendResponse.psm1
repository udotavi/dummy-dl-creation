# function sendResponse {
#   param($header, $body)
#   Write-Output $header $body
# }

function sendResponse {
  param($header, $body)
  Write-Host "In Send Response"
  if ($ENV:MESSAGE_URL) {
    Write-Host "In send message"
    Connect-AzAccount -Identity
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $aadToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://servicebus.azure.net").AccessToken

    $header.Add("Authorization", "Bearer $aadToken")
    $header.Add("Content-Type", "application/json")

    try {
      Invoke-WebRequest -Uri $ENV:MESSAGE_URL -Method 'POST' -Headers $header -Body $body
    }
    Catch {
      Write-Host "Error while sending message to the subscription. error: $_"
      return $false
    }

  }
  else {
    Write-Host "Value of environment variable MESSAGE_URL not set."
    return $false
  }
  return $true
}