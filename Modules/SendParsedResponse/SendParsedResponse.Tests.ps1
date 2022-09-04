BeforeAll {
  Import-Module -Name "$PSScriptRoot/SendParsedResponse.psm1" -Force
  Import-Module -Name "$PSScriptRoot/../sendResponse/sendResponse.psm1" -Force
}

Describe "SendParsedResponse" {
  Context "Context: 1" {
    BeforeAll {
      Mock -ModuleName SendParsedResponse sendResponse {}
      $result=SendParsedResponse "dummy" @{"processingStatus" = @{"key" = "value" } } "dummy" "dummy"
    }
    It "Test Case: 1" {
      Should -Invoke sendResponse -ModuleName SendParsedResponse -Times 1 -Scope Context
    }
  }
}