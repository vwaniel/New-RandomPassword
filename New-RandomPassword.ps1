function New-RandomPassword {
	<#
	.SYNOPSIS
		This script generates random passwords.
	.DESCRIPTION
		This script generates random passwords.  Password options include uppercase, lowercase, numbers, and special characters, as well as various options for generating and displaying the password.
	.PARAMETER MinimumLength
		This parameter sets the minimum password length.  If "-MaximumLength" is unspecified, the password will be the number of characters specified by "-MinimumLength" (default 20).
	.PARAMETER MaximumLength
		When used in conjunction with "-MinimumLength", this option allows the user to specify a range of possible password lengths in case a varying password length is desired.
	.PARAMETER Lower
		This parameter instructs the password generator to use lowercase characters.
	.PARAMETER Upper
		This parameter instructs the password generator to use uppercase characters.
	.PARAMETER Numeric
		This parameter instructs the password generator to use numbers.
	.PARAMETER Special
		This parameter instructs the password generator to use special characters.
	.PARAMETER AtLeastOne
		This parameter instructs the password generator to ensure that at least one character of each specified character class exists in the password.
	.PARAMETER NoSimilar
		This parameter restricts the available character classes (uppercase, lowercase, numeric, and special) to not use characters that are easily confused (such as 'l' and '1').
	.PARAMETER NATO
		This parameter prints the NATO phonetic spelling of the password to the screen in addition to the password itself.
	.PARAMETER NoRepeat
		This parameter instructs the password generator to check for repeating characters and to remove any repeats.
	.PARAMETER GUI
		This parameter launches a GUI which contains the same functionality as the command line.
	.EXAMPLE
		PS C:\> New-RandomPassword -Lower -Upper -Numeric
		Generates a new random password that can contain uppercase, lowercase, and numeric characters (but may not contain at least one character from each character class.)
	.EXAMPLE
		PS C:\> New-RandomPassword -Lower -Upper -Numeric -AtLeastOne
		Generates a new random password that will contain at least one uppercase, lowercase, and numeric character.
	.EXAMPLE
		PS C:\> New-RandomPassword -MinimumLength 10 -MaximumLength 20 -Lower -Upper -Numeric -AtLeastOne
		Generates a new random password between 10 and 20 characters in length that contains at least one lowercase, uppercase, and numeric character.
	.EXAMPLE
		PS C:\> New-RandomPassword -Lower -Upper -Numeric -AtLeastOne -NoSimilar
		Generates a new random password that will contain at least one uppercase, lowercase, and numeric character, excluding similar characters.
	.EXAMPLE
		PS C:\> New-RandomPassword -Lower -Upper -Numeric -AtLeastOne -NATO
		Generates a new random password that will contain at least one uppercase, lowercase, and numeric character.  Prints the NATO phonetic spelling of the password below the password for easy copy/paste/print.
	.EXAMPLE
		PS C:\> New-RandomPassword -Lower -Upper -Numeric -AtLeastOne -NoRepeat
		Generates a new random password that will contain at least one uppercase, lowercase, and numeric character.  The password will not contain any repeating characters.
	.EXAMPLE
		PS C:\> 1..100 | Foreach-Object {New-RandomPassword -Lower -Upper -Numeric -AtLeastOne}
		Generates 100 new random passwords that will contain at least one uppercase, lowercase, and numeric character.
	#>
	[cmdletbinding()]
	param(
		[Parameter(ParameterSetName="CLI",Mandatory=$false,Position=1)][int]$MinimumLength = 20,
		[Parameter(ParameterSetName="CLI",Mandatory=$false,Position=2)][int]$MaximumLength,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$Lower,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$Upper,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$Numeric,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$Special,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$AtLeastOne,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$NoSimilar,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$NATO,
		[Parameter(Mandatory=$false,ParameterSetName="CLI")][switch]$NoRepeat,
		[Parameter(Mandatory=$false,ParameterSetName="GUI")][switch]$GUI
	)
	
	if ($GUI) {
		Add-Type -AssemblyName System.Windows.Forms > $null
		[System.Windows.Forms.Application]::EnableVisualStyles() > $null
		
		# Main form.
		$Form = New-Object System.Windows.Forms.Form -Property @{
			"ClientSize" = '713,463'
			"Text" = "Password Generator v1.0"
			"TopMost" = $false
		}
		
		# Lowercase character class checkbox.
		$CheckBox1 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Character Class: Lower (a,b,c, ...z)"
			"AutoSize" = $false
			"Width" = 250
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,20))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $true
		}

		# Uppercase character class checkbox.
		$CheckBox2 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Character Class: Upper (A, B, C, ...Z)"
			"AutoSize" = $false
			"Width" = 250
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,45))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $true
		}

		# Numeric character class checkbox.
		$CheckBox3 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Character Class: Numeric (0,1,2, ... 9)"
			"AutoSize" = $false
			"Width" = 270
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,70))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $true
		}

		# Special character class checkbox.
		$CheckBox4 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Character Class: Special (!, @, #, $, ...)"
			"AutoSize" = $false
			"Width" = 270
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,95))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $true
		}

		# Exclude similar characters checkbox.
		$CheckBox5 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Exclude confusing (l, L, 1, !, O, 0, o)"
			"AutoSize" = $false
			"Width" = 300
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,120))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $false
		}

		# Enforce at least one of each character class checkbox.
		$CheckBox6 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Must be at least one of each character class checked above."
			"AutoSize" = $false
			"Width" = 350
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,145))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $true
		}

		# Do not allow repeating characters checkbox.
		$CheckBox7 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Do not allow repeating characters."
			"AutoSize" = $false
			"Width" = 350
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,170))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $false
		}
		
		# Include NATO phonetic spelling checkbox.
		$CheckBox8 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Include NATO phonetic spelling in output."
			"AutoSize" = $false
			"Width" = 350
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,195))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $false
		}
		
		$CheckBox9 = New-Object System.Windows.Forms.CheckBox -Property @{
			"Text" = "Colorize text output based on character type."
			"Autosize" = $false
			"Width" = 360
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(30,220))
			"Font" = 'Microsoft Sans Serif,10'
			"Checked" = $false
		}
		$CheckBox9.Add_CheckStateChanged({
			Colorize
		})
		
		function Colorize() {
			if ($CheckBox9.Checked -eq $false) {
				# Remove color from check boxes.
				$CheckBox1.ForeColor = "Black"
				$CheckBox2.ForeColor = "Black"
				$CheckBox3.ForeColor = "Black"
				$CheckBox4.ForeColor = "Black"
				# Remove text color.
				$i = 0
				while ($i -lt ($TextBox4RTF.TextLength - 1)) {
					$TextBox4RTF.SelectionStart = $i
					$TextBox4RTF.SelectionLength = 1
					$TextBox4RTF.SelectionColor = "Black"
					$i++
				}
				$TextBox4RTF.Visible = $false
				$TextBox4Plain.Visible = $true
			} else {
				$TextBox4RTF.Visible = $true
				$TextBox4Plain.Visible = $false
				# Add color to check boxes.
				$CheckBox1.ForeColor = "Black"
				$CheckBox2.ForeColor = "Black"
				$CheckBox3.ForeColor = "Red"
				$CheckBox4.ForeColor = "Blue"
				# Add text color.
				$i = 0
				while ($i -lt ($TextBox4RTF.TextLength - 1)) {
					$TextBox4RTF.SelectionStart = $i
					$TextBox4RTF.SelectionLength = 1
					switch -regex ($TextBox4RTF.SelectedText) {
						"(?-i)[a-z]" {$TextBox4RTF.SelectionColor = "Black";break}
						"(?-i)[A-Z]" {$TextBox4RTF.SelectionColor = "Black";break}
						"[0-9]" {$TextBox4RTF.SelectionColor = "Red";break}
						"[!@#%\^&\*\(\)]" {$TextBox4RTF.SelectionColor = "Blue";break}
					}
					$i++
				}
				# NATO output used, so need to identify individual lines.
				if ($TextBox4RTF.Text -match "----------------------") {
					$arrText = $TextBox4RTF.Text -split "\n"
					$arrText = $arrText | Foreach-Object {$_.ToString()}
					$i = 0
					foreach ($line in $arrText) {
						#$TextBox4.AppendText("Line: $($line)")
						switch -regex ($line) {
							"^(?-i)[A-Z]*$" {$TextBox4RTF.SelectionStart = $i; $TextBox4RTF.SelectionLength = $line.Length; $TextBox4RTF.SelectionColor = "Black"; break}
							"^(?-i)[a-z]*$" {$TextBox4RTF.SelectionStart = $i; $TextBox4RTF.SelectionLength = $line.Length; $TextBox4RTF.SelectionColor = "Black"; break}
							"^Number: .*" {$TextBox4RTF.SelectionStart = $i; $TextBox4RTF.SelectionLength = $line.Length; $TextBox4RTF.SelectionColor = "Red"; break}
							"^Special Character: .*" {$TextBox4RTF.SelectionStart = $i; $TextBox4RTF.SelectionLength = $line.Length; $TextBox4RTF.SelectionColor = "Blue"; break}
						}
						$i = $i + $line.Length + 1
					}
				}
			}
		}
		
		# Password length label.
		$Label1 = New-Object System.Windows.Forms.Label -Property @{
			"Text" = "Password Length:"
			"AutoSize" = $true
			"Width" = 25
			"Height" = 10
			"Location" = $(New-Object System.Drawing.Point(542,26))
			"Anchor" = 9
			"Font" = 'Microsoft Sans Serif,10'
		}

		# Minimum password length label.
		$Label2 = New-Object System.Windows.Forms.Label -Property @{
			"Text" = "Min:"
			"AutoSize" = $true
			"Width" = 25
			"Height" = 10
			"Location" = $(New-Object System.Drawing.Point(542,52))
			"Anchor" = 9
			"Font" = 'Microsoft Sans Serif,10'
		}

		# Maximum password length label.
		$Label3 = New-Object System.Windows.Forms.Label -Property @{
			"Text" = "Max:"
			"AutoSize" = $true
			"Width" = 25
			"Height" = 10
			"Location" = $(New-Object System.Drawing.Point(616,52))
			"Anchor" = 9
			"Font" = 'Microsoft Sans Serif,10'
		}

		# Mimimum password length textbox.
		$TextBox1 = New-Object System.Windows.Forms.TextBox -Property @{
			"Multiline" = $false
			"Width" = 30
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(574,48))
			"Anchor" = 9
			"Font" = 'Microsoft San Serif,10'
			"TextAlign" = 'Right'
			"Text" = 20
		}

		# Maximum password length textbox.
		$TextBox2 = New-Object System.Windows.Forms.TextBox -Property @{
			"Multiline" = $false
			"Width" = 30
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(651,48))
			"Anchor" = 9
			"Font" = 'Microsoft San Serif,10'
			"TextAlign" = 'Right'
		}

		# Number of passwords label.
		$Label4 = New-Object System.Windows.Forms.Label -Property @{
			"Text" = "Number of Passwords:"
			"AutoSize" = $true
			"Width" = 45
			"Height" = 10
			"Location" = $(New-Object System.Drawing.Point(504,92))
			"Anchor" = 9
			"Font" = 'Microsoft Sans Serif,10'
		}

		# Number of passwords textbox.
		$TextBox3 = New-Object System.Windows.Forms.TextBox -Property @{
			"Multiline" = $false
			"Width" = 30
			"Height" = 20
			"Location" = $(New-Object System.Drawing.Point(651,90))
			"Anchor" = 9
			"Font" = 'Microsoft San Serif,10'
			"TextAlign" = 'Right'
			"TabStop" = $false
			"Text" = 1
		}

		# Generate button.
		$Button1 = New-Object System.Windows.Forms.Button -Property @{
			"Text" = "Generate"
			"Width" = 80
			"Height" = 30
			"Location" = $(New-Object System.Drawing.Point(511,207))
			"Anchor" = 9
			"Font" = 'Microsoft Sans Serif,10,style=Bold'
		}
		$Button1.Add_Click({
			$testhash = @{
				MinimumLength =		($TextBox1.Text)
				MaximumLength =		($TextBox2.Text)
				Lower =			($CheckBox1.Checked)
				Upper =			($CheckBox2.Checked)
				Numeric =		($CheckBox3.Checked)
				Special =		($CheckBox4.Checked)
				NoSimilar =		($CheckBox5.Checked)
				AtLeastOne =	($CheckBox6.Checked)
				NoRepeat =		($CheckBox7.Checked)
				NATO =		($CheckBox8.Checked)
		   }

			$TextBox4Plain.Text = ""
			$TextBox4RTF.Text = ""
			1..$TextBox3.Text | Foreach-Object {   
				$LineOfText = New-RandomPassword @testhash
				$TextBox4Plain.AppendText($LineOfText + "`r`n")
				$TextBox4RTF.AppendText($LineOfText + "`r`n")
			}
			
			Colorize
		})

		# Cancel button.
		$Button2 = New-Object System.Windows.Forms.Button -Property @{
			"Text" = "Cancel"
			"Width" = 80
			"Height" = 30
			"Location" = $(New-Object System.Drawing.Point(601,207))
			"Anchor" = 9
			"Font" = 'Microsoft Sans Serif,10,style=Bold'
		}
		$Button2.Add_Click({
			$Form.Close()
		})

		# Results textbox.
		$TextBox4Plain = New-Object System.Windows.Forms.TextBox -Property @{
			"Visible" = $true
			"Multiline" = $true
			"Width" = 654
			"Height" = 159
			"ScrollBars" = "Vertical"
			"Location" = $(New-Object System.Drawing.Point(29,270))
			"Anchor" = 15
			"Font" = 'Consolas,12'
			"WordWrap" = $false;
			"BorderStyle" = "none";
		}
		$TextBox4RTF = New-Object System.Windows.Forms.RichTextBox -Property @{
			"Visible" = $false
			"Multiline" = $true
			"AutoWordSelection" = $true
			"Width" = 654
			"Height" = 159
			"Location" = $(New-Object System.Drawing.Point(29,270))
			"Anchor" = 15
			"Font" = 'Consolas,12'
			"WordWrap" = $false;
			"ScrollBars" = "ForcedVertical";
			"BorderStyle" = "none";
		}

		# Add controls to form.
		$Form.Controls.AddRange(@($CheckBox1,$CheckBox2,$CheckBox3,$CheckBox4,$CheckBox5,$CheckBox6,$CheckBox7,$CheckBox8,$CheckBox9,$TextBox4Plain,$TextBox4RTF,$Label1,$Label2,$Label3,$Label4,$TextBox1,$TextBox2,$TextBox3,$Button1,$Button2)) > $null

		$Form.ShowDialog() > $null
	} else {
	
		if ($MinimumLength -lt 1) {
			throw "Minimum password length must be greater than zero."
		}
		
		if ($MaximumLength) {
			if ($MaximumLength -lt $MinimumLength) {
				throw "Maximum password length must be greater than minimum password length."
			}
		}
		
		if (-NOT $Lower -and -NOT $Upper -and -NOT $Numeric -and -NOT $Special) {
			throw "At least one character set (Upper, Lower, Numeric, Special) must be specified."
		}

		if ($MaximumLength) {
			$Length = Get-Random -Minimum $MinimumLength -Maximum $MaximumLength
		} else {
			$Length = $MinimumLength
		}
		
		# NATO phonetic lookup.
		$nato_lookup = New-Object System.Collections.Hashtable
		$nato_lookup.'a' = 'alpha'
		$nato_lookup.'b' = 'bravo'
		$nato_lookup.'c' = 'charlie'
		$nato_lookup.'d' = 'delta'
		$nato_lookup.'e' = 'echo'
		$nato_lookup.'f' = 'foxtrot'
		$nato_lookup.'g' = 'golf'
		$nato_lookup.'h' = 'hotel'
		$nato_lookup.'i' = 'india'
		$nato_lookup.'j' = 'juliet'
		$nato_lookup.'k' = 'kilo'
		$nato_lookup.'l' = 'lima'
		$nato_lookup.'m' = 'mike'
		$nato_lookup.'n' = 'november'
		$nato_lookup.'o' = 'oscar'
		$nato_lookup.'p' = 'papa'
		$nato_lookup.'q' = 'quebec'
		$nato_lookup.'r' = 'romeo'
		$nato_lookup.'s' = 'sierra'
		$nato_lookup.'t' = 'tango'
		$nato_lookup.'u' = 'uniform'
		$nato_lookup.'v' = 'victor'
		$nato_lookup.'w' = 'whiskey'
		$nato_lookup.'x' = 'x-ray'
		$nato_lookup.'y' = 'yankee'
		$nato_lookup.'z' = 'zulu'
		$nato_lookup.'A' = 'ALPHA'
		$nato_lookup.'B' = 'BRAVO'
		$nato_lookup.'C' = 'CHARLIE'
		$nato_lookup.'D' = 'DELTA'
		$nato_lookup.'E' = 'ECHO'
		$nato_lookup.'F' = 'FOXTROT'
		$nato_lookup.'G' = 'GOLF'
		$nato_lookup.'H' = 'HOTEL'
		$nato_lookup.'I' = 'INDIA'
		$nato_lookup.'J' = 'JULIET'
		$nato_lookup.'K' = 'KILO'
		$nato_lookup.'L' = 'LIMA'
		$nato_lookup.'M' = 'MIKE'
		$nato_lookup.'N' = 'NOVEMBER'
		$nato_lookup.'O' = 'OSCAR'
		$nato_lookup.'P' = 'PAPA'
		$nato_lookup.'Q' = 'QUEBEC'
		$nato_lookup.'R' = 'ROMEO'
		$nato_lookup.'S' = 'SIERRA'
		$nato_lookup.'T' = 'TANGO'
		$nato_lookup.'U' = 'UNIFORM'
		$nato_lookup.'V' = 'VICTOR'
		$nato_lookup.'W' = 'WHISKEY'
		$nato_lookup.'X' = 'X-RAY'
		$nato_lookup.'Y' = 'YANKEE'
		$nato_lookup.'Z' = 'ZULU'
		$nato_lookup.'0' = 'Number: Zero'
		$nato_lookup.'1' = 'Number: One'
		$nato_lookup.'2' = 'Number: Two'
		$nato_lookup.'3' = 'Number: Three'
		$nato_lookup.'4' = 'Number: Four'
		$nato_lookup.'5' = 'Number: Five'
		$nato_lookup.'6' = 'Number: Six'
		$nato_lookup.'7' = 'Number: Seven'
		$nato_lookup.'8' = 'Number: Eight'
		$nato_lookup.'9' = 'Number: Nine'
		$nato_lookup.'!' = 'Special Character: Exclaimation Point'
		$nato_lookup.'@' = 'Special Character: At Symbol'
		$nato_lookup.'#' = 'Special Character: Hash'
		$nato_lookup.'%' = 'Special Character: Percent Symbol'
		$nato_lookup.'^' = 'Special Character: Caret'
		$nato_lookup.'&' = 'Special Character: Ampersand'
		$nato_lookup.'*' = 'Special Character: Star'
		$nato_lookup.'(' = 'Special Character: Open Parenthesis'
		$nato_lookup.')' = 'Special Character: Close Parenthesis'
		
		# Build an array of possible characters.
		if ($NoSimilar) {
			$arrLowercase = @("a","b","c","d","e","f","g","h","j","k","m","n","p","q","r","s","t","u","v","w","x","y","z")
			$arrUppercase = @("A","B","C","D","E","F","G","H","J","K","M","N","P","Q","R","S","T","U","V","W","X","Y","Z")
			$arrNumbers = @("2","3","4","5","6","7","8","9")
			$arrSpecial = @("@","#","%","^","&","*","(",")")
		} else {
			$arrLowercase = @("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
			$arrUppercase = @("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
			$arrNumbers = @("0","1","2","3","4","5","6","7","8","9")
			$arrSpecial = @("!","@","#","%","^","&","*","(",")")
		}
		
		$minLength = 0
		
		if ($Lower) {
			$arrCharacters += $arrLowercase
			$minLength++
		}
		if ($Upper) {
			$arrCharacters += $arrUppercase
			$minLength++
		}
		if ($Numeric) {
			$arrCharacters += $arrNumbers
			$minLength++
		}
		if ($Special) {
			$arrCharacters += $arrSpecial
			$minLength++
		}
		
		$strPassword = ""
		1..$Length | Foreach-Object {$strPassword = $strPassword + "$($arrCharacters | Get-Random)"}
		
		if ($AtLeastOne) {
			if ($Length -lt $minLength) {
				throw "Password is not long enough to fulfill complexity requirements."
			} else {
				$PasswordMetadata = New-Object System.Object | Select "LowercaseCount","UppercaseCount","NumericCount","SpecialCount"
				$PasswordMetadata.LowercaseCount = ([array]($strPassword -split "" | Where {$arrLowercase -ccontains $_})).Count
				$PasswordMetadata.UppercaseCount = ([array]($strPassword -split "" | Where {$arrUppercase -ccontains $_})).Count
				$PasswordMetadata.NumericCount = ([array]($strPassword -split "" | Where {$arrNumbers -contains $_})).Count
				$PasswordMetadata.SpecialCount = ([array]($strPassword -split "" | Where {$arrSpecial -contains $_})).Count
				$PasswordMetadata | Add-Member -MemberType "NoteProperty" -Name "Largest" -Value $($PasswordMetadata.PSObject.Properties | Where {$_.Value -eq $($PasswordMetadata.PSObject.Properties.Value | Sort -Descending | Select -First 1)} | Foreach-Object {$_.Name})
				$PasswordMetadata | Add-Member -MemberType "NoteProperty" -Name "LowercaseIndex" -Value $(0..$($strPassword.Length - 1) | Foreach-Object {if ($arrLowercase -ccontains $strPassword[$_]) {$_}})
				$PasswordMetadata | Add-Member -MemberType "NoteProperty" -Name "UppercaseIndex" -Value $(0..$($strPassword.Length - 1) | Foreach-Object {if ($arrUppercase -ccontains $strPassword[$_]) {$_}})
				$PasswordMetadata | Add-Member -MemberType "NoteProperty" -Name "NumericIndex" -Value $(0..$($strPassword.Length - 1) | Foreach-Object {if ($arrNumbers -ccontains $strPassword[$_]) {$_}})
				$PasswordMetadata | Add-Member -MemberType "NoteProperty" -Name "SpecialIndex" -Value $(0..$($strPassword.Length - 1) | Foreach-Object {if ($arrSpecial -ccontains $strPassword[$_]) {$_}})
				Write-Verbose "Largest: $($PasswordMetadata.Largest), LowercaseCount: $($PasswordMetadata.LowercaseCount), UppercaseCount: $($PasswordMetadata.UppercaseCount), NumericCount: $($PasswordMetadata.NumericCount), SpecialCount: $($PasswordMetadata.SpecialCount)"
				if ($Lower -and $PasswordMetadata.LowercaseCount -eq 0) {
					$stealfrom = ($PasswordMetadata.Largest | Get-Random).TrimEnd("Count")
					$stealfromindex, $PasswordMetadata."$($stealfrom)Index" = $PasswordMetadata."$($stealfrom)Index"
					Write-Verbose "Steal from index: $($stealfromindex)"
					$strPassword = $strPassword.Remove($stealfromindex,1).Insert($stealfromindex,$($arrLowercase | Get-Random))
					$PasswordMetadata."$($stealfrom)Count"--
					$PasswordMetadata."LowercaseCount"++
					$PasswordMetadata."LowercaseIndex" += $stealfromindex
				}
				if ($Upper -and $PasswordMetadata.UppercaseCount -eq 0) {
					Write-Verbose "Password does not contain one uppercase."
					$stealfrom = ($PasswordMetadata.Largest | Get-Random).TrimEnd("Count")
					$stealfromindex, $PasswordMetadata."$($stealfrom)Index" = $PasswordMetadata."$($stealfrom)Index"
					Write-Verbose "Steal from index: $($stealfromindex)"
					$strPassword = $strPassword.Remove($stealfromindex,1).Insert($stealfromindex,$($arrUppercase | Get-Random))
					$PasswordMetadata."$($stealfrom)Count"--
					$PasswordMetadata."UppercaseCount"++
					$PasswordMetadata."UppercaseIndex" += $stealfromindex
				}
				if ($Numeric -and $PasswordMetadata.NumericCount -eq 0) {
					Write-Verbose "Password does not contain a number."
					$stealfrom = ($PasswordMetadata.Largest | Get-Random).TrimEnd("Count")
					$stealfromindex, $PasswordMetadata."$($stealfrom)Index" = $PasswordMetadata."$($stealfrom)Index"
					Write-Verbose "Steal from index: $($stealfromindex)"
					$strPassword = $strPassword.Remove($stealfromindex,1).Insert($stealfromindex,$($arrNumbers | Get-Random))
					$PasswordMetadata."$($stealfrom)Count"--
					$PasswordMetadata."NumericCount"++
					$PasswordMetadata."NumericIndex" += $stealfromindex
				}
				if ($Special -and $PasswordMetadata.SpecialCount -eq 0) {
					Write-Verbose "Password does not contain a special character."
					$stealfrom = ($PasswordMetadata.Largest | Get-Random).TrimEnd("Count")
					$stealfromindex, $PasswordMetadata."$($stealfrom)Index" = $PasswordMetadata."$($stealfrom)Index"
					Write-Verbose "Steal from index: $($stealfromindex)"
					$strPassword = $strPassword.Remove($stealfromindex,1).Insert($stealfromindex,$($arrSpecial | Get-Random))
					$PasswordMetadata."$($stealfrom)Count"--
					$PasswordMetadata."SpecialCount"++
					$PasswordMetadata."SpecialIndex" += $stealfromindex
				}
			}
		}
		
		if ($NoRepeat) {
			for ($i = 0;$i -lt $($strPassword.Length - 1);$i++) {
				if ($i -lt $($strPassword.Length - 1)) {
					if ($strPassword[$i] -ceq $strPassword[$i + 1]) {
						if ($arrLowercase -ccontains $strPassword[$i]) {
							$strPassword = $strPassword.Remove(($i + 1),1).Insert(($i + 1),$($arrLowercase | Where {$_ -cne "$($strPassword[$i])"} | Get-Random))
						} elseif ($arrUppercase -ccontains $strPassword[$i]) {
							$strPassword = $strPassword.Remove(($i + 1),1).Insert(($i + 1),$($arrUppercase | Where {$_ -cne "$($strPassword[$i])"} | Get-Random))
						} elseif ($arrNumbers -ccontains $strPassword[$i]) {
							$strPassword = $strPassword.Remove(($i + 1),1).Insert(($i + 1),$($arrNumbers | Where {$_ -cne "$($strPassword[$i])"} | Get-Random))
						} elseif ($arrSpecial -ccontains $strPassword[$i]) {
							$strPassword = $strPassword.Remove(($i + 1),1).Insert(($i + 1),$($arrSpecial | Where {$_ -cne "$($strPassword[$i])"} | Get-Random))
						}
					}
				}
			}
		}
		
		if ($NATO) {
			$arrReturn = ""
			$arrReturn += "$($strPassword)"
			$arrReturn += "`r`n----------------------"
			0..$($strPassword.Length - 1) | Foreach-Object {$arrReturn += "`r`n$($nato_lookup["$($strPassword[$_])"])"}
			$arrReturn += "`r`n----------------------"
			return $arrReturn
		} else {
			return $strPassword
		}
	}
}