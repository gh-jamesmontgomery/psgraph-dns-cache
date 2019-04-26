# Import Module
Import-Module PSGraph
$colors = @{
    1 = 'RED'
    2 = 'Blue'
    3 = 'green'
}


$strWWW = "www"
graph folders @{rankdir='TB'} {
    node root
    node com
    edge -from com -to root

    node uk
    edge -from uk -to root
    node co.uk @{label={"co"}}
    edge -from co.uk -to uk
    node bbc.co.uk @{label={"bbc"}; color=$colors[2]}
    edge -from bbc.co.uk -to co.uk
    node cnn.com @{label={"cnn"}}
    edge -from cnn.com -to com
    node www.cnn.com @{label={$strWWW}; color=$colors[2]}
    edge -from www.cnn.com -to cnn.com
    node google.com @{label={"google"}; color=$colors[2]}
    edge -from google.com -to com
    node www.google.com @{label={$strWWW}; color=$colors[3]}
    node www2.google.com @{label={"www2"}; color=$colors[3]}
    edge -from www.google.com -to google.com
    edge -from www2.google.com -to google.com
    edge -from www2.google.com -to www.google.com -Attributes @{label='CNAME'}
    node 138.197.253.21
    edge -from www.google.com -to 138.197.253.21
    edge -from com -to www.cnn.com
} | Export-PSGraph -DestinationPath "$env:TEMP\dnscache-proto-temp.png"
Start-Process "$env:TEMP\dnscache-proto-temp.png"