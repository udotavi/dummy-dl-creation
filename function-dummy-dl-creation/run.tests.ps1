BeforeAll {
  . $PSScriptRoot/run.ps1
}

Describe "Test: setDlCreationObj" {
  Context "Happy Path" {
    BeforeEach {
      $mySbMsg = @{
        "requestDetails" = @{
          "dl_name" = "dummy_{dl}_name"
        }
      }
    }
    It "Test Case: 1" {
      setDlCreationObj
      $dlCreationObj.name | Should -Be "^dummy_dl_name"
    }
  }
}

Describe "Test: setStatusObject" {
  Context "Happy Path" {
    BeforeEach {
    }
    It "Test Case: 1" {
      setStatusObject -status "Error"
      $statusObject.status | Should -Be "Error"
    }
  }
}

Describe "Test: ConnectionSetup" {
  Context "Happy Path" {
    BeforeEach {
      # Mock Connect-ExchangeOnline
      Mock Write-Host
    }
    It "Test Case: 1" {
      ConnectionSetup
      Should -Invoke -CommandName Write-Host -Exactly -Times 1
    }
  }

  Context "Unhappy Path" {
    BeforeEach {
      Mock Write-Host { Throw 'Dummy Error' }
      Mock setStatusObject
    }
    It "Test Case: 1" {
      ConnectionSetup
      Should -Invoke -CommandName setStatusObject -Exactly -Times 1
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
      CreateDL
      Should -Invoke -CommandName setDlCreationObj -Exactly -Times 1
    }
  }

  Context "Unhappy Path" {
    BeforeEach {
      Mock setDlCreationObj { Throw 'Dummy Error' }
      Mock setStatusObject
    }
    It "Test Case: 1" {
      CreateDL
      Should -Invoke -CommandName setStatusObject -Exactly -Times 1
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
      RespondWithStatus
      Should -Invoke -CommandName sendResponse -Exactly -Times 1
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
      main
      Should -Invoke -CommandName ConnectionSetup -Exactly -Times 1
    }
  }
}