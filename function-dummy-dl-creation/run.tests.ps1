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

Describe "GetFromVault" {
  Context "Context: 1" {
    BeforeAll {
      $ENV:key_vault_name = "dummy_key_vault_name"
      Mock Get-AzKeyVaultSecret { return "secret_value" }
    }
    It "Test Case: 1" {
      $returnValue = GetFromVault "dummy_secret_name"
      Should -Invoke -CommandName Get-AzKeyVaultSecret -Exactly -Times 1 -Scope Context
      $returnValue | Should -Be "secret_value"
    }
  }
}

Describe "SetupConnection" {
  Context "Context: 1" {
    BeforeAll {
      Mock Connect-AzAccount
      # using a dummy base64 string
      Mock GetFromVault { return "eL78WIArGQ7bC44Ozr0yvUBkz9oc5YlsENYJilInSP==" }
      Mock New-Object
      Mock Connect-ExchangeOnline { throw "dummy_error" }
      Mock SetStatusObject

      SetupConnection
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName SetStatusObject -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "IsUniqueDL" {
  Context "Context: 1" {
    BeforeAll {
      Mock Get-DistributionGroup { return "not empty" }
      Mock SetStatusObject

      IsUniqueDL
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Get-DistributionGroup -Exactly -Times 1 -Scope Context
    }
  }
}

Describe "FindOwners" {
  Context "Context: 1" {
    BeforeAll {
      Mock SetStatusObject
      Mock Get-EXORecipient { return "" }
      FindOwners
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Get-EXORecipient -Exactly -Times 2 -Scope Context
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
      Mock Write-Error

      TerminateConnection
    }
    It "Test Case: 1" {
      Should -Invoke -CommandName Write-Error -Exactly -Times 1 -Scope Context
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