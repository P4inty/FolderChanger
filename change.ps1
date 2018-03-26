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
$SourceDir = 'A:\Programms\...'
#Define the Target (the changeable) Folder Path
$TargetDir = 'A:\Programms\...\Destination'

#Output Variables (Change if you need to)
$UserPromt = "Which Folder do you want to load? (id)"
$IdDivider = ". "
$InvalidInputMessage = "[Illegal Argument]The input must be a number between 0 and "
$SuccessMessageChange = "[Success]Folders successfully switched!"
$SuccessMessageGenerate = "[Sucess]Settings created: "
$EndMessage = "Press Enter to quit"

<#-----Class-----#>

Class ChangeFolder{

    #Directorys
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
            Write-Host ($This.GetChangeSuccess()) -ForegroundColor green
        }
        Read-Host -Prompt $This.GetEnd() 
    }

    [void]GenerateSettings(){
        $Folders = $This.GetFolders()
        $Counter = 0
        $SourceDir = $This.GetSource()
	    for($i=0; $i -lt $Folders.length; $i++) {
		    $ActiveFolder = $Folders[$i]
		    if(-not (Test-Path $SourceDir/$ActiveFolder/settings.txt)){
			    New-Item $SourceDir/$ActiveFolder/settings.txt -type file
			    "name=" + $ActiveFolder | Set-Content $SourceDir/$ActiveFolder/settings.txt
                $Counter++
		    }
	    }
        if($Counter -ne 0){
            Write-Host ($This.GetSettingsSuccess() + $Counter) -ForegroundColor green
        }
    }

    [array]GetFolders(){
        cd $This.GetSource()
        return dir
    }

    [void]PrintFolders(){
        $Folders = $This.GetFolders()
        for($i=0; $i -lt $Folders.length; $i++){
            Write-Host ([string]$i + $This.GetDivider() + $Folders[$i]) -ForegroundColor cyan
        }
    }

    [string]GetInput(){
        $Input        
        $Count = 0
        do {
            $Input = Read-Host $This.GetPrompt()
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
		   Write-Host ($This.GetError() + [string]($Folder.length - 1)) -ForegroundColor red
            $IsValid = $False
	    }
        return $IsValid
    }

    [boolean]SwitchFolder(){
        $Input = [string]$This.GetInput()
        $Success = $False
        $FirstSwitch = $False
        $SecondSwitch = $False
        $SourceDir = $This.GetSource()
        $TargetDir = $This.GetTarget()
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

    #Getter
    [string]GetSource(){
        return $This.Source
    }
    [string]GetTarget(){
        return $This.Target
    }
    [string]GetPrompt(){
        return $This.Prompt
    }
    [string]GetDivider(){
        return $This.Divider
    }
    [string]GetError(){
        return $This.Error
    }
    [string]GetChangeSuccess(){
        return $This.ChangeSuccess
    }
    [string]GetSettingsSuccess(){
        return $This.SettingsSuccess
    }
    [string]GetEnd(){
        return $This.End
    }
}

$default = [ChangeFolder]::new()
$default.Main()