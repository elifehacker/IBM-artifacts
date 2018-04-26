Get-Date -Format g
$ip_regex = [Regex] '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
$replacement_0 = 0
$replacement_1 = 0
$replacement_2 = 0
function get_next_unique_ip_mask(){
    if ($replacement_0 -eq 9){
        $global:replacement_0 = 0
        if ($replacement_1 -eq 9){
            $global:replacement_1 = 0
            if ($replacement_2 -eq 9){
                $global:replacement_2 = 0
            }
            else {
                $global:replacement_2++
            }
        }
        else {
            $global:replacement_1++
        }
    }
    else {
        $global:replacement_0++
    }
    return "$([String]$replacement_2)$([String]$replacement_1)$([String]$replacement_0)" 
}

$encountered_ips = @{}

$files = Get-ChildItem (Resolve-Path .\).Path -Recurse |
ForEach-Object {
    Write-Host $_.FullName
    if ($_ -is [system.io.fileinfo]){
        if (([IO.Path]::GetExtension($_) -ne ".ps1") -and ([IO.Path]::GetExtension($_) -ne ".zip")){
            $diff = 0
            $filename = $_.FullName
            $content = @()+(Get-Content $_.FullName)
            $linecount = 0;
            foreach($line in $content) {
                $match = $ip_regex.Match($line)
                while ($match.Success){
                    $diff++
                    if(-not ($encountered_ips.ContainsKey($match))){
                        $next_unique_mask = "xxx.xxx.xxx.$(get_next_unique_ip_mask)"
                        $encountered_ips.Add($match, $next_unique_mask)
                    }
                    $line = $line -replace $match, $encountered_ips[$match]
                    $content[$linecount] = $line
                    $match = $match.NextMatch()
                }
                $linecount++
            }

            if($diff -ne 0){
                $content | Set-Content $filename
            }
        }
    }
}
Get-Date -Format g
Read-Host -Prompt "Press enter to continue"