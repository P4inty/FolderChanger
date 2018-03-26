# changeFolder
<#
.SYNOPSIS
    A script to change folders between a source folder and a destination folder.
.DESCRIPTION
    This script is designed to switch out the contents of a defined folder with the contents
    of one folder, that is inside a source folder.
    The source folder can nest other folders which will be used to switch the content.
    You can choose which folder you want to switch to by enter the id of the folder when prompted.
.NOTES
    File Name  : ChangeFolder.ps1
    Version    : 2.0
    Date       : 26/03/2018
    Author     : Martin Wundsam - martin.wundsam@gmail.com
    Created on : PSVersion 5.1.16299.248, PSEdition Desktop

.EXAMPLE
    0. FolderOne
    1. FolderTwo
    2. FolderThree

    => Which folder do you want to use?: 1
#>
<#-----Variables-----#>

#Define the Source Folder Path
$SourceDir = 'A:\Programms\Software\...\Source'
#Define the Target (the changeable) Folder Path
$TargetDir = 'A:\Programms\Software\...\Target'

#Output Variables (Change if you need to)
$UserPromt = "Which Folder do you want to load? (id)"
$IdDivider = ". "
$InvalidInputMessage = "[Illegal Argument]The input must be a number between 0 and "
$SuccessMessageChange = "[Success]Folders successfully switched!"
$SuccessMessageGenerate = "[Success]Settings created: "
$EndMessage = "Press Enter to quit"

<#-----Class-----#>

Class ChangeFolder{

    #Directory's
    [string]$Source = $SourceDir
    [string]$Target = $TargetDir

    #Output
    [string]$Prompt = $UserPromt
    [string]$Divider = $IdDivider
    [string]$Error = $InvalidInputMessage
    [string]$ChangeSuccess = $SuccessMessageChange
    [string]$SettingsSuccess = $SuccessMessageGenerate
    [string]$End = $EndMessage

    #Methods
    [void]Main(){
        $This.GenerateSettings()
        $This.PrintFolders()
        $Success = $This.SwitchFolder()
        if($Success){
            Write-Host ($This.ChangeSuccess) -ForegroundColor green
        }
        Read-Host -Prompt $This.End 
    }

    [void]GenerateSettings(){
        $Folders = $This.GetFolders()
        $Counter = 0
        $SourceDir = $This.Source
	    for($i=0; $i -lt $Folders.length; $i++) {
		    $ActiveFolder = $Folders[$i]
		    if(-not (Test-Path $SourceDir/$ActiveFolder/settings.txt)){
			    New-Item $SourceDir/$ActiveFolder/settings.txt -type file
			    "name=" + $ActiveFolder | Set-Content $SourceDir/$ActiveFolder/settings.txt
                $Counter++
		    }
	    }
        if($Counter -ne 0){
            Write-Host ($This.SettingsSuccess + $Counter) -ForegroundColor green
        }
    }

    [array]GetFolders(){
        cd $This.Source
        return dir
    }

    [void]PrintFolders(){
        $Folders = $This.GetFolders()
        for($i=0; $i -lt $Folders.length; $i++){
            Write-Host ([string]$i + $This.Divider + $Folders[$i]) -ForegroundColor cyan
        }
    }

    [string]GetInput(){
        $Input        
        $Count = 0
        do {
            $Input = Read-Host $This.Prompt
            if($This.IsValid($Input)){
                $Count = 3
            }
            else{
                $Count++
            }
        }while($Count -lt 3)
        return $Input
    }

    [boolean]IsValid($Input){
        $IsValid = $True
        $Folder = $This.GetFolders()
	    if($Input -notmatch "^[0-9]*$" -or $Input -gt $Folder.length - 1 -or $Input -lt 0 -or !$Input){
           [console]::ForegroundColor="red"; $_;
		   Write-Host ($This.Error + [string]($Folder.length - 1)) -ForegroundColor red
            $IsValid = $False
	    }
        return $IsValid
    }

    [boolean]SwitchFolder(){
        $Input = [string]$This.GetInput()
        $Success = $False
        $FirstSwitch = $False
        $SecondSwitch = $False
        $SourceDir = $This.Source
        $TargetDir = $This.Target
        if(Test-Path -Path $TargetDir){
		    $Name = (Select-String -Path $TargetDir/settings.txt -Pattern "name=(.*)").Matches.Groups[1].Value
		    Ren $TargetDir $Name
		    $Folder = $This.GetFolders()
		    $SecondSwitch = $This.MoveRename($TargetDir)
		    cd $TargetDir/..		
		    move $Name $SourceDir
		    $FirstSwitch = $True
	    }
        else {
            $SecondSwitch = $This.MoveRename($TargetDir) 
            $FirstSwitch = $True
        }
        if($FirstSwitch -and $SecondSwitch){
            $Success = $True
        }
        return $Success
    }

    [boolean]MoveRename($TargetDir){
        $Success = $False
        $Folder = $This.GetFolders()
        if(Test-Path -Path $Folder[$Input]){
			$NewFolder = $Folder[$Input]
			Move $NewFolder $TargetDir/..
	        Ren ../$NewFolder ($TargetDir|Split-Path -leaf)
            $Success = $True
                
		}
        return $Success
    }

}

$default = [ChangeFolder]::new()
$default.Main()