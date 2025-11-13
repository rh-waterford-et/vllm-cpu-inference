This guide provides step-by-step instructions for compiling vLLM from
source for a CPU-only environment, specifically on a Fedora-based system
(using dnf). It includes instructions for building with ZenDNN support.

## 1.Prerequisites (System Dependencies)

First, install all necessary system-level packages, including
development tools, compilers, and required libraries.

\# Install essential build tools

```bash
sudo dnf install git cmake

sudo dnf group install "Development Tools"
```

[//]: # (this won't work in rhel or fedora based systems)

[//]: # (Install specific compiler toolchain GCC 12 and LLVM)

[//]: # (sudo dnf install -y gcc-12 g++-12 llvm-toolset)

\# Install required libraries for vLLM and Python

```bash
sudo dnf install numactl numactl-devel python-devel
```

## 2. Environment Setup

We will use uv for package management and a specific compiler toolset.

### 2.1. Install uv

\# Install the uv Python package manager:

```bash
curl -LsSf https://astral.sh/uv/install.sh \| sh
```

Note: You may need to restart your shell or source your .bashrc/.zshrc
file after this step.

### 2.2. Activate Compiler Toolset

To ensure vLLM compiles with the correct C++/GCC version, activate the
gcc-toolset-12:

\# This command starts a new shell session with the toolset active

```bash
scl enable gcc-toolset-12 bash
```

\# You can verify the version after

```bash
gcc --version
```

### 2.3. Create & Activate Virtual Environment

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

\# Install ZenDNN-enabled PyTorch (v2.7.0)

```bash
uv pip install torch==2.7.0 --index-url https://download.pytorch.org/whl/cpu
```

\# Install ZenDNN

```bash
uv pip install zentorch==5.1.0
```

## 4. Build vLLM from Source

Now, we can clone and build the vLLM project itself.

\# Clone the vLLM repository


```bash
git clone https://github.com/vllm-project/vllm.git vllm_source

cd vllm_source
```

\# Install vLLM build-time and CPU runtime dependencies


```bash
uv pip install -r requirements/cpu-build.txt --torch-backend cpu

uv pip install -r requirements/cpu.txt --torch-backend cpu
```

\# Build vLLM, targeting the CPU

```bash
VLLM_TARGET_DEVICE=cpu uv pip install . --no-build-isolation

```
## 5. Runtime Configuration

Before running the vLLM server, you must export several environment
variables to configure ZenDNN and vLLM performance.

\# ZenDNN settings


```bash
export ZENDNN_TENSOR_POOL_LIMIT=1024

export ZENDNN_MATMUL_ALGO=FP32:4,BF16:0

export ZENDNN_PRIMITIVE_CACHE_CAPACITY=1024

export ZENDNN_WEIGHT_CACHING=1
```

\# vLLM CPU settings


```bash
export VLLM_CPU_KVCACHE_SPACE=90

export VLLM_CPU_OMP_THREADS_BIND="0-15\|16-31\|32-47\|48-63"
```

\# Set the Hugging Face token


```bash
export HUGGING_FACE_HUB_TOKEN=xxx
```

## 6. Usage Example

Finally, we can run the vLLM server. Ensure your environment variables
(from Step 5) are set in your current shell.

```bash
# serve:
vllm serve meta-llama/Llama-3.2-1B-Instruct --dtype=bfloat16 --trust_remote_code --host 0.0.0.0 --port 8000 --max-log-len 0 --max-num-seqs 256 --enable-chunked-prefil --enable-prefix-caching -tp 4

 
# test:
vllm bench serve --dataset-name random --model meta-llama/Llama-3.2-1B-Instruct --host 0.0.0.0 --port 8000 --num-prompts 100 --random-prefix-len 512 --random-input-len 512 --random-output-len 512
```
