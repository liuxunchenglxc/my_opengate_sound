# ==============================================================================
# 阶段一：构建者环境
# ==============================================================================
FROM ghcr.io/void-linux/void-glibc:20261001r1 AS builder

# 安装编译所需的依赖基础包
RUN xbps-install -Suy git bash curl \
    libxcb libglvnd glib \
    libflac-devel \
    base-devel \
    openssl-devel \
    pkg-config \
    tar gzip \
    && xbps-remove -Oo

# 注入 Cargo 环境变量
ENV PATH=/root/.cargo/bin:$PATH

# 聚合编译与资产生成流程
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    git clone --depth 1 https://github.com/savageogre/opengate.git && \
    curl -L "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz" -o /tmp/piper.tar.gz && \
    tar -xzf /tmp/piper.tar.gz -C /opt/ && \
    cd opengate && \
    cargo build --release --features flac && \
    cp target/release/opengate /usr/local/bin/opengate && \
    cp target/release/opengate-download-models /usr/local/bin/opengate-download-models && \
    cp target/release/opengate-spectral-analysis /usr/local/bin/opengate-spectral-analysis && \
    cp target/release/opengate-tts /usr/local/bin/opengate-tts && \
    chmod +x /usr/local/bin/opengate* && \
    cd .. && \
    rm -rf opengate /tmp/*

# ==============================================================================
# 阶段二：运行时环境
# ==============================================================================
FROM ghcr.io/void-linux/void-glibc:20261001r1 AS runner

RUN xbps-install -Suy git bash libxcb libglvnd glib libflac openssl jq && \
    xbps-remove -Oo

COPY --from=builder /usr/local/bin/opengate /usr/local/bin/opengate
COPY --from=builder /usr/local/bin/opengate-download-models /usr/local/bin/opengate-download-models
COPY --from=builder /usr/local/bin/opengate-spectral-analysis /usr/local/bin/opengate-spectral-analysis
COPY --from=builder /usr/local/bin/opengate-tts /usr/local/bin/opengate-tts

COPY --from=builder /opt/piper /opt/piper
RUN ln -s /opt/piper/piper /usr/local/bin/piper && \
    ln -s /opt/piper/espeak-ng /usr/local/bin/espeak-ng && \
    ln -s /opt/piper/piper_phonemize /usr/local/bin/piper_phonemize && \
    chmod +x /usr/local/bin/piper

ENV LD_LIBRARY_PATH=/opt/piper:$LD_LIBRARY_PATH

WORKDIR /workspace