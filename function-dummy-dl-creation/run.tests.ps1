BeforeAll {
  . $PSScriptRoot/run.ps1
  New-Module -Name DummyModule -ScriptBlock {
    function Get-AzKeyVaultSecret () {}
    function Connect-AzAccount () {}
    function Connect-ExchangeOnline () {}
    function Get-DistributionGroup () {}
    function Get-EXORecipient () {}
    function New-DistributionGroup () {}
    function Disconnect-ExchangeOnline () {}
    function Disconnect-AzAccount () {}
    function SendParsedResponse () {}
    function ConnectToExchange () {}
  } | Import-Module
}

Describe "SetDlCreationObj" {
  Context "Context: 1" {
    BeforeAll {
      Mock Write-Output
      SetDlCreationObj
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Write-Output -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "SetStatusObject" {
  Context "Context: 1" {
    BeforeAll {
      Mock Write-Output
      SetStatusObject "dummy_status" "dummy_status_code" "dummy_message"
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Write-Output -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "SetupConnection" {
  Context "Context: 1" {
    BeforeAll {
      Mock Connect-AzAccount
      Mock SetStatusObject
    }
    It "Test Case: 1" {
      Mock ConnectToExchange { }

      # execute function
      SetupConnection
      Should -Invoke -CommandName ConnectToExchange -Exactly -Times 1 -Scope Context
    }
    It "Test Case: 2" {
      Mock ConnectToExchange { throw "dummy error" }

      # execute function
      SetupConnection
      Should -Invoke -CommandName SetStatusObject -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "IsUniqueDL" {
  Context "Context: 1" {
    BeforeAll {
      Mock SetStatusObject
      Mock Write-Host
    }
    It "Test Case: 1" {
      Mock Get-DistributionGroup { return "not empty" }
      IsUniqueDL
      Should -Invoke -CommandName Get-DistributionGroup -Exactly -Times 1 -Scope Context
    }
    It "Test Case: 2" {
      Mock Get-DistributionGroup { throw "dummy_error" }
      IsUniqueDL
      Should -Invoke -CommandName Write-Host -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "FindOwners" {
  Context "Context: 1" {
    BeforeAll {
      Mock SetStatusObject
      Mock Write-Host
    }
    It "Test Case: 1" {
      Mock Get-EXORecipient { return "" }
      FindOwners
      Should -Invoke -CommandName Get-EXORecipient -Exactly -Times 2 -Scope Context
    }
    It "Test Case: 2" {
      Mock Get-EXORecipient { throw "dummy_error" }
      FindOwners
      Should -Invoke -CommandName Write-Host -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "CreateDL" {
  Context "Context: 1" {
    BeforeAll {
      Mock SetStatusObject
      Mock New-DistributionGroup { throw "dummy_error" }

      CreateDL
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName SetStatusObject -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "TerminateConnection" {
  Context "Context: 1" {
    BeforeAll {
      Mock Disconnect-ExchangeOnline
      Mock Disconnect-AzAccount { throw "dummy_error" }
      Mock Write-Host

      TerminateConnection
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Write-Host -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "Main" {
  Context "Context: 1" {
    BeforeAll {
      # mocking all the child functions
      Mock SetDlCreationObj
      Mock IsUniqueDL
      Mock FindOwners
      Mock SetupConnection
      Mock CreateDL
      Mock SendParsedResponse
      Mock TerminateConnection

      # executing main
      Main
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName SendParsedResponse -Exactly -Times 1 -Scope Context
    }
  }
}

AfterAll {
  Remove-Module DummyModule
}