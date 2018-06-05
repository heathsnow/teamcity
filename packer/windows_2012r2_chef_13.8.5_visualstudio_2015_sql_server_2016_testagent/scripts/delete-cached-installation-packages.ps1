Write-Host 'Delete cached installation packages'
Remove-Item C:\\chef\\cache\\* -include *.iso
Remove-Item C:\\chef\\cache\\* -include *.zip
