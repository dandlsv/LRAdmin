<# 
DLSV MS SQL Backup script v2.1
Authour: @DanDLSV
Function: 
- Obtain the lastest MS SQL backup file in a directory 
- Generate a new fule name with today's date. 
- Copy the backup to a remote location
- Calculate the SRC and DST SHA256 and compare them.  
    -If successful the script will remove the local MSSQL backup 
    - If unsuccessful the script will write out an error to the localhost's application event log.
    - If no backups are found in the directory it will write out an informational notification to the localhost's application event lof. 
#>


#Set flexible Vars:
$backupDirectory = "D:\LR_Backups"
$remoteSharePath = "\\remote\file\share"


#Get the last written MS SQL backup file in the LR backup Directory.  
$latestBackupFile = Get-ChildItem -Path $backupDirectory -Filter "*.bak" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1

if ($latestBackupFile) {
    # Generate the new file name with today's date
    $today = Get-Date -Format "yyyyMMdd"
    $newFileName = "{0}_{1}.bak" -f $latestBackupFile.BaseName, $today
    $remoteFilePath = Join-Path -Path $remoteSharePath -ChildPath $newFileName

    # Copy the backup file to the remote file share
    Copy-Item -Path $latestBackupFile.FullName -Destination $remoteFilePath

    # Calculate SHA256 of the local file
    $localSha256 = Get-FileHash -Path $latestBackupFile.FullName -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    # Calculate SHA256 of the remote file
    $remoteSha256 = Get-FileHash -Path $remoteFilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    # Compare SHA256 hashes and perform actions accordingly
    if ($localSha256 -eq $remoteSha256) {
        Remove-Item -Path $latestBackupFile.FullName
    } else {
        #Write error to the application log
        $errorMessage = "File copy error: SHA256 hashes do not match."
        Write-EventLog -LogName Application -Source "LR Backup Script" -EventId 1000 -EntryType Error -Message $errorMessage  
    }
} else {
    # No backup files found in the directory
    $errorMessage = "No backup files found in the directory: $backupDirectory"
    Write-EventLog -LogName Application -Source "LR Backup Script" -EventId 1000 -EntryType Information -Message $errorMessage
}