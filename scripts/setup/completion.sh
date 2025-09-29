#!/usr/bin/env bash

eval "$(direnv hook bash)"
source <(devbox completion bash)

#source <(kubelogin completion bash)
#source <(gh completion bash)
#source <(kind completion bash)
#source <(kubectl completion bash)
#source <(yq completion bash)
#source "$(brew --prefix)/etc/bash_completion.d/az"
#eval "$(npm completion)"
#eval "$(uv generate-shell-completion bash)"
#eval "$(uvx --generate-shell-completion bash)"

#source <(chainsaw completion bash)
#source <(npm completion)
