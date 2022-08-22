BeforeAll {
  . $PSScriptRoot/run.ps1
}

Describe "Test: setDlCreationObj" {
  Context "Happy Path" {
    BeforeEach {
    }
    It "Test Case: 1" {
      setDlCreationObj | Should -Be $true
    }
  }
}

Describe "Test: setStatusObject" {
  Context "Happy Path" {
    BeforeEach {
    }
    It "Test Case: 1" {
      setStatusObject | Should -Be $true
    }
  }
}

Describe "Test: ConnectionSetup" {
  Context "Happy Path" {
    BeforeEach {
      # Mock Connect-ExchangeOnline
      Mock setStatusObject
    }
    It "Test Case: 1" {
      ConnectionSetup | Should -Be $true
    }
  }

  Context "Unhappy Path" {
    BeforeEach {
      Mock Write-Host { Throw 'Dummy Error' }
      Mock setStatusObject
    }
    It "Test Case: 1" {
      ConnectionSetup | Should -Be $false
    }
  }
}

Describe "Test: CreateDL" {
  Context "Happy Path" {
    BeforeEach {
      # Mock New-DistributionGroup
      Mock setDlCreationObj
    }
    It "Test Case: 1" {
      CreateDL | Should -Be $true
    }
  }

  Context "Unhappy Path" {
    BeforeEach {
      Mock setDlCreationObj { Throw 'Dummy Error' }
      Mock setStatusObject
    }
    It "Test Case: 1" {
      CreateDL | Should -Be $false
    }
  }
}

Describe "Test: RespondWithStatus" {
  Context "Happy Path" {
    BeforeEach {
      function sendResponse() {
        # dummy function
      }
      Mock sendResponse
    }
    It "Test Case: 1" {
      RespondWithStatus | Should -Be $true
    }
  }
}

Describe "Test: Main Function" {
  Context "Context 1" {
    BeforeEach {
      Mock ConnectionSetup
      Mock CreateDL
      Mock RespondWithStatus
    }
    It "Test Case: 1" {
      main | Should -Be $true
    }
  }
}