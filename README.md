# psgraph-dns-cache

An example of using PSGraph. I am using the Windows DNS cache as source data.

The write-up of this is here:

[https://ja.mesmontgomery.co.uk/2019/04/visualising-your-dns-cache-with-psgraph/](https://ja.mesmontgomery.co.uk/2019/04/visualising-your-dns-cache-with-psgraph/)

Files:

* psgraph-proto-1.ps1  
Experimenting with manually creating a DNS graph directly.
* WalkDNSCache-loop-proto.ps1  
Prototyping the loop to walk the DNS cache entries.
* WalkDNSCache-psgraph-entry.ps1  
The script that walks the DNS cache and produces the graph.