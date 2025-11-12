# vLLM Build from source

## Install and build kineto

```bash
# Check out repo and sub modules
git clone --recursive https://github.com/pytorch/kineto.git
# Build libkineto with cmake
cd kineto/libkineto
mkdir build && cd build
cmake ..
make
make install
```

## Install libnuma

```bash
sudo dnf install numactl numactl-devel
```

## Setup env

```bash
uv venv --python 3.12 --seed
source .venv/bin/activate
git clone https://github.com/vllm-project/vllm.git vllm_source
cd vllm_source
```

## Install ZenDNN

```bash
pip uninstall zentorch
# from blog torch==2.6.0 is recommended
pip install torch==2.7.0 --index-url https://download.pytorch.org/whl/cpu
pip install zentorch==5.1.0
```

## Build vLLM

```bash
uv pip install -r requirements/cpu-build.txt --torch-backend cpu 
uv pip install -r requirements/cpu.txt --torch-backend cpu

VLLM_TARGET_DEVICE=cpu uv pip install . --no-build-isolation

export ZENDNN_TENSOR_POOL_LIMIT=1024
export ZENDNN_MATMUL_ALGO=FP32:4,BF16:0
export ZENDNN_PRIMITIVE_CACHE_CAPACITY=1024
export ZENDNN_WEIGHT_CACHING=1

export VLLM_CPU_KVCACHE_SPACE=90
export VLLM_CPU_OMP_THREADS_BIND='0-31|32-63'
export HUGGING_FACE_HUB_TOKEN=xxx

# not so sure about this setting
# export VLLM_PLUGINS="torch==2.7.0"

vllm serve meta-llama/Llama-3.2-1B-Instruct -tp 2 

```

## Install and Build gperftools

```bash

git clone https://github.com/gperftools/gperftools

cd gperftools

./configure
make
sudo make install

# check the documentation to link
```

## Use GuideLLM for benchmarking

```bash
pip install git+https://github.com/vllm-project/guidellm.git

# execute guidllm
guidellm benchmark --target http://<inference-endpoint>/v1 --model meta-llama/Llama-3.2-1B-Instruct --data "prompt_tokens=512,output_tokens=128" --rate-type sweep --max-seconds 240
```
