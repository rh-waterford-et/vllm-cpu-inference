#!/bin/bash


export ZENDNN_TENSOR_POOL_LIMIT=1024
export ZENDNN_MATMUL_ALGO=FP32:4,BF16:0
export ZENDNN_PRIMITIVE_CACHE_CAPACITY=1024
export ZENDNN_WEIGHT_CACHING=1
export VLLM_PLUGINS="torch==2.6.0"
# for 64 core 256GB RAM a higher value here crashes - need to investigate
export VLLM_CPU_KVCACHE_SPACE=50
# use for 192 core
# export VLLM_CPU_OMP_THREADS_BIND="0-47|48-91|92-127|128-191"
# use for 64 core
export VLLM_CPU_OMP_THREADS_BIND="0-15|16-31|32-47|48-63"
export HUGGING_FACE_HUB_TOKEN=$(cat ~/.cache/huggingface/token)

MODEL=$1

vllm serve ${MODEL} --dtype=bfloat16 --trust_remote_code --host 0.0.0.0 --port 8000 --max-log-len 0 --max-num-seqs 256 --enable-chunked-prefil --enable-prefix-caching -tp 4

