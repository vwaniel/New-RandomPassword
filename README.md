# New-RandomPassword
Are you wary of browser-based password generators?  Ever wish you could quickly generate secure passwords, even when offline?  New-RandomPassword is the solution, offering a highly customizable way to quickly generate secure passwords, even while offline.  Plus, as a script, the code can be easily audited for vulnerabilities.

## Features
- CLI or GUI (Windows Forms)
- Generate multiple passwords at once
- Minimum and optional maximum password length (to randomize password length)
- Selectable character classes (upper/lowercase, numeric, special) with the ability to include or exclude similar characters (such as "l" and "1").
- Selectable option to verify that the password contains at least one character from every selected character class
- Selectable option to avoid repeat characters
- Option to include NATO phonetic output of each character in the password (handy if the password is going to be printed out for safekeeping), and to color code each character class (GUI only)

## Loading into PowerShell
PS:> Import-Module .\New-RandomPassword.ps1

## Usage
### Built-In Help
PS:> Get-Help New-RandomPassword -Full
### GUI
PS:> New-RandomPassword -GUI

![image](https://github.com/vwaniel/New-RandomPassword/assets/62962179/98221720-2dab-4bd1-bd75-fb90d5ff29c7)

![image](https://github.com/vwaniel/New-RandomPassword/assets/62962179/1324a58e-762f-4f61-8a18-e7b67d22844f)
