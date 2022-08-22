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

$dlCreationObj = @{
  "name"         = ""
  "smtp_address" = ""
  "owners"       = ""
}

$statusObject = @{
  status     = "Complete"
  statusCode = "200"
  message    = "Transaction Successful"
}

# helper function to update dlCreationObj
function setDlCreationObj() {
  $original_dl_string = $mySbMsg.requestDetails.dl_name
  # removing unwanted characters and extra spaces from dl name string
  $modified_dl_string = $original_dl_string -replace "[^a-zA-Z0-9 .\-_']", "" -replace "\s+", " "

  $dlCreationObj.name = "^" + $modified_dl_string
  $dlCreationObj.smtp_address = ($modified_dl_string -replace "\s+", "") + "@example.com"
  $dlCreationObj.owners = $mySbMsg.requestDetails.owner1 + "," + $mySbMsg.requestDetails.owner2
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
    setDlCreationObj # updating dl creation obj from payload
    Write-Host "Trying to create the DL.."
    Write-Host "DL Name:" $dlCreationObj.name ", SMTP Address:" $dlCreationObj.smtp_address ", Owners:" $dlCreationObj.owners
    # New-DistributionGroup -Name $dlCreationObj.name -ManagedBy $dlCreationObj.owners -PrimarySmtpAddress $dlCreationObj.smtp_address
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
