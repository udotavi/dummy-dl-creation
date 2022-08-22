<#
Description: Creates a DL in Exchange 365
Date: 19th Aug, 2022
Version: Under Development
#>

param($mySbMsg, $TriggerMetadata)

# example mySbMsg ..
# {
#   "request_id": "REQ2123123",
#   "requestDetails":{
#       "dl_name": "dummy_dl",
#       "owner1": "dummy_owner1",
#       "owner2": "dummy_owner2",
#   }
# }

# removes unwanted characters from DL name
function fixDlName() {
  param($dl_name)

  $new_dl_name = $dl_name -replace "[^a-zA-Z0-9 .\-_']", "" -replace "\s+", " "
  return $new_dl_name
}

$dlCreationObj = @{
  "name"   = fixDlName -dl_name $mySbMsg.requestDetails.dl_name
  "owners" = $mySbMsg.requestDetails.owner1 + "," + $mySbMsg.requestDetails.owner2
}

$statusObject = @{
  status     = "Complete"
  statusCode = "200"
  message    = "Transaction Successful"
}

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
    # Connect-ExchangeOnline ... yet to be completed
  }
  catch {
    Write-Error "$_"
    setStatusObject -status "Error" -statusCode "400" -message "Error in ConnectionSetup: $_"
  }
}

# creates a new distribution list
function CreateDL() {
  try {
    Write-Host "Trying to create the DL.."
    Write-Host "DL Name:" $dlCreationObj.name ", Owners:" $dlCreationObj.owners
    # New-DistributionGroup -Name $dlCreationObj.name -ManagedBy $dlCreationObj.owners
  }
  catch {
    Write-Error "$_"
    setStatusObject -status "Error" -statusCode "400" -message "Error in CreateDL: $_"
  }
}

# parses overall process status and sends response
function RespondWithStatus() {
  $responseHeader = @{
    'requestState' = $statusObject.status
    'requestType'  = 'yet-to-be-decided??'
  }

  $processingStatus = @{
    "functionName"     = $TriggerMetadata.functionName
    "statusCode"       = $statusObject.statusCode
    "status"           = $statusObject.status
    "timestamp"        = $(Get-Date)
    "response_message" = $statusObject.message
  }

  # $mySbMsg.processingStatus += $processingStatus

  # $responseBody = ConvertTo-Json $mySbMsg
  # using Modules/sendResponse function to send message back to topic
  # sendResponse $responseHeader $responseBody
  sendResponse $responseHeader # dummy
}

function main() {
  Write-Host "Process Started - $(Get-Date)"

  # tries to setup a connection to Exchange Online
  ConnectionSetup

  # dl creation
  if ($statusObject.status -ne "Error") { CreateDL }

  # parses execution status/message and sends response
  RespondWithStatus

  Write-Host "Process Completed - $(Get-Date)"
}

if ($MyInvocation.InvocationName -ne '.') {
  main
}

#end
