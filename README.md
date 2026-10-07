# Polyaura Homebrew tap

    brew install polyaura/tap/cloak
    cd your-project
    cloak

Cloak finds cloud AI work and moves supported jobs local without making
developers think about the language or cloud provider underneath. In a
project's folder, `cloak` finds its AI jobs, runs the one a local model can
most likely do on your Mac, so you see the local answer before changing any
code, and on a yes moves it local, with the cloud call kept as the fallback.
Today: OpenAI and Claude, from Python, JavaScript and TypeScript.

Commercial use of Cloak CLI is permitted. Redistribution, sublicensing, and resale of Cloak CLI require Polyaura LLC’s prior written permission. Third-party dependencies remain subject to their respective licenses.

Full terms are installed with Cloak as `LICENSE`
(`$(brew --prefix cloak)/LICENSE`), beside llama.cpp's MIT license
(`LICENSE-llama.cpp`). The model Cloak downloads the first time it runs a job, Gemma 3 1B, comes
from Hugging Face and is subject to Google's
[Gemma Terms of Use](https://ai.google.dev/gemma/terms). Cloak CLI is
proprietary beta software, not open source.
