# --- 阶段一：构建自定义 Caddy ---
# 使用 builder-alpine 浮动标签，它会指向最新的 builder 镜像
FROM caddy:builder-alpine AS builder

# ... (RUN xcaddy build ... 命令不变)
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddyserver/cache-handler \
    --with github.com/greenpau/caddy-security \
    --with github.com/caddyserver/transform-encoder

# --- 阶段二：创建最终运行镜像 ---
# 使用 alpine 浮动标签，它会指向最新的 alpine 基础镜像
FROM caddy:alpine

# ... (COPY --from=builder ... 命令不变)
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
