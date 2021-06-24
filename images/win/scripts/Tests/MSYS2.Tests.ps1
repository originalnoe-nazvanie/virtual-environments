$toolsetContent = (Get-ToolsetContent).MsysPackages
$archs = $toolsetContent.mingw.arch

BeforeAll {
    $msys2Dir = "C:\msys64\usr\bin"
    $originalPath = $env:PATH
}

Describe "MSYS2 packages" {
    BeforeEach {
        $env:PATH = "$msys2Dir;$env:PATH"
    }

    It "msys2Dir exists" {
        $msys2Dir | Should -Exist
    }

    $TestCases = @(
        @{ ToolName = "bash.exe" }
        @{ ToolName = "tar.exe" }
        @{ ToolName = "make.exe" }
    )

    It "<ToolName> is installed in <msys2Dir>" -TestCases $TestCases {
        (Get-Command "$ToolName").Source | Should -BeLike "$msys2Dir*"
    }

    It "<ToolName> is avaialable" -TestCases $TestCases {
        "$ToolName" | Should -ReturnZeroExitCodeWithParam
    }

    AfterEach {
        $env:PATH = $originalPath
    }
}

$mingwTypes = (Get-ToolsetContent).MsysPackages.mingw
foreach ($type in $mingwTypes) {
    Describe "$($type.arch) packages" {
        $tools = $type.runtime_packages
        $execDir = "C:\msys64\" + $type.exec_dir + "\bin"
        
        foreach ($tool in $tools) {
            Context "$($tool.name) package"{
                $executables = $tool.executables | ForEach-Object {
                    @{
                        ExecName = $_
                        ExecDir = $execDir
                    }
                }

                BeforeEach {
                    $env:PATH = "$ExecDir;$env:PATH"
                }

                It "<ExecName> is installed in <ExecDir>" -TestCases $executables {
                    (Get-Command "$ExecName").Source | Should -BeLike "$ExecDir*"
                }

                It "<ExecName> is available" -TestCases $executables {
                    "$ExecName" | Should -ReturnZeroExitCodeWithParam
                }

                AfterEach {
                    $env:PATH = $originalPath
                }
            }
        }
    }
}