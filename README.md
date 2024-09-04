# pre-commit-dep-downloader

Framework for installing dependencies required for your pre-commit hooks.

Features:

- Download dependencies (brew, apt, pipx, go)
- Test if dependencies are installed

## Deployment

Add the following to your `.pre-commit-config.yaml`. Best to add this to the top of the file to install dependencies first.

`.pre-commit-config.yaml`

```
  - repo: https://github.com/omnicate/pre-commit-dep-downloader
    rev: main
    hooks:
      - id: dep-downloader
        name: "Download dependencies (brew, go)"
        args:
          [
            "--brew-packages=trivy,terraform,shellcheck,semgrep",
            "--apt-packages=trivy,terraform,shellcheck",
            "--pip-packages=semgrep",
            "--go-packages=github.com/minamijoyo/tfupdate@latest,github.com/bazelbuild/buildtools/buildifier@latest,github.com/yoheimuta/protolint/cmd/protolint@latest",
          ]
```

## Local Testing

.hooks/pre-commit-download-dependencies.sh \
 "--brew-packages=trivy,terraform,shellcheck" \
 "--apt-packages=trivy,terraform,shellcheck" \
 "--pip-packages=semgrep" \
 "--go-packages=github.com/minamijoyo/tfupdate@latest,github.com/bazelbuild/buildtools/buildifier@latest,github.com/yoheimuta/protolint/cmd/protolint@latest"
