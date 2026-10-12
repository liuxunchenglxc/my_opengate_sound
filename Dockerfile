FROM ghcr.io/void-linux/void-glibc:20261001r1

RUN xbps-install -Suy git uv bash curl iproute2 \
    libxcb libglvnd glib \
    libflac-devel \
    base-devel \
    openssl-devel \
    pkg-config \
    tar gzip \
    && xbps-remove -Oo

# COPY requirements.txt .
# RUN uv pip install --system --break-system-packages --no-cache-dir -r requirements.txt

# add cargo to path
ENV PATH=/root/.cargo/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    git clone --depth 1 https://github.com/savageogre/opengate.git && \
    curl -L "https://github.com/rhasspy/piper/releases/download/2023.11.14-2/piper_linux_x86_64.tar.gz" -o piper_linux_x86_64.tar.gz && \
    tar -xzf piper_linux_x86_64.tar.gz && \
    mv piper /usr/local/bin/piper && \
    rm piper_linux_x86_64.tar.gz && \
    cd opengate && \
    cargo build --release --features flac && \
    ls -al target/release && \
    cp target/release/opengate /usr/local/bin/opengate && \
    opengate-download-models --all && \
    opengate ./beats/meditation_delta.yaml -o meditation_delta.flac && \
    opengate ./openstates/001_liminal_state.yaml -o liminal_state.flac && \
    cd .. && \
    rm -rf opengate

WORKDIR /workspace