
"Running tests"
$ErrorActionPreference = "Stop"


if ($env:APPVEYOR_BUILD_VERSION) {
  # run in CI
  $version = $env:APPVEYOR_BUILD_VERSION -replace('\.[^.\\/]+$')
} else {
  # run manually
  [xml]$spec = Get-Content launchy.nuspec
  $version = $spec.package.metadata.version
}

"TEST: Version $version in launchy.nuspec file should match"
[xml]$spec = Get-Content launchy.nuspec
if ($spec.package.metadata.version.CompareTo($version)) {
  Write-Error "FAIL: Wrong version in nuspec file!"
}

"TEST: Package should contain install/uninstall scripts"
Add-Type -assembly "system.io.compression.filesystem"
$zip = [IO.Compression.ZipFile]::OpenRead("$pwd\launchy.$version.nupkg")
# Write-Host $zip.Entries.FullName
Write-Host $zip.Entries.Count
if ($zip.Entries.Count -ne 6) {
  Write-Error "FAIL: Wrong count in nupkg!"
}
$zip.Dispose()

"TEST: Installation of package should work"
. choco install -y launchy --pre -source . -version $version

"TEST: Uninstallation of package should work"
. choco uninstall -y launchy --pre -source .

"TEST: Finished"