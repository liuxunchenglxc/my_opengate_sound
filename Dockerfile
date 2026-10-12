FROM ghcr.io/void-linux/void-glibc:20261001r1

RUN xbps-install -Suy git uv bash curl iproute2 \
    libxcb libglvnd glib \
    libflac-devel \
    && xbps-remove -Oo

# COPY requirements.txt .
# RUN uv pip install --system --break-system-packages --no-cache-dir -r requirements.txt

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    git fetch --depth 1 https://github.com/savageogre/opengate && \
    cd opengate && \
    cargo build --release --features flac && \
    cp target/release/opengate /usr/local/bin/opengate && \
    opengate ./beats/meditation_delta.yaml -o meditation_delta.flac && \
    cd .. && \
    rm -rf opengate

WORKDIR /workspace