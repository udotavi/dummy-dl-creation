BeforeAll {
  Import-Module -Name "$PSScriptRoot/ConnectToExchange.psm1" -Force
  New-Module -Name DummyModule -ScriptBlock {
    function GetVaultSecret () {}
    function New-Object () {}
    function Connect-ExchangeOnline () {}
  } | Import-Module
}

Describe "ConnectToExchange" {
  Context "Context: 1" {
    BeforeAll {
      # using a dummy base64 string
      $ENV:app_certificate_name = "dummy_certificate_name"
      Mock -ModuleName ConnectToExchange GetVaultSecret { return "eL78WIArGQ7bC44Ozr0yvUBkz9oc5YlsENYJilInSP==" }
      Mock New-Object { return "dummy" }
      Mock -ModuleName ConnectToExchange Connect-ExchangeOnline { return "dummy_secret_value" }
    }
    It "Test Case: 1" {
      ConnectToExchange -appId "dummy_app_id" -organization "dummy_org_name" -vaultCertificateName "dummy_cert_name"
      Should -Invoke Connect-ExchangeOnline -ModuleName ConnectToExchange -Times 1 -Scope Context
    }
  }
}

AfterAll {
  Remove-Module DummyModule
}