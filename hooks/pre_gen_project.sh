#!/usr/bin/env sh

case "{{cookiecutter.project_slug}}" in
    *\ *|*\	*)
        printf "\n  %s\n\n" "Error: project_slug cannot contain whitespace" >>/dev/stderr
        exit 1
esac
case "{{cookiecutter.environment_name}}" in
    *\ *|*\	*)
        printf "\n  %s\n\n" "Error: environment_name cannot contain whitespace" >>/dev/stderr
        exit 1
esac
if ! which micromamba >/dev/null 2>&1; then
    printf "\n  %s\n  %s\n\n" \
        "Error: Please install micromamba" \
        "https://mamba.readthedocs.io/en/latest/installation.html#micromamba-standalone-executable" \
        >>/dev/stderr
    exit 1
fi
