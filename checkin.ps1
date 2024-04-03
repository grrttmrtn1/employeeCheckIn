#need to call like addUser "name" "date" "direct/indirect". It cannot be in paranthesis or with commas

#object format
#Name               lastCheckIn employeeType
#----               ----------- ------------

$file = 'text file location'

function loadFile {
    return Get-Content $file
}

function checkFileContainsArray {
    if ([string]::IsNullOrWhitespace($employees) -or $employees.GetType().BaseType.Name -ne "Array")
    {
        return $false
    }
    elseif ($employees.GetType().BaseType.Name -eq "Array"){
        return $true
    }
}

function addUser ($name, $type) {
    if ($type.ToLower() -eq 'indirect' -or $type.ToLower() -eq 'direct') {
        $employees = loadFile
        $newEmployeeArr = @()
        if (checkFileContainsArray) {
            $newEmployeeArr += $employees | ConvertFrom-Json
            $newEmployeeArr += [PSCustomObject]@{
            Name = $name
            lastCheckIn = (Get-Date -format "MM/dd/yyy")
            employeeType = $type
            }
             Set-Content -Value ($newEmployeeArr | ConvertTo-Json) -Path $file
        }
        else {
            $newEmployeeArr += [PSCustomObject]@{
            Name = $name
            lastCheckIn = $date
            employeeType = $type
            } 
            Add-Content -Value ($newEmployeeArr | ConvertTo-Json) -Path $file
        }
    }
    else {
        throw 'Employee type should be direct or indirect'
    }
}

function removeUser ($name) {
    $employees = loadFile | ConvertFrom-Json
    if ($employees.Name.IndexOf($name) -eq -1) {
        throw "employee with name: $name not found in the list"
    }
    else {
        Set-Content -Value ($employees | Where-Object -FilterScript {$_.Name -ne $name} | ConvertTo-Json) -Path $file
    }

}

function message ($name) {
    Add-Type -AssemblyName System.Windows.Forms
    $msgBody = "Check in with $name"
    $msgTitle = "Check in needed"
    $msgButton = 'OKCancel'
    $result = [System.Windows.Forms.MessageBox]::Show($msgBody,$msgTitle,$msgButton)
    if ($result -eq 'OK') {
        return $true
    }
    if ($result -eq 'Cancel') {
        return $false 
    }
}

function displayEmployees {
    return loadFile | ConvertFrom-Json
}

function runCheckin {
    $employees = loadFile | ConvertFrom-Json
    foreach ($employee in $employees) {
        if ($employee.employeeType.ToLower() = "direct") {
            if ((New-TimeSpan -Start $employee.lastCheckIn -End (Get-Date)).Days -ge 3) {
                if (message $employee.Name) {
                    $userUpdate = $employees | Where-Object { $_.Name -eq $employee.Name}
                    $userUpdate.lastCheckIn = (Get-Date -format "MM/dd/yyy")
                    Set-Content -Value ($employees | ConvertTo-Json) -Path $file
                }
            }
        }
        elseif ($employee.employeeType.ToLower() = "indirect") {
            if ((New-TimeSpan -Start $employee.lastCheckIn -End (Get-Date)).Days -ge 6) {
                if (message $employee.Name) {
                    $userUpdate = $employees | Where-Object { $_.Name -eq $employee.Name}
                    $userUpdate.lastCheckIn = (Get-Date -format "MM/dd/yyy")
                    Set-Content -Value ($employees | ConvertTo-Json) -Path $file
                }
            }
        }
    }

}
