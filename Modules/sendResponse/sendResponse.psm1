function sendResponse {
  param($header)
  Write-Host "Header is: "
  ConvertTo-Json $header | Write-Host
}