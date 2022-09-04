BeforeAll {
  Import-Module -Name "$PSScriptRoot/SendParsedResponse.psm1" -Force
  Import-Module -Name "$PSScriptRoot/../sendResponse/sendResponse.psm1" -Force
}

Describe "Test: dummy" {
  Context "dummy context" {
    BeforeAll {
      Mock -ModuleName SendParsedResponse sendResponse {}
      $result=SendParsedResponse "dummy" @{"processingStatus" = @{"key" = "value" } } "dummy" "dummy"
    }
    It "Test Case: dummy" {
      Should -Invoke sendResponse -ModuleName SendParsedResponse -Times 1 -Scope Context
    }
  }
}