function SendParsedResponse() {
  # parses overall process status and sends response
  param($FunctionName, $MySbusMsg, $RequestType, $StatusObj)
  $responseHeader = @{
    'requestState' = $StatusObj.status
    'requestType'  = $RequestType
  }

  $processingStatus = @{
    "functionName"     = $FunctionName
    "statusCode"       = $StatusObj.statusCode
    "status"           = $StatusObj.status
    "timestamp"        = $(Get-Date)
    "response_message" = $StatusObj.message
  }

  $MySbusMsg.processingStatus += $processingStatus

  Get-Pocus
  
  $responseBody = ConvertTo-Json $MySbusMsg
  # using Modules/sendResponse function to send message back to topic
  sendResponse $responseHeader $responseBody
}