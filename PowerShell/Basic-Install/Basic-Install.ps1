Write-Host "### Basic-Install.ps1 ###"
# Placeholders
$defaultversion = "21H1"
# Take in parameter for OS
$param1=$args[0]

# Choose OS
#Write-Host ('Requested: ' + $param1)
If($param1){
	Write-Host('Requested version: ' + $param1)
	$version = $param1
}else{
	Write-Host('Using default version: ' + $defaultversion)
	$version = $defaultversion
}
#Write-Host ('Version: ' + $version)

# Find USB
$drives = @('c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v')
foreach($drive in $drives){
	if(Test-Path -path ($drive + ":\Basic-Install.ps1")){
		#Write-Host ("USB: " + $drive + ':')
		$usbdrive = $drive
		break
	}
}
If (!$usbdrive) {
	Write-Host ("Cannot find USB drive")
	return
}
Write-Host ("USB: " + $usbdrive + ':')

# Check for driver pack
$computersystem = Get-WMIObject Win32_ComputerSystem
Write-Host ("Model: " + $computersystem.Model)
If(Test-Path -path ($usbdrive + ":\Drivers\" + $computersystem.Model)){
	$driverpath = ($usbdrive + ":\Drivers\" + $computersystem.Model)
	Write-Host ("Driver pack: " + $driverpath)
}

# Run setup.exe
# with noreboot if driver pack found
# Check for setup.exe
$setuppath = ($usbdrive + ":\" + $version + "\setup.exe")
If (Test-Path -path $setuppath){
	Write-Host ("Windows setup path: " + $setuppath)
}else{
	Write-Host ("Could not find " + $setuppath)
	return
}
If ($driverpath){
	$setupcmd = ($setuppath + " /noreboot")
}else{
	$setupcmd = $setuppath
}
Write-Host ("Windows setup command: " + $setupcmd)
start-process 'cmd' -wait -argument ('/c ' + $setupcmd)

# Find OS drive letter
foreach($drive in $drives){
	if(Test-Path -path ($drive + ":\Windows\explorer.exe")){
		Write-Host ("Windows drive: " + $drive + ':')
		$windowsdrive = $drive
		break
	}
}
# re-check for driver pack

# DISM in drivers
$dismcommand = ('dism.exe /image:' + $windowsdrive + ': /add-driver /driver:"' + $driverpath + '" /recurse')

Write-Host ("dism command: " + $dismcommand)
start-process 'cmd' -wait -argument ('/c ' + $dismcommand)

# End
Write-Host "End"
