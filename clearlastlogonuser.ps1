param 
(
    [switch]$RunAtLogoff
)

# Specify the path to the user profile folder
$userProfilePath = "C:\Users"

# Define the script path
$scriptPath = "C:\Users\testuser\ClearLastLogonUser.ps1"

if ($RunAtLogoff) 
{
    # Get the last logged-on user from the registry
    $lastLoggedOnUserKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
    $lastLoggedOnUser = (Get-ItemProperty -Path $lastLoggedOnUserKey).LastLoggedOnUser

    # Check if the last logged-on user exists
    if ($null -ne $lastLoggedOnUser -and $lastLoggedOnUser.Trim() -ne "") 
    {
        # Construct the path to the user's profile folder
        $userFolderPath = Join-Path -Path $userProfilePath -ChildPath $lastLoggedOnUser

        # Check if the user profile folder exists
        if (Test-Path -Path $userFolderPath) 
        {
            # Attempt to delete the user profile folder
            try 
            {
                Remove-Item -Path $userFolderPath -Recurse -Force
                Write-Host "User profile folder '$userFolderPath' deleted successfully."
            } 
            catch 
            {
                Write-Host "Failed to delete user profile folder '$userFolderPath'. Error: $_"
            }
        } 
        else 
        {
            Write-Host "User profile folder '$userFolderPath' does not exist."
        }
    } 
    else 
    {
        Write-Host "No last logged-on user found or already cleared."
    }
} 
else 
{
    # Get the last logged-on user from the registry
    $lastLoggedOnUserKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI"
    $lastLoggedOnUser = (Get-ItemProperty -Path $lastLoggedOnUserKey).LastLoggedOnUser

    # Check if the last logged-on user exists and proceed to create the scheduled task
    if ($null -ne $lastLoggedOnUser -and $lastLoggedOnUser.Trim() -ne "") {
        # Create the Task Scheduler task to run this script at logoff
        $taskName = "ClearLastLoggedOnUserAtLogoff"
        $taskDescription = "This task clears the last logged-on user and deletes the user profile folder at logoff."
        $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`" -RunAtLogoff"
        $taskTrigger = New-ScheduledTaskTrigger -AtLogoff
        $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteriesPower -DontStopIfGoingOnBatteriesPower -StartWhenAvailable

        # Register the scheduled task
        Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -TaskName $taskName -Description $taskDescription -RunLevel Highest

        Write-Host "Scheduled task '$taskName' created to run the script at logoff."
    } 
    else 
    {
        Write-Host "No last logged-on user found or already cleared."
    }
}