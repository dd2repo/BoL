##Project: EasyDaily 
##Author: Yannick Lanzrath
##Version: 1.0
##ToDo:
## ~ VendorID Ausgabe ob Angebot Agof oder nicht Agof ist
## ~ Autoupdate
## ~ Prüfung ob Angebotsliste aktuell ist

Function SelectFileDialog($strInitialDirectory) {
    # Open a Windows standard "Open File Dialog" starting in a given folder.
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    # Create new Forms instance
    $wfrmFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    # Define starting / default directory
    $wfrmFileDialog.InitialDirectory = $strInitialDirectory
    # Set filter for file types
    $wfrmFileDialog.Filter = "All files (*.csv)| *.csv"
    # Open dialog
    $wfrmFileDialog.ShowDialog() | Out-Null
    
    # Return the file path
    return $wfrmFileDialog.FileName
}

$date = Get-Date -Format d-M-yyyy
Write-Host " ________________________________________________________________________________" -foreground "Green"
Write-Host "| Project: EasyDaily | Version: 1.0 | Author: Yannick Lanzrath | INFOnline GmbH  |" -foreground "Green"
Write-Host "|________________________________________________________________________________|" -foreground "Green"
Write-Host ""
Start-Sleep -s 1
Write-Host "Bitte wählen Sie, aus welchen Prozess Sie gerne bearbeiten würden." 
Write-Host "Folgende Eingaben sind Möglich:"
Write-Host "1. 'A1'" -foreground "Green"
Write-Host "2. 'VendorID'" -foreground "Green"
Write-Host "3. 'NotGeo'" -foreground "Green"
Write-Host "4. 'Help'"
Write-Host ""

Start-Sleep -s 1
$choice = ""
$choice = Read-Host
 
$afiles = "C:\Program Files\EasyDaily"
$aroot = "C:\EasyDaily"
$testfiles = Test-Path -Path $afiles
$testroot = Test-Path -Path $aroot

if ($testfiles){
cd C:\Program Files\EasyDaily
}
elseif ($testroot){
cd C:\EasyDaily
}
else{
Write-Host "Fehler: Ihr 'EasyDaily' Ordner befindet sich am falschen Ort. Bitte benutzen Sie 'EasyDaily' aussschliesslich aus 'C:\Program Files\' oder 'C:\' um Kompatibilitätsprobleme zu vermeiden"
}

##########################A1

if ($choice -eq "A1" -or $choice -eq "1" -or $choice -eq "1."){
Write-Host ""
Write-Host "Bitte wählen Sie nun die CSV für die A1 Analyse aus damit diese bearbeitet werden kann." 
Write-Host ""
Start-Sleep -s 1

$angebote = Import-Csv (SelectFileDialog -strInitialDirectory "C:") –delimiter ";" | Where-Object {[int]$_.Prozent -gt 30.000 } | Where-Object {[int]$_.Ok -gt 500 } | Select-Object Site | Format-Table -HideTableHeaders | Out-String
if ($angebote)
{
	Write-Host "Folgende Filter wurden angewendet >"
	Write-Host "Größer als 30.000 Prozent / Größer als 500 PI"
	Write-Host ""
	Write-Host "Folgende Angebote müssen angeschrieben werden:"
	Write-Host ""
	Write-Host $angebote -foreground "Green"
}
else
{
	Write-Host "Nach der Filterung sind keine Angebote mehr übrig geblieben!" -foreground "Green"
}
$angebote | Out-File .\log\A1-Analyse-$date.txt 

}
##########################VENDORID

