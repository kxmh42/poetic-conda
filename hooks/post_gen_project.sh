#!/usr/bin/env bash

set -e
tmpdir="`mktemp -d`"
trap 'rm -rf -- "$tmpdir"' EXIT

micromamba env create -y -p "$tmpdir/env" -f environment.yml
{ set +x; } >/dev/null 2>&1
eval "`micromamba shell hook -s bash`"
micromamba activate "$tmpdir/env"
set -x
make clean-direct-url-json
poetry init {{cookiecutter.poetry_init_args}}
poetry add --lock --group dev conda-lock
poetry install
conda-lock --conda micromamba --micromamba
{ set +x; } >/dev/null 2>&1
micromamba deactivate
set -x
rm -rf -- "$tmpdir"
trap - EXIT

make env name={{cookiecutter.environment_name}}
{ set +x; } >/dev/null 2>&1
cat <<EOF

You can now go into your project directory: \`cd {{cookiecutter.project_slug}}\`
{% if cookiecutter.generate_envrc -%}
- Run \`direnv allow\` to automatically activate the environment when you enter
  the project directory
- Otherwise, activate the environment manually with \`micromamba activate {{cookiecutter.environment_name}}\`
{%- else -%}
- Activate the environment with \`micromamba activate {{cookiecutter.environment_name}}\`
- You can run \`make .envrc\` to create the file that \`direnv\` will use to
  automatically activate the environment when you enter the project directory
{%- endif %}
- When adding/removing/upgrading/downgrading Poetry packages, follow the
  standard Poetry procedures
- When adding/removing/upgrading/downgrading Conda packages, make the necessary
  changes to \`environment.yml\` and run \`make update\`, which will update
  both \`conda-lock.yml\` and \`poetry.lock\` according to the updated package
  specifications
- See https://github.com/kxmh42/poetic-conda for more information
EOF
