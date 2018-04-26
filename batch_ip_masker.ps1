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
            $match_list = New-Object System.Collections.Specialized.StringCollection
            $match = $ip_regex.Match((Get-Content $_.FullName))
            while ($match.Success){
                $match_list.Add($match.Value) | Out-Null
                $match = $match.NextMatch()
            }
            ForEach($match in $match_list){
                if(-not ($encountered_ips.ContainsKey($match))){
                    $next_unique_mask = "xxx.xxx.xxx.$(get_next_unique_ip_mask)"
                    $encountered_ips.Add($match, $next_unique_mask)
                }
            }

            
            ForEach ($ip in $encountered_ips.Keys){
                (Get-Content $_.FullName) -replace $ip, $encountered_ips[$ip] | Set-Content $_.FullName
            }
        }
    }
}

Read-Host -Prompt "Press enter to continue"