param([string] $mySbMsg, $TriggerMetadata)

# will setup the connection to exchange
function ConnectionSetup() {
  try {
      Write-Host "Trying to setup connection.."
  }
  catch {
      Write-Error "$_"
      return $null
  }

  return $true
}

function main(){
  Write-Host "Calling the main function.."
  ConnectionSetup
}

if ($MyInvocation.InvocationName -ne '.')
{
main
}