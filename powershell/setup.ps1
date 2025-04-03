# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    return
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}

# Check for internet connectivity before proceeding
if (-not (Test-InternetConnection)) {
	return
}

if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
	try {
		$profilePath = ""

		if ($PSVersionTable.PSEdition -eq "Core") {
            		$profilePath = "$env:USERPROFILE\Documents\Powershell"
        	}
		elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            		$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell"
        	}

		if (!(Test-Path -Path $profilePath)) {
            		New-Item -Path $profilePath -ItemType "directory"
        	}

		Invoke-RestMethod https://github.com/thloc/dotfiles-window/raw/refs/heads/master/powershell/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
		Write-Host "The profile @ [$PROFILE] has been created."
	}
	catch {
		Write-Error "Failed to create or update the profile. Error: $_"
	}
}
else {
	 try {
        	Get-Item -Path $PROFILE | Move-Item -Destination "oldprofile.ps1" -Force
        	Invoke-RestMethod https://github.com/thloc/dotfiles-window/raw/refs/heads/master/powershell/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        	Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
        }
    	catch {
		Write-Error "Failed to backup and update the profile. Error: $_"
    	}
}

# Install Jabba
try {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Write-Host "Jabba not found, installing..."
    	Invoke-Expression (
        	Invoke-WebRequest https://github.com/shyiko/jabba/raw/master/install.ps1 -UseBasicParsing
    	).Content
}
catch {
	Write-Error "Failed to install Jabba. Error: $_"
}

if ((Test-Path -Path $PROFILE) -and (Test-Path -Path "$env:USERPROFILE\.jabba" -or (Get-Command jabba -ErrorAction SilentlyContinue))) {
    Write-Host "Setup completed successfully. Please restart your PowerShell session to apply changes."
} else {
    Write-Warning "Setup completed with errors. Please check the error messages above."
}


