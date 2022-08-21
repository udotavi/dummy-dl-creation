<#
Description: Creates a DL in Exchange 365
Date: 19th Aug, 2022
#>

param($mySbMsg, $TriggerMetadata)

$statusObject = @{status = "Complete"; statusCode = "200"; message = "Transaction Successful"; }

# helper function to update statusObject
function setStatusObject() {
  param($status, $statusCode, $message)
  $statusObject.status = $status
  $statusObject.statusCode = $statusCode
  $statusObject.message = $message
} 

# setup the connection to exchange
function ConnectionSetup() {
  try {
    Write-Host "Trying to setup connection.."
    # Connect-ExchangeOnline ...
  }
  catch {
    Write-Error "$_"
    setStatusObject "Error" "400" "Error: Could not connect to the Exchange. $_"
  }
}

# creates a new distribution list
function CreateDL() {
  try {
    Write-Host "Trying to Add the DL.."
    # New-DistributionGroup ...
  }
  catch {
    Write-Error "$_"
    setStatusObject "Error" "400" "Error: Could not create the DL. $_"
  }
}

function main() {
  Write-Host "Process Started - $(Get-Date)"

  # connection setup
  if ($statusObject.status -ne "Error") { ConnectionSetup }

  # dl creation
  if ($statusObject.status -ne "Error") { CreateDL }

  $responseHeader = @{'requestState' = $statusObject.status; 'requestType' = 'yet-to-be-decided??' }

  $processingStatus = @{
    "functionName"     = $TriggerMetadata.functionName; 
    "statusCode"       = $statusObject.statusCode; 
    "status"           = $statusObject.status; 
    "timestamp"        = $(Get-Date); 
    "response_message" = $statusObject.message;
  }

  # $mySbMsg.processingStatus += $processingStatus

  # $responseBody = ConvertTo-Json $mySbMsg

  # Calling function send message back to topic
  # sendResponse $responseHeader $responseBody
  sendResponse $responseHeader

  Write-Host "Process Completed - $(Get-Date)"
  # Write-Host $mySbMsg.GetType()
}

if ($MyInvocation.InvocationName -ne '.') {
  main
}

#end
