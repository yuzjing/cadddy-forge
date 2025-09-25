# caddy-forge

[English](README.md)

一个集成了实用插件的自定义 Caddy 镜像，通过 GitHub Actions 自动构建。

### 核心特性

-   **自动更新**: 工作流每周检查 Caddy 及所有插件的新版本。若有更新，则自动构建并推送新版镜像。
-   **精选插件**: 包含了 DNS 质询、响应缓存和安全相关的常用插件。
-   **发布至 GHCR**: 镜像托管于 GitHub 容器注册中心 (GHCR)。

## 包含插件

-   **[caddy-dns/cloudflare](https://github.com/caddy-dns/cloudflare)**: 使用 Cloudflare 完成 ACME DNS-01 质询，以获取泛域名证书。
-   **[caddyserver/cache-handler](https://github.com/caddyserver/cache-handler)**: 功能强大的响应缓存中间件。
-   **[greenpau/caddy-security](https://github.com/greenpau/caddy-security)**: 提供身份验证、授权和访问控制等安全功能。

## 使用方法

### 1. 拉取镜像

```bash
podman pull ghcr.io/yuzjing/caddy-forge:latest
```

### 2. 运行容器

```bash
# 创建目录和 Caddyfile 文件
mkdir -p ./caddy/{config,data}
touch ./caddy/Caddyfile

# 运行容器，并传入你的 Cloudflare 令牌
podman run -d \
    --name caddy \
    --restart unless-stopped \
    -p 80:80 \
    -p 443:443 \
    -p 443:443/udp \
    -v $(pwd)/caddy/Caddyfile:/etc/caddy/Caddyfile \
    -v $(pwd)/caddy/data:/data \
    -e CLOUDFLARE_API_TOKEN="你的_cloudflare_api_token" \
    ghcr.io/yuzjing/caddy-forge:latest
```
_提示：生产环境中，建议使用 `.env` 文件来管理敏感信息。_

### 3. Caddyfile 示例

```caddy
{
    # 使用 Cloudflare 进行 ACME DNS 质询
    acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}

your.domain.com {
    # 示例：阻止特定 IP 地址的访问
    security {
        block ip 192.0.2.1
    }

    # 示例：缓存静态资源 2 小时
    route /static/* {
        cache {
            expire 2h
        }
    }

    reverse_proxy my-backend-service:8080
}
```

## 自定义

Fork 本仓库以构建你自己的镜像。

1.  **Fork 本仓库。**
2.  编辑 `Dockerfile`，增删 `--with` 插件行。
3.  更新 `versions.yml` 文件，使其与 `Dockerfile` 中的插件列表保持一致。
4.  推送更改到你的 `main` 分支。Actions 将自动构建镜像并推送到你自己的 GHCR。```