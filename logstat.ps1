# Get Credententials for execution on remote hosts. Account must have admin privileges on remote host.

$password = ConvertTo-SecureString “QWyKv1Zli334were34324242rweEkfigr” -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("CONTOSO\rufat.admin”, $password)

# Invoke script on rmeote hosts.
Invoke-Command -Credential $cred -ComputerName SRV-EXA, SRV-EXB -ScriptBlock {

# Here you must define vaules for variables
$srv = (Get-ComputerInfo).CsName
$exlogspath = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging'
$iislogspath = 'C:\inetpub\Logs\LogFiles'
$logstatpath = 'D:\ExLogsStats'
$exdirectory = Get-childItem -Path "$exlogspath" -Directory
$iisdirectory = Get-ChildItem -Path "$iislogspath" -Directory
$directories = $iisdirectory + $exdirectory

# If the remote host don't have folder for statistics CSV file this statement will create it.
if (!(Test-Path $logstatpath)) {New-Item -ItemType Directory -Path $logstatpath}

# Starting loop for each log file.
foreach ($i in $directories) {

    $log = Get-ChildItem -Path $i.FullName -Recurse -File| Measure-Object -Sum Length | Select-Object `
        @{Name='Folder';Expression={$i.Name}},
        @{Name='Date/Time';Expression={(Get-Date -Format "dd/MM/yyyy HH:mm")}},
        @{Name='Files';Expression={$_.Count}},
        @{Name='Size';Expression={$_.Sum}} 

# This if statement will check the content of the log folder. If it not empty then the script will contune to work. 
# If it empty the script will skip this log file.

        if ($log -ne $null) 
        {
        # If CSV file already exist then the script will append data to it.
            If ("$logstatpath\$srv - $i.csv")
            {
    
            $log | Export-Csv -Append "$logstatpath\$srv - $i.csv"

            }
        # If CSV does not exist the the script will create it.
        else {
    
            $log | Export-Csv "$logstatpath\$srv - $i.csv"
    
             }
        }

    }

}
