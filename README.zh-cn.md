# caddy-forge

[English](README.md)


这个仓库包含一个自动化配置，用于通过 GitHub Actions 构建一个功能丰富的自定义 [Caddy](https://caddyserver.com/) 服务器镜像。构建完成的镜像会被推送到 GitHub Container Registry (GHCR)，可以直接通过 Docker 或 Podman 使用。

项目的主要目标是创建一个“锻造”了特定插件集的个性化 Caddy 实例，以满足我个人项目的需求。

## 包含的插件

这个 Caddy 镜像是用以下插件编译的，以扩展其核心功能：

- **[caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)**
  - 让 Caddy 能够使用 Cloudflare 的 DNS 来完成 ACME DNS-01 质询。这对于获取泛域名 SSL/TLS 证书而无需暴露 80 端口至关重要。

- **[caddyserver/cache-handler](https://github.com/caddyserver/cache-handler)**
  - 一个强大的响应缓存中间件。非常适合通过在边缘缓存静态资源或 API 响应来提升性能。

- **[greenpau/caddy-security](https://github.com/greenpau/caddy-security)**
  - 一个全面的安全插件，提供 IP 过滤、地理位置（GeoIP）过滤以及更高级的身份验证方法等功能。

- **[caddyserver/transform-encoder](https://github.com/caddyserver/transform-encoder)**
  - 一个可以在传输过程中动态修改响应体的编码模块，例如注入脚本或替换文本。

## 如何使用

### 1. 拉取镜像

该镜像已公开发布在 GHCR 上。你可以使用 Podman 或 Docker 拉取。

```bash
# 如果需要，可以将 'latest' 替换为特定版本
podman pull ghcr.io/yuzjing/caddy-forge:latest
```

### 2. 运行容器

这是一个 `podman run` 的示例命令。你需要提供自己的 `Caddyfile` 和一个 Cloudflare API 令牌。

```bash
# 创建用于配置和数据的目录
mkdir -p ./caddy/config
mkdir -p ./caddy/data
touch ./caddy/Caddyfile

# 将你的 Cloudflare API 令牌设置为环境变量
export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token_here"

# 运行容器
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

### `Caddyfile` 示例

请记住配置 `acme_dns` 全局选项来使用 Cloudflare 插件。

```caddy
{
    # 使用 Cloudflare DNS 插件来申请证书
    acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

your.domain.com {
    # 在这里填写你的网站配置
    reverse_proxy my-backend-service:8080
}
```

## 自定义

你可以轻松地 fork 这个仓库来构建你自己的自定义 Caddy 镜像：
1.  **Fork 本仓库。**
2.  **编辑 `Dockerfile`**: 在 `RUN xcaddy build ...` 命令中添加或删除插件。
3.  **推送更改**: GitHub Actions 将会自动构建新的镜像并将其推送到你自己的容器仓库中。
