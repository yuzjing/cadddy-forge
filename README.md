# caddy-forge

[![Build Custom Caddy Image](https://github.com/yuzjing/cadddy-forge/actions/workflows/build-caddy-image.yml/badge.svg)](https://github.com/yuzjing/cadddy-forge/actions/workflows/build-caddy-image.yml)

This repository contains an automated setup to build a custom, feature-rich [Caddy](https://caddyserver.com/) server image using GitHub Actions. The resulting image is pushed to GitHub Container Registry (GHCR) and is ready for use with Docker or Podman.

The primary goal is to create a personalized Caddy instance "forged" with a specific set of plugins required for my personal projects.

## Included Plugins

This Caddy image is compiled with the following plugins to extend its core functionality:

- **[caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)**
  - Enables Caddy to use Cloudflare's DNS for solving ACME DNS-01 challenges. Essential for obtaining wildcard SSL/TLS certificates without exposing port 80.

- **[caddyserver/cache-handler](https://github.com/caddyserver/cache-handler)**
  - A powerful response caching middleware. Great for improving performance by caching static assets or API responses at the edge.

- **[greenpau/caddy-security](https://github.com/greenpau/caddy-security)**
  - A comprehensive security plugin providing features like IP filtering, GeoIP filtering, and more advanced authentication methods.

- **[caddyserver/transform-encoder](https://github.com/caddyserver/transform-encoder)**
  - An encoding module that can modify response bodies on the fly, for example, to inject scripts or replace text.

## Usage

### 1. Pull the Image

The image is publicly available on GHCR. You can pull it using Podman or Docker.

```bash
# Replace 'latest' with a specific version if needed
podman pull ghcr.io/yuzjing/caddy-forge:latest
```

### 2. Run the Container

Here is a sample `podman run` command. You will need to provide your `Caddyfile` and a Cloudflare API token.

```bash
# Create directories for configuration and data
mkdir -p ./caddy/config
mkdir -p ./caddy/data
touch ./caddy/Caddyfile

# Set your Cloudflare API Token as an environment variable
export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token_here"

# Run the container
podman run -d \
    --name caddy \
    --restart unless-stopped \
    -p 80:80 \
    -p 443:443 \
    -p 443:443/udp \
    -v $(pwd)/caddy/config:/etc/caddy \
    -v $(pwd)/caddy/data:/data \
    -e CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN} \
    ghcr.io/yuzjing/caddy-forge:latest
```

### Example `Caddyfile`

Remember to configure the `acme_dns` global option to use the Cloudflare plugin.

```caddy
{
    # Use the Cloudflare DNS plugin for certificate acquisition
    acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

your.domain.com {
    # Your site configuration here
    reverse_proxy my-backend-service:8080
}
```

## Customization

You can easily fork this repository to build your own custom Caddy image:
1.  **Fork the repository.**
2.  **Edit the `Dockerfile`**: Add or remove plugins in the `RUN xcaddy build ...` command.
3.  **Push the changes**: GitHub Actions will automatically build and push the new image to your own container registry.
