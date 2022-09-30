BeforeAll {
  Import-Module -Name "$PSScriptRoot/sendResponse.psm1" -Force
  New-Module -Name DummyModule -ScriptBlock {
    function Connect-AzAccount () {}
    function Invoke-WebRequest () {}
  } | Import-Module
}

# Describe "sendResponse" {
#   Context "Context: 1" {
#     BeforeAll {
#       Mock -ModuleName sendResponse Connect-AzAccount {}
#       Mock New-Object {}
#       Mock -ModuleName sendResponse Write-Host {}
#     }
#     It "Test Case: 1" {
#       $ENV:MESSAGE_URL = "dummy_url"
#       Mock -ModuleName sendResponse Invoke-WebRequest {}
#       sendResponse -header @{"dummy_header" = "header" } -body @{"dummy_body" = "body" }
#       Should -Invoke Invoke-WebRequest -ModuleName sendResponse -Times 1 -Scope Context
#     }
#     It "Test Case: 2" {
#       $ENV:MESSAGE_URL = $null
#       sendResponse -header @{"dummy_header" = "header" } -body @{"dummy_body" = "body" }
#       Should -Invoke Write-Host -ModuleName sendResponse -Times 1 -Scope Context
#     }
#     It "Test Case: 3" {
#       $ENV:MESSAGE_URL = "dummy_url"
#       Mock -ModuleName sendResponse Invoke-WebRequest { throw "dummy_error" }
#       sendResponse -header @{"dummy_header" = "header" } -body @{"dummy_body" = "body" }
#       Should -Invoke Invoke-WebRequest -ModuleName sendResponse -Times 1 -Scope Context
#     }
#   }
# }

AfterAll {
  Remove-Module DummyModule
}