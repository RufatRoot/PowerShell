#This Scirpt uses custom AD attribute (privateMobileNumber) and GSM gateway based on Asterisk Platform.
param([string]$username)
Import-Module ActiveDirectory
#$username = 'rufat.test'
$lower = ("abcdefghijklmnopqrstuvwxyz".ToCharArray() | Sort-Object {Get-Random})[0..2] -Join ''
$upper = ("ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray() | Sort-Object {Get-Random})[0..2] -Join ''
$digits = ("0123456789".ToCharArray() | Sort-Object {Get-Random})[0..1] -Join ''
$chars = ("!@#$%_".ToCharArray() | Sort-Object {Get-Random})[0..1] -Join ''

$passwd = (($lower + $upper + $digits + $chars).ToCharArray() | Sort-Object {Get-Random}) -Join ''

Set-ADAccountPassword -Identity $username -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $passwd -Force)
Set-ADUser $username -ChangePasswordAtLogon $true
$user = Get-ADUser $username -Properties *

$number = ''
if ($user.MobilePhone -ne $null) {
    $number = $user.MobilePhone
    Write-Host "Public Mobile Phone $number is used for user $username. Password =  $passwd" -ForegroundColor Green
} elseif ($user.privateMobileNumber -ne $null) {
    $number = $user.privateMobileNumber
    Write-Host "Private Mobile Phone $number is used for user $username. Password =  $passwd" -ForegroundColor Green
} else {
    Write-Host "No Mobile Numbers Found" -ForegroundColor Red
    exit
}

    $text1 =  "Your new password is: "
    $text2 = "In case of support contact +XXXxxxXXX EXT=XXXX "
    $message = '"' + $text1 + $passwd + '==== ' + $text2 + ' ==== ' + '"'
    $gsmhost = "XXX.XXX.XXX.XXX"
    $gsmport = "XXX"

    $tcpconnection = New-Object System.Net.Sockets.TcpClient ($gsmhost, $gsmport)
    $tcpStream = $tcpConnection.GetStream()
    $reader = New-Object System.IO.StreamReader($tcpStream)
    $writer = New-Object System.IO.StreamWriter($tcpStream)
    $writer.AutoFlush = $true

    if ($tcpConnection.Connected) {
        $writer.WriteLine("action: login")
        $writer.WriteLine("username: admin")
        $writer.WriteLine("secret: admin")
        $writer.WriteLine("")

        $writer.WriteLine("action: command")
        $writer.WriteLine("Command: gsm send sync sms 1 $number $message 10 0 ")
        $writer.WriteLine("")
        }

    $reader.Close()
    $writer.Close()
    $tcpConnection.Close()

