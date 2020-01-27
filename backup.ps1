[CmdletBinding()] 
Param( 
        #Which folder you would like to backup
            [Parameter(Mandatory)]
            [String]$Backupfiles = '',
        #Backup location
            [Parameter(Mandatory)]
            [String]$Backuplocation = '',
        #Define you storage limit (MB or GB)
            [Parameter(Mandatory)]
            $Sizelimit="",
        #Temp Location to copy files
            [Parameter(Mandatory)]
            [String]$templocation = ''
)

#Get your existing backup files to determine the exceeded limit
    $files = Get-ChildItem -Path $backuplocation | sort LastWriteTime -Descending

$sumsize = 0
    foreach ($file in $files) {
        $sumsize += $file.length
    }


while ($sumsize -gt $sizelimit) {
    $sumsize -= $files[-1].Length
    Remove-Item $files[-1].PSPath
    $files = $files[0..($files.length-2)]
    }
# If during backup process you files are used by another process so copy them to another location
    Copy-Item $backupfiles $templocation -Recurse

$compress = @{
    Path= $backupfiles
    CompressionLevel = "Optimal"
    DestinationPath = "$backuplocation\$(get-date -f MM-dd-yyyy).zip"
    }

Compress-Archive @compress -Update
    if ($templocation) {
        Remove-Item $templocation -Recurse -Force
    }
