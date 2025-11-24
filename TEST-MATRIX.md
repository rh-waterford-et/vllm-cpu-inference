# Overview

This is a cli test matrix (guidellm) with reference to [vllm (CPU) Performace Evaluation Guide](https://docs.google.com/document/d/1L9XdEnrfU5cyWM29BssWsdMDDhWnTF57hDqvstelshU/edit?tab=t.lkrz1tew8ge4)

This applies to AMD EPYC CPU inference only

Command line execution assumes that the model has been setup on a target server and that the public url is known, the execution of guidellm should be on a separate server

## Setup (target server)

refer to [readme](https://github.com/rh-waterford-et/vllm-cpu-inference/blob/main/README.md) for setup and command line execution

## Test Case 1.1  

- Model    : Llama-3.2-1B
- Test     : sweep
- Workload : chat (512:256) 
- Metric   : Max throughput (OTPS/TTPS)

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model meta-llama/Llama-3.2-1B-Instruct  --data "prompt_tokens=512,output_tokens=256" --rate-type sweep --max-seconds 240
```

## Test Case 1.2  

- Model    : Llama-3.2-1B
- Test     : sweep
- Workload : rag (4096:512) 
- Metric   : kv cache / TTFT (scaling)

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model meta-llama/Llama-3.2-1B-Instruct  --data "prompt_tokens=4096,output_tokens=512" --rate-type sweep --max-seconds 240
```

## Test Case 1.3  

- Model    : Qwen2-0.5-B-Instruct-AWQ
- Test     : sweep
- Workload : codegen (512:4K) 
- Metric   : ITL Decoding Efficiency

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model Qwen/Qwen2.5-0.5B-Instruct-AWQ   --data "prompt_tokens=512,output_tokens=4096" --rate-type sweep --max-seconds 240
```

## Test Case 1.4  

- Model    : granite-3.2-2b-instruct
- Test     : sweep
- Workload : rag (4096:512) 
- Metric   : prefill TTFT scaling

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model  ibm-granite/granite-3.2-2b-instruct  --data "prompt_tokens=4096,output_tokens=512" --rate-type sweep --max-seconds 240
```

## Test Case 1.5  

- Model    : facebook/opt-125m
- Test     : sweep
- Workload : summarization (1024:256) 
- Metric   : balanced throughput of legacy architecture

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model  facebook/opt-125m  --data "prompt_tokens=1024,output_tokens=256" --rate-type sweep --max-seconds 240
```

## Test Case 1.6 (vLLM v0.9.2 does not have v1/embeddings endpoint)  

- Model    : slate-30m-english-rtrvr
- Test     : sweep
- Workload : embedding (512:1) 
- Metric   : enterprise english embedding throughput (RPS)

cli - NA

## Test Case 1.7 (vLLM v0.9.2 does not have v1/embeddings endpoint)  

- Model    : granite-embedding-278M-multilingual
- Test     : sweep
- Workload : embedding (512:1) 
- Metric   : multilingual embedding throughput (RPS)

cli - NA

## Test Case 1.8  

- Model    : Qwen2-0.5-B-Instruct-AWQ
- Test     : sweep
- Workload : chat (512:256) 
- Metric   : max throughput

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model Qwen/Qwen2.5-0.5B-Instruct-AWQ   --data "prompt_tokens=512,output_tokens=256" --rate-type sweep --max-seconds 240
```

## Test Case 1.9  

- Model    : granite-3.2-2b-instruct
- Test     : sweep
- Workload : chat (512:256) 
- Metric   : max throughput

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model  ibm-granite/granite-3.2-2b-instruct  --data "prompt_tokens=512,output_tokens=256" --rate-type sweep --max-seconds 240
```

## Test Case 1.10

- Model    : tinyLlama-1.1B
- Test     : sweep
- Workload : chat (512:256) 
- Metric   : raw baseline

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model   TinyLlama/TinyLlama-1.1B-Chat-v1.0 --data "prompt_tokens=512,output_tokens=256" --rate-type sweep --max-seconds 240
```

## Test Case 2.1

- Model    : granite-3.2-2b-instruct
- Test     : concurrent
- Workload : chat (512:256) 
- Metric   : p95 latency scaling

cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model  ibm-granite/granite-3.2-2b-instruct  --data "prompt_tokens=512,output_tokens=256" --rate-type concurrent --max-seconds 240
```

## Test Case 2.2 (vLLM v0.9.2 does not have v1/embeddings endpoint) 

- Model    : granite-embedding-278M-multilingual
- Test     : constant
- Workload : embedding (512:1) 
- Metric   : p95 latency scaling

cli - NA


## Test Case 2.3

- Model    : Llama-3.2-1B
- Test     : poisson
- Workload : shot-codegen (256:2048) 
- Metric   : Responsiveness (code workloads)
cli

```
guidellm benchmark --target http://<TARGET-URL>:<TARGET-PORT>/v1 --model meta-llama/Llama-3.2-1B-Instruct  --data "prompt_tokens=256,output_tokens=2048" --rate-type poisson --max-seconds 240
```

