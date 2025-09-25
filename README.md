# caddy-forge

[简体中文](README.zh-cn.md)

A custom Caddy image with useful plugins, built automatically via GitHub Actions.

### Features

-   **Automated Updates**: Weekly workflow checks for new versions of Caddy and all included plugins. If updates are found, it automatically builds and pushes a new image.
-   **Curated Plugins**: Includes plugins for DNS challenges, response caching, and security.
-   **Published to GHCR**: Images are available on the GitHub Container Registry.

## Included Plugins

-   **[caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)**: Solves ACME DNS-01 challenges using Cloudflare for wildcard certificates.
-   **[caddyserver/cache-handler](https://github.com/caddyserver/cache-handler)**: A powerful middleware for caching responses.
-   **[greenpau/caddy-security](https://github.com/greenpau/caddy-security)**: Provides authentication, authorization, and access control features.

## Usage

### 1. Pull the Image

```bash
podman pull ghcr.io/yuzjing/caddy-forge:latest
```

### 2. Run the Container

```bash
# Create directories and a Caddyfile
mkdir -p ./caddy/{config,data}
touch ./caddy/Caddyfile

# Run the container with your Cloudflare token
podman run -d \
    --name caddy \
    --restart unless-stopped \
    -p 80:80 \
    -p 443:443 \
    -p 443:443/udp \
    -v $(pwd)/caddy/Caddyfile:/etc/caddy/Caddyfile \
    -v $(pwd)/caddy/data:/data \
    -e CLOUDFLARE_API_TOKEN="your_cloudflare_api_token" \
    ghcr.io/yuzjing/caddy-forge:latest
```
_Note: For production, consider using a `.env` file instead of passing secrets directly._

### 3. Example Caddyfile

```caddy
{
    # Use Cloudflare for ACME DNS challenges
    acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

your.domain.com {
    # Example: Block an IP address
    security {
        block ip 192.0.2.1
    }

    # Example: Cache static assets for 2 hours
    route /static/* {
        cache {
            expire 2h
        }
    }

    reverse_proxy my-backend-service:8080
}
```

## Customization

Fork this repository to build your own image.

1.  **Fork the repository.**
2.  Edit the `Dockerfile` to add or remove `--with` plugin lines.
3.  Update `versions.yml` to match the plugins in your `Dockerfile`.
4.  Push changes to your `main` branch. The Action will build and push the image to your own GHCR.
