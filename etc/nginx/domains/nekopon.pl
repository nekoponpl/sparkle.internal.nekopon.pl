upstream php-handler { server unix:/run/nextcloud/nextcloud.sock; }

upstream photoprism {
	zone photoprism 32k;
	server 127.0.0.1:2342 max_conns=4096 fail_timeout=1s;
}

# cloud.internal.nekopon.pl
server {
	listen [::1]:443 ssl http2;
	listen 443 ssl http2;
	server_name cloud.internal.nekopon.pl;

	root /usr/share/webapps/nextcloud;
	index index.php index.html /index.php$request_uri;

	include snippets/security-headers.conf;
	add_header Cross-Origin-Resource-Policy "same-origin" always;
	add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), fullscreen=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), magnetometer=(), microphone=(), midi=(), payment=(), picture-in-picture=(), publickey-credentials-get=(), screen-wake-lock=(), serial=(), sync-xhr=(), xr-spatial-tracking=()" always;
	add_header Content-Security-Policy "font-src 'self' data:; manifest-src 'self'; object-src 'none'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; frame-ancestors 'none'; block-all-mixed-content" always;
	add_header X-Frame-Options "SAMEORIGIN" always;
	add_header X-Robots-Tag "none";

	client_max_body_size 512M;
	client_body_timeout 300s;
	fastcgi_buffers 64 4K;

	fastcgi_hide_header X-Powered-By;

	# Rule borrowed from `.htaccess` to handle Microsoft DAV clients
	location = / {
		if ( $http_user_agent ~ ^DavClnt ) {
			return 302 /remote.php/webdav/$is_args$args;
		}
	}

	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	# Make a regex exception for `/.well-known` so that clients can still
	# access it despite the existence of the regex rule
	# `location ~ /(\.|autotest|...)` which would otherwise handle requests
	# for `/.well-known`.
	location ^~ /.well-known {
		# The rules in this block are an adaptation of the rules
		# in `.htaccess` that concern `/.well-known`.
		location = /.well-known/carddav { return 301 /remote.php/dav/; }
		location = /.well-known/caldav  { return 301 /remote.php/dav/; }

		location /.well-known/acme-challenge	{ try_files $uri $uri/ =404; }
		location /.well-known/pki-validation	{ try_files $uri $uri/ =404; }

		# Let Nextcloud's API for `/.well-known` URIs handle all other
		# requests by passing them to the front-end controller.
		return 301 /index.php$request_uri;
	}

	# Rules borrowed from `.htaccess` to hide certain paths from clients
	location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
	location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)				{ return 404; }
	# Ensure this block, which passes PHP files to the PHP process, is above the blocks
	# which handle static assets (as seen below). If this block is not declared first,
	# then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
	# to the URI, resulting in a HTTP 500 error response.
	location ~ \.php(?:$|/) {
		# Required for legacy support
		rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy) /index.php$request_uri;

		fastcgi_split_path_info ^(.+?\.php)(/.*)$;
		set $path_info $fastcgi_path_info;
		try_files $fastcgi_script_name =404;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $path_info;
		fastcgi_param HTTPS on;
		fastcgi_param modHeadersAvailable true;		 # Avoid sending the security headers twice
		fastcgi_param front_controller_active true;	 # Enable pretty urls
		fastcgi_pass php-handler;
		fastcgi_intercept_errors on;
		fastcgi_request_buffering off;
	}
	location ~ \.(?:css|js|svg|gif|png|jpg|ico|wasm|tflite)$ {
		try_files $uri /index.php$request_uri;
		expires 6M;		 # Cache-Control policy borrowed from `.htaccess`
		access_log off;	 # Optional: Don't log access to assets
		location ~ \.wasm$ {
			default_type application/wasm;
		}
	}
	location ~ \.woff2?$ {
		try_files $uri /index.php$request_uri;
		expires 7d;		 # Cache-Control policy borrowed from `.htaccess`
		access_log off;	 # Optional: Don't log access to assets
	}
	# Rule borrowed from `.htaccess`
	location /remote {
		return 301 /remote.php$request_uri;
	}
	location / {
		try_files $uri $uri/ /index.php$request_uri;
	}
}

# photos.internal.nekopon.pl
server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	server_name photos.internal.nekopon.pl;

	root /var/empty;

	include snippets/security-headers.conf;
	add_header Cross-Origin-Resource-Policy "same-origin" always;
	add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), camera=(), clipboard-read=(), clipboard-write=(), display-capture=(), document-domain=(), encrypted-media=(), fullscreen=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), magnetometer=(), microphone=(), midi=(), payment=(), picture-in-picture=(), publickey-credentials-get=(), screen-wake-lock=(), serial=(), sync-xhr=(), xr-spatial-tracking=()" always;
	add_header Content-Security-Policy "default-src 'self'; child-src 'self' blob:; connect-src 'self' https://api.maptiler.com; font-src 'self'; img-src 'self' data:; manifest-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; form-action 'none'; frame-ancestors 'none'; block-all-mixed-content; base-uri 'none'" always;
	add_header X-Frame-Options "DENY" always;

	location / {
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header Host $host;
		proxy_pass http://photoprism;
		proxy_buffering off;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection "upgrade";
    }
}
