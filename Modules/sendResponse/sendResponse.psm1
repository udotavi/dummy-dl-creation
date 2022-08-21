function sendResponse {
  param($header)
  Write-Host "Inside Modules/sendResponse function.."
  ConvertTo-Json $header | Write-Host
}