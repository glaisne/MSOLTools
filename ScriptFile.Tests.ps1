[CmdletBinding()]
PARAM (
    $ModuleName = "MSOLTools",
    $GithubRepository = "github.com/glaisne/"
)

# Make sure one or multiple versions of the module are note loaded
Get-Module -Name $ModuleName | remove-module

# Find the Manifest file
$ManifestFile = "$(Split-path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition))\$ModuleName\$ModuleName.psd1"

# Import the module and store the information about the module
$ModuleInformation = Import-module -Name $ManifestFile -PassThru

# Get the functions present in the Manifest
$ExportedFunctions = $ModuleInformation.ExportedFunctions.Values.name

write-host 'test'

# Testing the Module
Describe "$ModuleName Module - Tokenize" -Tags "Module" {
    FOREACH ($funct in $ExportedFunctions)
    {
        $FunctionContent = Get-Content function:$funct
        $Tokenized = [System.Management.Automation.PSParser]::Tokenize($Functioncontent,[ref]$null)
        
        Context "$funct - CommandParameter"{
            Foreach ($Token in $Tokenized)
            {
                if ($Token.type -eq 'CommandParameter')
                {
                    it "CommandParameter - Capitalized ($($Token.Content))"{
                        if (-not ($Token.Content -cmatch '[A-Z]' | Should Be $true))
                        {
                            $Toke |fl
                        }
                    }
                }
            }
        } #Context

        
        
        Context "$funct - Variable"{
            Foreach ($Token in $Tokenized)
            {
                if ($Token.type -eq 'Variable')
                {
                    if ($($Token.Content) -eq '_')
                    {
                        Continue
                    }
                    it "Variable - Capitalized ($($Token.Content))"{
                        $Token.Content -cmatch '[A-Z].*' | Should Be $true
                    }
                }
            }
        } #Context
    } #FOREACH
} #Describe
