BeforeAll {
  Import-Module -Name "$PSScriptRoot/SendParsedResponse.psm1" -Force
  New-Module -Name DummyModule -ScriptBlock {
    function sendResponse () {
      return 0
    }
  } | Import-Module
}

Describe "SendParsedResponse" {
  Context "Context: 1" {
    BeforeAll {
      Mock -ModuleName SendParsedResponse sendResponse {}
      SendParsedResponse "dummy" @{"processingStatus" = @{"key" = "value" } } "dummy" "dummy"
    }
    It "Test Case: 1" {
      Should -Invoke sendResponse -ModuleName SendParsedResponse -Times 1 -Scope Context
    }
  }
}

AfterAll {
  Remove-Module DummyModule
}