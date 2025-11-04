# Overview

A collection of simple templates to get a vllm (cpu only) enabled container deployed on OpenShift


## Creating container

Clone the repository https://github.com/vllm-project/vllm.git

Execute the following commands

```bash
cd vllm

podman build -f docker/Dockerfile.cpu  --security-opt label=disable --build-arg VLLM_CPU_AVX512BF16=false --build-arg VLLM_CPU_AVX512VNNI=false --build-arg VLLM_CPU_DISABLE_AVX512=false --tag quay.io/luzuccar/vllm-cpu:dev --target vllm-openai .

podman push quay.io/<user>/vllm-cpu:<version> 

```

For podman notice the flag ```--security-opt label=disable``` - this is due to the fact that the vllm containerfile uses the directive ```--mount=type=```

## Deploy to Openshift


The vllm container requires privleged Security Context Constraint (SCC) 

Execute the following command (you would need cluster-admin permissions)

```bash 
oc adm policy add-scc-to-user privileged -z default -n <namespace>
```

Execute the following templates in the specific order (assumes you have created a new namespace/project)

```bash

oc apply -f pvc.yaml 
oc apply -f secret.yaml 
oc apply -f vllm.yaml 
oc apply -f service.yaml 
oc apply -f route.yaml 

```

You may need to change the resource values in the vllm.yaml file, current values are
- cpu : 48
- memory : 32Gi

Use the the route url to access the inference endpoint

```bash

curl -X POST http://<rout-url>/v1/chat/completions   -H "Content-Type: application/json"   -d '{
    "model": "meta-llama/Llama-3.2-1B-Instruct",
    "messages": [
      {
        "role": "user",
        "content": "<prompt>"
      }
    ]
  }'

```

Use the following [tool](https://github.com/vllm-project/guidellm) to benchmark vllm cpu 

Typical usage could be something like this 

```bash
guidellm benchmark --target http://<route-url>/v1 --model meta-llama/Llama-3.2-1B-Instruct --data "prompt_tokens=512,output_tokens=128" --rate-type sweep --max-seconds 240

```

## Acknowledgemet

[link](https://developers.redhat.com/author/sai-sindhur-malleni) How to run vLLM on CPUs with OpenShift for GPU-free inference



 
