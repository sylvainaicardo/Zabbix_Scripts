<#
L'API de Zabbix, basée sur le standard JSON-RPC 2.0 peux bien sur etre intérrogée aussi avec Powershell.

 Ci-dessous un script montrant le principe d'interrogation de l'API, en recuperant certaines infos.

 Vous devez renseigner un compte (<my_zabbix_account>) avec au minimum les droits de lecture sur Zabbix, et le nom ou l'ip du serveur Front Web (<zabbix_frontweb_server>).
#>

### Query Zabbix Through native zabbix json api
 
    $credential = Get-Credential -Credential "my_zabbix_account"
 
$baseurl = 'https://<name_or_ip_of_front_server>/zabbix'
$params = @{
    body =  @{
        "jsonrpc"= "2.0"
        "method"= "user.login"
        "params"= @{
            "user"= $credential.UserName
            "password"= $credential.GetNetworkCredential().Password
        }
        "id"= 1
        "auth"= $null
    } | ConvertTo-Json
    uri = "$baseurl/api_jsonrpc.php"
    headers = @{"Content-Type" = "application/json"}
    method = "Post"
}
 
[System.Net.ServicePointManager]::SecurityProtocol = 'tls12'
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
 
$result = Invoke-WebRequest @params -UseBasicParsing
 
 
 
$params.body = @{
    "jsonrpc"= "2.0"
    "method"= "host.get"
    "params"= @{
        output = "extend"
        selectFunctions = "extend"
        selectLastEvent = "extend"
        selectGroups = "extend"
        selectHosts = "extend"
    }
    auth = ($result.Content | ConvertFrom-Json).result
    id = 2
} | ConvertTo-Json
 
$result = Invoke-WebRequest @params -UseBasicParsing
$result = $result.Content | ConvertFrom-Json