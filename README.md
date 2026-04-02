Agentica Mini
=============

A minature version of [Agentica] which runs all agents locally and makes no
attempt at sandboxing. Use with caution.

Intended for education and research purposes - not actively maintained by the
Symbolica team. No guarentees are made for responsiveness to PRs/issues/feature
requests.

Best effort has been made to keep the agent interface in line with the latest
main-Agentica, but there may be some differences. Currently the magic decorator
and streaming work differently, but agents are the same.

[Agentica]: https://agentica.symbolica.ai


Installation
------------

Until this repo is published on PyPI, the easiest way to install it is to clone
the repo as a submodule, then depend on it directly.

**Step 1:** Clone this repo into your repo as a submodule:

~~~~ bash
git submodule add git@github.com:symbolica-ai/agentica-mini.git agentica-mini
~~~~

**Step 2:** Add it as a dependency (choose one):

### Option A: UV (recommended)

Add the submodule to your `pyproject.toml` dependencies:

~~~~ toml
[project]
dependencies = [
    "agentica",
    # ... your other dependencies
]

[tool.uv.sources]
agentica = { path = "./agentica-mini", editable = true }
~~~~

### Option B: Pip

Install the dependency in editable mode:

~~~~ bash
pip install -e ./agentica-mini
~~~~


Environment variables
---------------------

Agentica uses OpenRouter for inference by default, but the endpoint is
configurable. You can use either the `BASE_URL` and `API_KEY` environment
variables to point to any OpenAI-compatible API:

| Variable   | Description              | Default                            |
| ---------- | ------------------------ | ---------------------------------- |
| `BASE_URL` | Inference endpoint URL   | `https://openrouter.ai/api/v1`     |
| `API_KEY`  | API key for the endpoint | Falls back to `OPENROUTER_API_KEY` |

It is recommended to put environment variables in a `.env` file that is not
committed to git:

~~~~ bash
# .env in root of your project
BASE_URL="https://openrouter.ai/api/v1"  # or your custom endpoint
API_KEY="your-api-key"
~~~~

Or set them as environment variables in your shell:

~~~~ bash
export BASE_URL="https://openrouter.ai/api/v1"
export API_KEY="your-api-key"
~~~~

**Legacy support:** The `OPENROUTER_API_KEY` variable still works and will be
used if `API_KEY` is not set.


Usage
-----

This library is intended to line up with the main-Agentica library, so see the
[Agentica documentation] for more details.

The primary abstraction is the `Agent`, which is a combination of an LLM and a
REPL for the LLM to work in:

[Agentica documentation]: https://docs.symbolica.ai/

### Spawning an agent

This makes an agent which can be called multiple times, and keeps a consistent
REPL state with all the objects you've ever given it.

~~~~ python
from agentica import spawn

def secret() -> int:
    return 42

agent = await spawn(
    premise="You are a helpful assistant.",
    model="openai:gpt-4.1",
    scope={'secret': secret}, # can add arbitrary objects at spawn time as a dict
)
~~~~

### Sending a message to an agent

This sends a message to the agent, and returns the result.

~~~~ python
result = await agent.call(
    int,
    "What is the smallest prime number bigger than the secret?",
    secret=secret, # can also pass arbitrary objects at call time as kwargs
)

assert result == 43
~~~~

The first argument to `call` constrains the agent to only return a value of the
given type.

If the agent deems it's task impossible, it will raise an `AgentError`.

For a more complete example, see `chat.py`.

### Streaming

To stream chunks during an agent's response:

1.  Define a callback function that will be called on every chunk.
2.  Make a logger that calls this callback function.
3.  Make a listener that wraps the logger.
4.  Spawn an agent with a factory which returns this listener.

~~~~ python
# Make the callback
chunks = []
async def callback(chunk):
    print(chunk.content, end="", flush=True)

# Make the logger & wrap it in a listener
listener = AgentListener(StreamLogger(on_chunk=callback))

# Spawn an agent with this listener
agent = await spawn(listener=lambda: listener) # default model & premise

# Call the agent
result = await agent.call(int, "What is the 32nd power of 3?")
assert result == 3 ** 32

# Intermediate chunks will have been added to the list
assert len(chunks) > 0
~~~~
