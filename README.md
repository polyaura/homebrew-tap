# Polyaura Homebrew tap

    brew install polyaura/tap/cloak
    cd your-project
    cloak

In a project that calls OpenAI or Claude, `cloak` finds the AI it uses, picks
the job a local model can most likely do, and runs it on your Mac, so you see
the local answer before changing any code.

Commercial use of Cloak CLI is permitted. Redistribution, sublicensing, and resale of Cloak CLI require Polyaura LLC’s prior written permission. Third-party dependencies remain subject to their respective licenses.

Full terms are installed with Cloak as `LICENSE`
(`$(brew --prefix cloak)/LICENSE`), beside llama.cpp's MIT license
(`LICENSE-llama.cpp`). The model Cloak downloads the first time it runs a job, Gemma 3 1B, comes
from Hugging Face and is subject to Google's
[Gemma Terms of Use](https://ai.google.dev/gemma/terms). Cloak CLI is
proprietary beta software, not open source.
