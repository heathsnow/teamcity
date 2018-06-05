$download_url = 'http://artrepo.daptiv.com:8081/artifactory/bins-local/KB973544_x64.exe'

(New-Object System.Net.WebClient).DownloadFile($download_url, 'C:\\Windows\\Temp\\KB973544_x64.exe')
Start-Process -FilePath 'C:\\Windows\\Temp\\KB973544_x64.exe' -ArgumentList "/q" -NoNewWindow -Wait
