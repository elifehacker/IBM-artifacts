Get-Date -Format g
$ip_regex = [Regex] '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

$files = Get-ChildItem (Resolve-Path .\).Path -Recurse |
ForEach-Object {
    Write-Host $_.FullName
    if ($_ -is [system.io.fileinfo]){
        if (([IO.Path]::GetExtension($_) -ne ".ps1") -and ([IO.Path]::GetExtension($_) -ne ".zip")){

            (Get-Content $_.FullName) -replace $ip_regex, "IP_MASKED" | Set-Content $_.FullName
            
        }
    }
}
Get-Date -Format g
Read-Host -Prompt "Press enter to continue"