BeforeAll {
  Import-Module -Name "$PSScriptRoot/GetVaultSecret.psm1" -Force
  New-Module -Name DummyModule -ScriptBlock {
    function Get-AzKeyVaultSecret () {}
  } | Import-Module
}

Describe "GetVaultSecret" {
  Context "Context: 1" {
    BeforeAll {
      $ENV:key_vault_name = "dummy_key_vault_name"
      Mock -ModuleName GetVaultSecret Get-AzKeyVaultSecret { return "dummy_secret_value" }
      $returnValue = GetVaultSecret "dummy_secret_name"
    }
    It "Test Case: 1" {
      Should -Invoke Get-AzKeyVaultSecret -ModuleName GetVaultSecret -Times 1 -Scope Context
    }
    It "Test Case: 2" {
      $returnValue | Should -Be "dummy_secret_value"
    }
  }
}

AfterAll {
  Remove-Module DummyModule
}