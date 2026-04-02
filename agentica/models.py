import os
from dataclasses import dataclass

from dotenv import load_dotenv
from openai import AsyncOpenAI

load_dotenv()


@dataclass
class Model:
    id: str
    client: AsyncOpenAI
    extra_body: object | None = None


# Configurable base URL for inference endpoint (defaults to OpenRouter)
INFERENCE_BASE_URL = os.getenv("BASE_URL", "https://openrouter.ai/api/v1")
API_KEY = os.getenv("API_KEY", "")


QWEN_3_5 = Model(
    id="qwen/qwen-3.5",
    client=AsyncOpenAI(
        base_url=INFERENCE_BASE_URL,
        api_key=API_KEY or "",
    ),
)

NEMOTRON_3_NANO = Model(
    id="nvidia/nemotron-3-nano",
    client=AsyncOpenAI(
        base_url=INFERENCE_BASE_URL,
        api_key=API_KEY or "",
    ),
)

NEMOTRON_3_SUPER = Model(
    id="nvidia/nemotron-3-super",
    client=AsyncOpenAI(
        base_url=INFERENCE_BASE_URL,
        api_key=API_KEY or "",
    ),
)

GEMMA_4 = Model(
    id="google/gemma-4",
    client=AsyncOpenAI(
        base_url=INFERENCE_BASE_URL,
        api_key=API_KEY or "",
    ),
)

GLM_4_7 = Model(
    id="zai/GLM-4.7",
    client=AsyncOpenAI(
        base_url=INFERENCE_BASE_URL,
        api_key=API_KEY or "",
    ),
)


def openrouter(model: str) -> Model:
    """Shorthand for making a model from an openrouter model slug"""
    if not API_KEY:
        raise ValueError("No API key found. Set the API_KEY environment variable.")
    return Model(
        id=model,
        client=AsyncOpenAI(
            base_url=INFERENCE_BASE_URL,
            api_key=API_KEY,
        ),
    )
