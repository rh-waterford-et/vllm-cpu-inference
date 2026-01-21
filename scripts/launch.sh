#!/bin/bash

export TORCHINDUCTOR_FREEZING=0 
export ZENTORCH_LINEAR=1 
export USE_ZENDNN_MATMUL_DIRECT=1 
export USE_ZENDNN_SDPA_MATMUL_DIRECT=1 
export ZENDNNL_MATMUL_WEIGHT_CACHE=1 
export ZENDNNL_MATMUL_ALGO=1

# vLLM CPU settings
export VLLM_CPU_KVCACHE_SPACE=90        # GB for KV cache
export VLLM_CPU_OMP_THREADS_BIND=0-95   # CPU cores to use
export HUGGING_FACE_HUB_TOKEN=$(cat ~/.cache/huggingface/token)
export VLLM_PLUGINS="torch==2.9.1"

# export LD_PRELOAD=/usr/local/lib/libtcmalloc_minimal.so.4:/usr/lib64/libomp.so:$LD_PRELOAD

MODEL=$1

vllm serve ${MODEL} --dtype=bfloat16 --trust_remote_code --host 0.0.0.0 --port 8000 --max-log-len 0 --max-num-seqs 256 --enable-chunked-prefil --enable-prefix-caching 
