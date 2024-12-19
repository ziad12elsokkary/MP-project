param (
    [string]$savePath,
    [string]$testPath
)

# Ensure savePath and testPath are provided
if (-not $savePath -or -not $testPath) {
    Write-Host "Please provide both a save path for the recorded video and the Flutter test file path."
    exit
}

# Start screen recording in the background
Write-Host "Starting screen recording for 2 minutes..."
Start-Process -NoNewWindow -FilePath "adb" -ArgumentList "shell screenrecord --time-limit 180 /sdcard/screenrecord.mp4" -PassThru

# Run the Flutter test while recording
Write-Host "Running Flutter test in $testPath while screen recording is active..."
flutter test $testPath

# Ensure enough time for the screen recording to complete
Write-Host "Waiting for the screen recording to finish..."
Start-Sleep -Seconds 180

# Pull the recorded file to the specified location
Write-Host "Pulling the recorded file to $savePath..."
adb pull /sdcard/screenrecord.mp4 $savePath

# Check if the pull was successful
if (Test-Path $savePath) {
    Write-Host "Recording saved successfully to $savePath"
} else {
    Write-Host "Failed to save the recording to $savePath"
}

# Clean up: Delete the recorded file from the emulator
Write-Host "Cleaning up the recorded file from the emulator..."
adb shell rm /sdcard/screenrecord.mp4

Write-Host "Done."