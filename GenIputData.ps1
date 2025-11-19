# PowerShell 5.1 script – genererer 'Banker.txt' og 'Transaktioner.txt'
# Match'er fast-bredde felter fra din Python-kode

# ---------- Parametre ----------
$NUM_CUSTOMERS = 10000
$MAX_TRANSACTIONS_PER_CUSTOMER = 10
$NUM_BANKS = 100

$BASE_PATH = Join-Path -Path "." -ChildPath "text-files"
if (-not (Test-Path $BASE_PATH)) {
    New-Item -ItemType Directory -Path $BASE_PATH | Out-Null
}

$TRANSACTION_FILE = Join-Path $BASE_PATH "Transaktioner.txt"
$BANK_FILE        = Join-Path $BASE_PATH "Banker.txt"

# ---------- Fiktive data ----------
$FIRST_NAMES = "Lars","Mette","Jens","Anne","Peter","Marie","Søren","Hanne","Niels","Camilla"
$LAST_NAMES  = "Hansen","Jensen","Nielsen","Christensen","Andersen","Mortensen","Larsen","Pedersen","Olsen","Thomsen"

$STREETS = "Østerbrogade","Nørreport","Amagerbrogade","Vesterbrogade","Hovedgaden","Søndergade","Strandvejen","Frederiks Allé"
$CITIES  = "København","Aarhus","Odense","Aalborg","Esbjerg","Randers","Vejle","Roskilde","Helsingør","Næstved"
$POSTCODES = "2100","8000","5000","9000","6700","8900","7100","4000","3000","4700"

$STORES = @(
  "Supermarked","Tøjbutik","Elektronikbutik","Restaurant","Boghandel",
  "Apotek","Tankstation","Café","Biograf","Møbelbutik","Blomsterhandler","Bageri","Fitnesscenter"
)

$BANK_NAMES = "Danske Bank","Nordea","Jyske Bank","Sydbank","Nykredit Bank","Arbejdernes Landsbank","Spar Nord Bank","Handelsbanken"

$VALUTA_CODES = "DKK","USD","EUR"
$TRANSACTION_TYPES = "Indbetaling","Udbetaling","Overførsel"

# ---------- Hjælpere ----------
Add-Type -AssemblyName "System.Globalization" | Out-Null
$Invariant = [System.Globalization.CultureInfo]::InvariantCulture
$Rand = New-Object System.Random

function Get-RandItem([object[]]$arr) {
    return $arr[$Rand.Next(0, $arr.Count)]
}

function New-CPR {
    # Fødselsdato mellem 1950-01-01 og 2005-12-31
    $start = [datetime]::new(1950,1,1)
    $end   = [datetime]::new(2005,12,31)
    $rangeDays = ($end - $start).Days
    $offset = $Rand.Next(0, $rangeDays + 1)
    $birth = $start.AddDays($offset)
    $birthStr = $birth.ToString("ddMMyy", $Invariant)    # DDMMYY
    $suffix = "{0:0000}" -f $Rand.Next(1000, 10000)      # 4 cifre
    $cpr = "$birthStr-$suffix"
    $birthHuman = $birth.ToString("dd-MM-yyyy", $Invariant)
    return @($cpr, $birthHuman)
}

function New-AccountNumber {
    $part1 = "{0:000}"  -f $Rand.Next(100,1000)
    $part2 = "{0:00}"   -f $Rand.Next(10,100)
    $part3 = "{0:00000}"-f $Rand.Next(10000,100000)
    return "$part1-$part2-$part3"
}

function New-Address {
    $street = Get-RandItem $STREETS
    $house  = "{0}{1}" -f $Rand.Next(1,1000), (Get-RandItem @("","A","B","C"))
    $post   = Get-RandItem $POSTCODES
    $city   = Get-RandItem $CITIES
    return "$street $house, $post $city"
}

function New-TransactionTimestamp {
    # Format: yyyy-MM-dd-HH.mm.ss.ffffff (som Python-koden)
    $start = [datetime]::new(2020,1,1,0,0,0)
    $end   = [datetime]::new(2025,12,31,23,59,59)
    $totalSeconds = [int][Math]::Floor(($end - $start).TotalSeconds)
    $secOffset = $Rand.Next(0, $totalSeconds + 1)
    $dt = $start.AddSeconds($secOffset)
    $micro = $Rand.Next(0,1000000)  # 0..999999
    return ("{0:yyyy-MM-dd-HH.mm.ss}.{1:000000}" -f $dt, $micro)
}

