FROM ghcr.io/void-linux/void-glibc:20261001r1

RUN xbps-install -Suy git uv bash curl iproute2 \
    libxcb libglvnd glib \
    libflac-devel \
    base-devel \
    openssl-devel \
    pkg-config \
    tar gzip \
    jq \
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
    chmod +x /usr/local/bin/piper && \
    rm piper_linux_x86_64.tar.gz && \
    cd opengate && \
    cargo build --release --features flac && \
    ls -al target/release && \
    cp target/release/opengate /usr/local/bin/opengate && \
    cp target/release/opengate-download-models /usr/local/bin/opengate-download-models &&\
    cp target/release/opengate-spectral-analysis /usr/local/bin/opengate-spectral-analysis && \
    cp target/release/opengate-tts /usr/local/bin/opengate-tts && \
    chmod +x /usr/local/bin/opengate && \
    chmod +x /usr/local/bin/opengate-download-models && \
    chmod +x /usr/local/bin/opengate-spectral-analysis && \
    chmod +x /usr/local/bin/opengate-tts && \
    opengate --help && \
    opengate-download-models --help && \
    opengate-spectral-analysis --help && \
    opengate-tts --help && \
    curl -L -o voices.json https://huggingface.co/rhasspy/piper-voices/resolve/main/voices.json && \
    bash piper-models.sh && \
    cd .. && \
    rm -rf opengate

    
    # opengate ./beats/meditation_delta.yaml -o meditation_delta.flac && \
    # opengate ./openstates/001_liminal_state.yaml -o liminal_state.flac && \

    
    # opengate-download-models --all --short-lang en --lang en_US && \
    # opengate-download-models --all --short-lang en --lang en_GB && \
    # opengate-download-models --all --short-lang zh --lang zh_CN && \
    # opengate-download-models --all --short-lang ja --lang ja_JP && \

WORKDIR /workspace