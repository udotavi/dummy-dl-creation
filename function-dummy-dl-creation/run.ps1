<#
  .SYNOPSIS
  Short Description..

  .Description
  Creates a DL in Exchange 365
  19th Aug, 2022
  Under Development

  .EXAMPLE
  Some example..
  #!!!!!!!!!!!!!!!!!!!! replace the Write-Output with write-output
#>

param($mySbMsg, $TriggerMetadata)

# example mySbMsg ..
# {
#   "request_id": "REQ2123123",
#   "requestDetails":{
#       "dl_name": "dummy.DL@_13",
#       "owner1": "dummy_owner1",
#       "owner2": "dummy_owner2"
#   },
#   "processingStatus":[{
#       "key1": "value1"
#   }
#   ]
# }

$global:dlCreationObj = @{
  "name"         = ""
  "smtp_address" = ""
  "owners"       = ""
}

$global:StatusObject = @{
  status     = "Complete"
  statusCode = "200"
  message    = "Transaction Successful"
}

function SetDlCreationObj() {
  # helper function to update dlCreationObj
  $original_dl_string = $mySbMsg.requestDetails.dl_name
  # removing unwanted characters and extra spaces from dl name string
  $modified_dl_string = $original_dl_string -replace "[^a-zA-Z0-9 .\-_']", "" -replace "\s+", " "

  $global:dlCreationObj.name = "^" + $modified_dl_string
  # ?? what should be the mail domain value ??
  $global:dlCreationObj.smtp_address = ($modified_dl_string -replace "\s+", "") + "@example.com"
  $global:dlCreationObj.owners = $mySbMsg.requestDetails.owner1 + "," + $mySbMsg.requestDetails.owner2

  Write-Output "DL Name: $($global:dlCreationObj.name) , SMTP Address: $($global:dlCreationObj.smtp_address) , Owners: $($global:dlCreationObj.owners)"
}

function SetStatusObject() {
  # helper function to update StatusObject
  param($status, $statusCode, $message)

  # Write-Output "$status : $statusCode - $message"
  $global:StatusObject.status = $status
  $global:StatusObject.statusCode = $statusCode
  $global:StatusObject.message += $message + "."

  Write-Output $global:StatusObject
}

function SetupConnection() {
  # setup the connection to exchange
  try {
    Write-Output "Trying to setup connection to AzAccount.."
    Connect-AzAccount -Identity

    $vaultCertificateName = $ENV:app_certificate_name # need to change the env var name
    # connecting to exchange online
    ConnectToExchange -appId "dummy_app_id" -organization "dummy_org" -vaultCertificateName $vaultCertificateName
  }
  catch {
    Write-Host "$_"
    SetStatusObject -status "Error" -statusCode "400" -message "Cound not setup connection: $_"
  }
}

function IsUniqueDL() {
  try {
    # checks if the dl already exists
    $dlUnique = Get-DistributionGroup -Filter "DisplayName -eq '$($global:dlCreationObj.name)'"
    if ($dlUnique -ne "") {
      SetStatusObject -status "Error" -statusCode "400" -message "DL name - $($global:dlCreationObj.name) already exists"
    }
  }
  catch {
    Write-Host "Exception Occured in IsUniqueDL function. $_"
    SetStatusObject -status "Error" -statusCode "400" -message "Exception Occured in IsUniqueDL function. $_"
  }
}

function FindOwners() {
  try {
    # checks if the dl already exists
    $owner1 = Get-EXORecipient -Filter "DisplayName -eq '$($mySbMsg.requestDetails.owner1)'"
    $owner2 = Get-EXORecipient -Filter "DisplayName -eq '$($mySbMsg.requestDetails.owner2)'"
    
    if ($owner1 -eq "") {
      SetStatusObject -status "Error" -statusCode "400" -message "Owner - $($mySbMsg.requestDetails.owner1) not found"
    }

    if ($owner2 -eq "") {
      SetStatusObject -status "Error" -statusCode "400" -message "Owner - $($mySbMsg.requestDetails.owner2) not found"
    }
  }
  catch {
    Write-Host "Exception Occured in FindOwners function. $_"
    SetStatusObject -status "Error" -statusCode "400" -message "Exception Occured in FindOwners function. $_"
  }
}

function CreateDL() {
  # creates a new distribution list
  try {
    Write-Output "Trying to create the DL.."
    New-DistributionGroup -Name $global:dlCreationObj.name `
      -ManagedBy $global:dlCreationObj.owners `
      -PrimarySmtpAddress $global:dlCreationObj.smtp_address
  }
  catch {
    Write-Host "$_"
    SetStatusObject -status "Error" -statusCode "400" -message "Error during the DL creation: $_"
  }
}

function TerminateConnection() {
  # closes the connections with Az and Exchange
  try {
    Disconnect-ExchangeOnline -Confirm:$false
    Disconnect-AzAccount -Confirm:$false
  }
  catch {
    Write-Host "$_"
  }
}

function Main() {
  Write-Output "Process Started - $(Get-Date)"

  # updating dl creation obj from sbus message body
  SetDlCreationObj

  # tries to setup all the connections
  SetupConnection

  if ($StatusObject.status -ne "Error") { 
    # checks if the DL is unique
    IsUniqueDL
    # checks is the owners can be found
    FindOwners
  }

  # dl creation
  if ($StatusObject.status -ne "Error") { CreateDL }

  # parses execution status/message and sends response
  $requestType = "dummy_req_type"
  # sourcing SendParseResponse from Modules
  SendParsedResponse -FunctionName $TriggerMetadata.functionName `
    -MySbusMsg $mySbMsg `
    -RequestType $requestType `
    -StatusObj $StatusObject

  # terminates the Az, Exchange connections
  TerminateConnection

  Write-Output "Process Completed - $(Get-Date)"
}

if ($MyInvocation.InvocationName -ne '.') {
  Main
}

#end