elseif ($choice -eq "VendorID" -or $choice -eq "2" -or $choice -eq "2."){
Write-Host ""
Write-Host "Um die VendorID zu bearbeiten müssen Sie den Inhalt des aktuellen VendorID Tickets in die dafür vorgesehene 'vendoraktuell.txt' einfügen." 
Write-Host "Diese befindet sich im Hauptverzeichnis des 'EasyDaily'-Tools." 
Write-Host ""
Start-Sleep -s 1
Write-Host "Ist die 'vendoraktuell.txt' aktuell? Ja/Nein" 
Write-Host ""
$choice1 = Read-Host
if ($choice1 -eq "Yes" -or $choice1 -eq "YES" -or $choice1 -eq "yes" -or $choice1 -eq "ja" -or $choice1 -eq "JA" -or $choice1 -eq "Ja" -or $choice1 -eq "J" -or $choice1 -eq "Y" -or $choice1 -eq "j" -or $choice1 -eq "y")
{
	$b = Get-Content -Path .\data\oer
	$c = Get-Content -Path .\data\nichtagof
	$d = Get-Content -Path .\data\agof
	Write-Host ""
	Write-Host "Es wurden folgende Filter angewendet >"
	Write-Host "Nicht Oeffentlich-rechtlich / Agof-Ja / Agof-Nein"
	Write-Host ""
	Write-Host ""
	
	$agofja = Get-Content -Path .\vendoraktuell.txt | ForEach-Object { $_ -replace ' ' } | Select-String -pattern $d | Select-String -pattern $b -NotMatch 
	$agofnein = Get-Content -Path .\vendoraktuell.txt | ForEach-Object { $_ -replace ' ' } | Select-String -pattern $c | Select-String -pattern $b -NotMatch 
	Get-Content -Path .\vendoraktuell.txt | ForEach-Object { $_ -replace ' ' } | Select-String -pattern $c | Select-String -pattern $d | Select-String -pattern $b -NotMatch | Out-File .\log\VendorID-$date.txt 
	
	if ($agofja)
	{
		Write-Host "Folgende Agof Angebote müssen angeschrieben werden:"
		Write-Host $agofja -foreground "Green"
		Write-Host ""
	}
	
	else
	{
		Write-Host "Es müssen keine Agof Angebote angeschrieben werden." -foreground "Green"
		Write-Host ""
	}
	
	if($agofnein)
	{
		Write-Host "Folgende Nicht-Agof Angebote müssen angeschrieben werden:"
		Write-Host $agofnein -foreground "Green"
		Write-Host ""
	}

	else
	{
		Write-Host "Es müssen keine Nicht-Agof Angebote angeschrieben werden." -foreground "Green"
		Write-Host ""
	}
}
}
elseif ($choice1 -eq "No" -or $choice1 -eq "NO" -or $choice1 -eq "no" -or $choice1 -eq "nein" -or $choice1 -eq "NEIN" -or $choice1 -eq "Nein" -or $choice1 -eq "N" -or $choice1 -eq "n")
{
Write-Host "Bitte aktualisieren Sie die 'vendoraktuell.txt' und starten sie 'EasyDaily' erneut!"

}
##########################NotGeo

elseif ($choice -eq "NotGeo" -or $choice -eq "3" -or $choice -eq "3."){
$b = Get-Content -Path .\data\oer
Write-Host ""
Write-Host "Bitte wählen Sie nun die CSV Datei 'Ungeolokalisierbare_Angebote' aus. Diese können Sie im 'CSV-Generator' generieren."
Write-Host ""
$notgeo = Import-Csv (SelectFileDialog -strInitialDirectory "C:") -Delimiter ";" -Header 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 | 
Where-Object {$_.15 -ne "" } | Where-Object {$_.14 -ne "" }| Where-Object {$_.13 -ne "" }| Where-Object {$_.12 -ne "" }| Where-Object {$_.11 -ne "" }| Where-Object {$_.10 -ne "" }| Where-Object {$_.9 -ne "" }| Where-Object {$_.8 -ne "" }| Where-Object {$_.7 -ne "" }| Where-Object {$_.6 -ne "" }| Where-Object {$_.5 -ne "" }| Where-Object {$_.4 -ne "" }| Where-Object {$_.3 -ne "" }| Where-Object {$_.2 -ne "" }| Where-Object {$_.1 -ne "" } |
Where-Object {$_.1 -notmatch $b} | Where-Object {$_.1 -notmatch "ctv"} | Where-Object {$_.1 -notmatch "aad"} | Where-Object {$_.1 -notmatch "Angebotskennung"} | Where-Object {$_.1 -notmatch "app"} |
Where-Object {([int]$_.3 -gt 100 -and [int]$_.5 -gt 100 -and [int]$_.7 -gt 100) -or ([int]$_.5 -gt 100 -and [int]$_.7 -gt 100 -and [int]$_.9 -gt 100) -or ([int]$_.7 -gt 100 -and [int]$_.9 -gt 100 -and $_.11 -gt 100) -or ([int]$_.9 -gt 100 -and [int]$_.11 -gt 100 -and [int]$_.13 -gt 100) -or ([int]$_.11 -gt 100 -and [int]$_.13 -gt 100 -and [int]$_.15 -gt 100)} |
Select-Object "1" | Format-Table -HideTableHeaders | Out-String 

Write-Host "Es werden folgende Filter angewendet >"
Write-Host "Nicht Oeffentlich-rechtlich / Nicht CTV / Nicht App / Mehr als 100 PI's in 3 aufeinander folgenden Tagen / Spalten mit leeren Feldern wurden entfernt"
Write-Host ""
if($notgeo)
{
	Write-Host "Folgende Angebote müssen an geschrieben werden:"
	Write-Host $notgeo -foreground "Green"
	$notgeo | Out-File .\log\NotGeo-$date.txt 
}
else
{
	Write-Host "Nach der Filterung sind keine Angbote übrig geblieben." -foreground "Green"
}
}

##########################HELP
elseif ($choice -eq "Help" -or $choice -eq "4" -or $choice -eq "4."){
Write-Host "Sharepoint Dokumentation wird geoeffnet.."
start https://iep.infad.intern/sus/Wiki%20SuS/EasyDaily.aspx
}

else{
Write-Host "Ihre Eingabe konnte leider nicht erkannt werden." -foreground "Red"
}




