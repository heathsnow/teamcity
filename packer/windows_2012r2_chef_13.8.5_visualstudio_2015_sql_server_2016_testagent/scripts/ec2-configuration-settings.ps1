[xml]$xmlDoc = Get-Content "C:\Program Files\Amazon\Ec2ConfigService\Settings\Config.xml"

foreach ($element in $xmlDoc.Ec2ConfigurationSettings.Plugins.Plugin)
{
    if ($element.Name -eq "Ec2SetComputerName") {
        $element.State = "Enabled"
    }
    if ($element.Name -eq "Ec2HandleUserData") {
        $element.State = "Enabled"
    }
}

$xmlDoc.Save("C:\Program Files\Amazon\Ec2ConfigService\Settings\Config.xml")
