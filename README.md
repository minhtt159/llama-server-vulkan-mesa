# llama-server-vulkan-mesa

`ghcr.io/ggml-org/llama.cpp:server-vulkan-<build>` plus Mesa from the
[kisak-mesa PPA](https://launchpad.net/~kisak/+archive/ubuntu/kisak-mesa). Nothing else changes.

Why: the stock image is Ubuntu 26.04 with Mesa 26.0.x. Mesa >= 26.1 roughly doubles llama.cpp
Vulkan decode on Intel Battlemage (Arc B580: `qwen3:8b` 29.8 -> 61.0 tok/s, same GGUF, same
ggml build - [ggml-org/llama.cpp#27777](https://github.com/ggml-org/llama.cpp/discussions/27777);
Phoronix B580 Mistral-7B Q8 14.6 -> 47.6). The driver lives in the image, not on the node, so
the fix is an image.

Tags on `ghcr.io/minhtt159/llama-server-vulkan-mesa`:

- `b<N>` - llama.cpp build N (same as upstream's suffix), with whatever kisak Mesa was current at build time
- `b<N>-mesa<ver>` - the same image, pinned by both
- `latest`

Renovate bumps `ARG LLAMA_BUILD` in the Dockerfile; every merge rebuilds and republishes. amd64 only.

```bash
docker run --rm --device /dev/dri -p 8080:8080 -v llama:/root/.cache/llama.cpp \
  ghcr.io/minhtt159/llama-server-vulkan-mesa:latest \
  -hf unsloth/Qwen3.5-9B-GGUF:Q4_K_M -ngl 99 -fa on -c 16384 --metrics
```
