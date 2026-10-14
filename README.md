# llama-server-vulkan-mesa

`ghcr.io/ggml-org/llama.cpp:server-vulkan-<build>` plus Mesa from the
[kisak-mesa PPA](https://launchpad.net/~kisak/+archive/ubuntu/kisak-mesa). Nothing else changes.

Why: the stock image is Ubuntu 26.04 with Mesa 26.0.x. Mesa >= 26.1 roughly doubles llama.cpp
Vulkan decode on Intel Battlemage. The driver lives in the image, not on the node, so the fix is
an image.

Measured on an Arc B580 (Talos, kernel 6.18, `xe`), `unsloth/Qwen3.5-9B-GGUF:Q4_K_M`,
`-ngl 99 -fa on -c 8192 -np 1`, 1530-token prompt, 256 greedy tokens, 3 runs each (all identical):

| Image (llama.cpp b11610) | Mesa | prompt tok/s | gen tok/s |
|---|---|---|---|
| `ggml-org/llama.cpp:server-vulkan` (stock) | 26.0.8 | 1431 | 25.4 |
| **this image** | 26.2.4 (kisak) | 1477 | **53.7** |
| `ggml-org/llama.cpp:server-intel` (SYCL, no Mesa) | - | 2045 | 63.2 |

Same ggml build, same GGUF, same flags: Mesa alone is 2.1x on decode. The SYCL image is faster
still and needs no rebuild, but is 4.3 GB and needs a >= 10 GiB memory limit at model load
(8 GiB died with SIGBUS). See
[ggml-org/llama.cpp#27777](https://github.com/ggml-org/llama.cpp/discussions/27777) for the
independent B580 Mesa measurement this reproduces.

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
