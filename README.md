# sparkle.internal.nekopon.pl

	OS: Arch Linux x86_64 
	Host: OptiPlex 9020 00 
	Kernel: 5.15.14-hardened1-1-hardened 
	Uptime: 1 hour, 20 mins 
	Packages: 496 (pacman) 
	Shell: bash 5.1.16
	CPU: Intel i5-4590 (4) @ 3.700GHz 
	GPU: Intel HD Graphics 
	Memory: 1111MiB / 7857MiB 

## SSL

cron every month calls script containing

	certbot certonly \
	  --must-staple \
	  --dns-ovh \
	  --dns-ovh-credentials /root/certbot/ovh.ini \
	  --dns-ovh-propagation-seconds 10 \
	  --email nat@nekopon.pl \
	  --server https://acme-v02.api.letsencrypt.org/directory \
	  --agree-tos \
	  --manual-public-ip-logging-ok \
	  --key-type ecdsa \
	  --force-renewal \
	  -d "*.internal.nekopon.pl"

## Security

System is hardened with recommendations from [Madaidan's Insecurities](https://madaidans-insecurities.github.io/guides/linux-hardening.html)  
I have also copied some config snippets from [Zanthed's repos](https://github.com/zanthed)  

UEFI SecureBoot is enabled by generating and signing a unified kernel image using [sbupdate](https://github.com/andreyv/sbupdate)  

I don't have hardened-malloc yet because it's crashing php-fpm - I'll probably have to mess with some build flags.

## Storage

2x 250GB Crucial MX500 SSDs running in a mdadm RAID1 array.  
Array is LUKS encrypted but currently I have to plug keyboard and input passphrase blindly because systemd-cryptenroll doesn't support ancient TPM 1.2 yet and I'm too lazy to figure out how to do it manually.

## unbound-adblock

Unbound is configured as recursive resolver with cron calling https://github.com/lepiaf/adblock-unbound every 8 hours.

## Photoprism + NextCloud

Both services are "integrated" by adding photoprism user to nextcloud group and pointing Photoprism OriginalsPath at NextCloud data directory.

## nginx

https://github.com/tomwassenberg/certbot-ocsp-fetcher + https://github.com/GrapheneOS/nginx-rotate-session-ticket-keys
