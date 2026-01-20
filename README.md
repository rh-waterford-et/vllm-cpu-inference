# Overview 

This guide provides step-by-step instructions for compiling vLLM from
source for **AMD-EPYC** bare metal CPU only servers.

**NB** this is specifically for Fedora/Rhel based systems (using dnf). 

It includes instructions for building with ZenDNN support.

For Debian builds please follow this [guide](https://docs.vllm.ai/en/stable/getting_started/installation/cpu/) 

## 1.Prerequisites (System Dependencies)

First, install all necessary system-level packages, including
development tools, compilers, and required libraries.

\# Install essential build tools

```bash
sudo dnf install git cmake make autoconf binutils gcc g++
```

\# Install required libraries for vLLM and Python

```bash
sudo dnf install numactl numactl-devel python-devel
```

## 2. Environment Setup

We will use uv for package management and a specific compiler toolset.

### 2.1. Install uv

\# Install the uv Python package manager:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Note: You may need to restart your shell or source your .bashrc/.zshrc
file after this step.

### 2.2. Create & Activate Virtual Environment

Create a new virtual environment using Python 3.12 and activate it.

\# Create the environment

```bash
uv venv --python 3.12 --seed
```

\# Activate the environment

```bash
source .venv/bin/activate
```

## 3. Build and Install Dependencies

This process requires manually building libkineto and installing a
specific ZenDNN-enabled version of PyTorch.

### 3.1. Install libkineto

\# Check out the repo and its submodules

```bash
git clone --recursive https://github.com/pytorch/kineto.git

cd kineto/libkineto
```

\# Build libkineto with cmake

```bash
mkdir build && cd build

cmake ..

make

sudo make install
```

\# Return to your original project directory

```bash
cd ../../..
```

### 3.2. Install ZenDNN-enabled PyTorch

\# Uninstall any existing zentorch

```bash
uv pip uninstall zentorch
```

\# Install ZenDNN-enabled PyTorch (v2.6.0)

```bash
uv pip install torch==2.9.1 --index-url https://download.pytorch.org/whl/cpu
```

\# Install ZenDNN

```bash
uv pip install zentorch==5.1.0
```

## 4. Build vLLM from Source

Now, we can clone and build the vLLM project itself. (N.B. for ZenDNN 5.1.0 we need to use vLLM 0.9.2)

\# Clone the vLLM repository


```bash
git clone https://github.com/vllm-project/vllm.git vllm_source

cd vllm_source

git checkout v0.13.0
```

\# Install vLLM build-time and CPU runtime dependencies


```bash
uv pip install -r requirements/cpu-build.txt --torch-backend cpu --index-strategy unsafe-best-match

uv pip install -r requirements/cpu.txt --torch-backend cpu --index-strategy unsafe-best-match
```

\# Build vLLM, targeting the CPU

```bash
VLLM_TARGET_DEVICE=cpu uv pip install . --no-build-isolation

# if you get aimv2 error already in use install the following

uv pip install "transformers<4.54.0"
```

## 5. Runtime Configuration

Before running the vLLM server, you must export several environment
variables to configure ZenDNN and vLLM performance.

\# ZenDNN settings


```bash
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
```

## 6. Usage Example

Finally, we can run the vLLM server. Ensure your environment variables
(from Step 5) are set in your current shell.

**N.B.** - There is a script provided in this repo (scripts/launch.sh) that handles all the envars and launches vllm

```bash
# parameters  provided by AMD engineers
# serve:
vllm serve meta-llama/Llama-3.2-1B-Instruct --dtype=bfloat16 --trust_remote_code --host 0.0.0.0 --port 8000 --max-log-len 0 --max-num-seqs 256 --enable-chunked-prefil --enable-prefix-caching 

# test:
vllm bench serve --dataset-name random --model meta-llama/Llama-3.2-1B-Instruct --host 0.0.0.0 --port 8000 --num-prompts 100 --random-prefix-len 512 --random-input-len 512 --random-output-len 512
```

## 7. Use GuideLLM for benchmarking

```bash
guidellm benchmark --target http://<host>/v1 --model meta-llama/Llama-3.2-1B-Instruct --data "prompt_tokens=128,output_tokens=256" --rate-type sweep --max-seconds 90
```

## 8. Curl Test

```bash
curl -X POST http://<route-url>/v1/chat/completions   -H "Content-Type: application/json"   -d '{
    "model": "meta-llama/Llama-3.2-1B-Instruct",
    "messages": [
      {
        "role": "user",
        "content": "<prompt>"
      }
    ]
  }'
```

## 9. Fine tuning (optional)

Execute the follow commands 

```bash
# interrupt noise elimination
sudo systemctl disable --now irqbalance

# frequency stability
sudo systemctl enable --now tuned
sudo tuned-adm profile throughput-performance
```
