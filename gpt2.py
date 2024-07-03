import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

device = "cuda"

model = AutoModelForCausalLM.from_pretrained(
    "gpt2",
    torch_dtype=torch.float16,
    attn_implementation="flash_attention_2",
    device_map='auto'
)
tokenizer = AutoTokenizer.from_pretrained("gpt2")

prompt = "def hello_world():"

model_inputs = tokenizer([prompt], return_tensors="pt").to(device)
model.to(device)

gen_tokens = model.generate(**model_inputs, max_new_tokens=100, do_sample=True)
gen_text = tokenizer.batch_decode(gen_tokens)[0]

print(gen_text)
