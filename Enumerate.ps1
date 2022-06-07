# you can add more properties if you need to
$properties = 'Name','OperatingSystem'
$searcher   = [adsisearcher]'(objectCategory=computer)'
$searcher.PropertiesToLoad.AddRange($properties)
$computers = $searcher.FindAll() 
$output = @()
foreach ($pc in $computers) {
    # get a list of IP addresses for each computer, filter on IPV4
    try {
        $name = $pc.Properties["name"]
        $ip = $null
        $ip = [System.Net.Dns]::GetHostEntry($name).AddressList | 
              Where-Object { $_.AddressFamily -eq 'InterNetwork' } | 
              Select-Object -ExpandProperty IPAddressToString
    }
    catch { 
        Write-Warning "Host '$name' could not be reached."
    }

    # create a PSObject with selected properties for each machine found
    $result = New-Object -TypeName PSObject
    foreach ($key in $properties) {
        # apparently, all property names must be lower case
        $name  = $key.ToLower()
        $value = $pc.Properties[$name]
        $result | Add-Member -MemberType NoteProperty -Name $key -Value $value
    }
    # add the 'IpV4Addresses' property
    $result | Add-Member -MemberType NoteProperty -Name 'IpV4Addresses' -Value ($ip -join ', ')

    # output the resulting object
    $output += $result
}

# display the output on screen as table
$output | Format-Table -AutoSize  
# or $output | Format-List

# or save the output to a CSV file
# $output | Export-Csv -Path 'PATH AND FILENAME FOR THE EXPORT CSV' -NoTypeInformation
