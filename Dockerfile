# llama-server (Vulkan) with a Battlemage-fast Mesa.
#
# The stock ghcr.io/ggml-org/llama.cpp:server-vulkan image is Ubuntu 26.04, whose
# archive Mesa (26.0.x) is on the slow side of the Intel Xe2 cliff: Mesa >= 26.1 roughly
# doubles llama.cpp Vulkan decode on Arc B580/B70. Only mesa-vulkan-drivers is swapped;
# everything else (llama-server, entrypoint, env) is upstream's.
ARG LLAMA_BUILD=b11610
FROM ghcr.io/ggml-org/llama.cpp:server-vulkan-${LLAMA_BUILD}

# ponytail: add-apt-repository pulls python for a one-shot PPA add; swap for a hand-written
# sources entry + keyring if image size ever matters.
RUN apt-get update \
 && apt-get install -y --no-install-recommends software-properties-common \
 && add-apt-repository -y ppa:kisak/kisak-mesa \
 && apt-get install -y --no-install-recommends mesa-vulkan-drivers \
 && apt-get purge -y --auto-remove software-properties-common \
 && rm -rf /var/lib/apt/lists/*
