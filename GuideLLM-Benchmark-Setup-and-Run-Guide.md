# GuideLLM Benchmark Setup & Run Guide

This document describes how to set up and run the GuideLLM benchmark on a RHEL 10 bare-metal instance, and how to collect the benchmark results locally.

---

## Prerequisites
- RHEL 10 bare-metal instance
- Python 3.12 available
- Network access to the target inference endpoint

---

## 1. Install uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

\#Verify installation: 
```bash
uv --version
```

## 2. Create and initialize a Python virtual environment
```bash
uv venv --python 3.12 --seed
```

\# Activate the virtual environment:
```bash
source .venv/bin/activate
```

## 3. Install Git 
```bash
sudo dnf install -y git
```

## 4. Install GuideLLM 
```bash
uv pip install git+https://github.com/vllm-project/guidellm.git
```

Verify the installation:
```bash
guidellm --version
```

## 5. Create directory structure for benchmark results
```bash
mkdir -p results/20260120/test-01
cd results/20260120/test-01
```

## 6. Run the benchmark
\# From the test directory, run: 

```bash
guidellm benchmark \
  --target http://<host>/v1 \
  --model meta-llama/Llama-3.2-1B-Instruct \
  --data "prompt_tokens=128,output_tokens=256" \
  --rate-type sweep \
  --max-seconds 90
```

## 7. Downloado benchmark results to local machine
\# Run this command from your local system: 

```bash
scp -i ~/.ssh/rh-et-wd.pem -r \
ec2-user@<host ip> :/home/ec2-user/results/<dateoftest> \
~/Desktop/vLLM-Test-Results/
```

\#This will copy the entire test run directory for local analysis.