function New-BankData {
    $list = New-Object System.Collections.Generic.List[object]
    for ($i=1; $i -le $NUM_BANKS; $i++) {
        $reg   = "{0:0000}" -f $i
        $name  = Get-RandItem $BANK_NAMES
        $addr  = New-Address
        $phone = "+45 {0}" -f $Rand.Next(10000000,100000000)
        $email = "kontakt@{0}.dk" -f ($name -replace ' ','').ToLowerInvariant()
        $list.Add([pscustomobject]@{
            Reg   = $reg
            Name  = $name
            Addr  = $addr
            Phone = $phone
            Email = $email
        }) | Out-Null
    }
    return $list
}

# Ensret fast-bredde felter (venstre/højre justering via .NET formatstrenge)
function Format-BankRecord($reg,$name,$addr,$phone,$email) {
    return ("{0,-4}{1,-30}{2,-50}{3,-15}{4,-30}" -f $reg,$name,$addr,$phone,$email)
}

function Format-Amount([double]$amount) {
    # Højrejusteret 15, 2 decimaler, invariant (punktum)
    return [string]::Format($Invariant, "{0,15:F2}", $amount)
}

function Format-TransactionRecord($cpr,$navn,$adresse,$fodselsdato,$kontonr,$regnr,$belob,[string]$valuta,$type,$butik,$timestamp) {
    $belobStr = Format-Amount $belob
    # Bredder: 15,30,50,11,14,6,15,4,20,20,26
    return ("{0,-15}{1,-30}{2,-50}{3,-11}{4,-14}{5,-6}{6}{7,-4}{8,-20}{9,-20}{10,-26}" -f `
            $cpr,$navn,$adresse,$fodselsdato,$kontonr,$regnr,$belobStr,$valuta,$type,$butik,$timestamp)
}

# ---------- Skriv filer ----------
# Brug StreamWriter for performance (og UTF-8 med BOM – god til danske æøå i PS5.1)
$ansi = [System.Text.Encoding]::GetEncoding(1252)
$bankWriter = New-Object System.IO.StreamWriter($BANK_FILE, $false, $ansi)
$txWriter   = New-Object System.IO.StreamWriter($TRANSACTION_FILE, $false, $ansi)
try {
    # Bankdata
    $banks = New-BankData
    foreach ($b in $banks) {
        $line = Format-BankRecord $b.Reg $b.Name $b.Addr $b.Phone $b.Email
        $bankWriter.WriteLine($line)
    }

    $bankRegs = $banks | ForEach-Object { $_.Reg }

    # Transaktioner
    for ($i=1; $i -le $NUM_CUSTOMERS; $i++) {
        $cprInfo = New-CPR
        $cpr     = $cprInfo[0]
        $fodsels = $cprInfo[1]                   # "dd-MM-yyyy"
        $konto   = New-AccountNumber
        $regnr   = Get-RandItem $bankRegs
        $navn    = "{0} {1}" -f (Get-RandItem $FIRST_NAMES), (Get-RandItem $LAST_NAMES)
        $adresse = New-Address

        $numTx = $Rand.Next(1, $MAX_TRANSACTIONS_PER_CUSTOMER + 1)
        for ($t=0; $t -lt $numTx; $t++) {
            $belob = [Math]::Round(($Rand.NextDouble() * 200000.0) - 100000.0, 2)  # -100000..100000
            $valuta = Get-RandItem $VALUTA_CODES
            $type   = Get-RandItem $TRANSACTION_TYPES
            $butik  = Get-RandItem $STORES
            $ts     = New-TransactionTimestamp

            $record = Format-TransactionRecord `
                $cpr $navn $adresse $fodsels $konto $regnr $belob $valuta $type $butik $ts

            $txWriter.WriteLine($record)
        }
    }
}
finally {
    $bankWriter.Close()
    $txWriter.Close()
}

Write-Host ("Dataset med {0} kunder og op til {1} transaktioner er genereret i filen '{2}'" -f `
    $NUM_CUSTOMERS, ($NUM_CUSTOMERS * $MAX_TRANSACTIONS_PER_CUSTOMER), $TRANSACTION_FILE)
Write-Host ("Bankdata genereret i filen '{0}'" -f $BANK_FILE)
