# Poetic Conda

## Introduction

This template grew out of an [answer](https://stackoverflow.com/a/71110028) to
this question: [Does it make sense to use Conda +
Poetry?](https://stackoverflow.com/questions/70851048/does-it-make-sense-to-use-conda-poetry)
The short answer is: Yes, it makes sense to use both, because we can work
around their functional overlap, and take advantage of their unique strengths
to create a reproducible setup.

- **Conda** allows you to specify the required Python version of the project
  and install right Python binary directly (eliminating the need for a tool
  like `pyenv`).
- **Conda** allows you to specify the required Poetry version of the project
  and install it like any other project dependency.
- **Conda** provides virtual environments (eliminating the need for a tool like
  `virtualenv` or `venv`).
- **Conda**'s virtual environments can be easily used as Python kernels in
  Jupyter and VS Code.
- **Conda** is in principle a generic, rootless, language-agnostic package
  manager and allows the specification and installation of non-Python
  dependencies of the project, including various tools and
  compilers/interpreters of different languages.
- Some Python packages installed via **Conda** work better than the same
  packages installed from PyPI, e.g. in terms of GPU support (although the
  situation with PyPI packages has improved a lot recently).
- **Poetry** can easily install any package available in PyPI.
- **Poetry** provides a convenient CLI for adding, removing and upgrading
  individual packages, and reflecting these changes in both the config file
  (`pyproject.toml`) and the lock file (`poetry.lock`).
- **Poetry** allows you to put packages into different groups, e.g. separate
  dev dependencies.
- **Poetry** automatically removes unused dependencies, making it easy to try
  out new packages and revert the project to a previous state if new packages
  are deemed unnecessary.

Or, to put it another way: If you primarily use **Conda**, you will sometimes
need another tool to install non-Conda PyPI packages. Poetry is a better choice
than e.g. using `pip` directly for this purpose. And if you mainly use
**Poetry**, you still need tools to handle different Python versions and to
manage virtual environments. Conda offers all this, and much more.

## Overview

First, we use Conda to install Python, Poetry and other packages that we can't
or don't want to install from PyPI. Then we use Poetry to install all the other
dependencies from PyPI. Poetry will see the packages already installed by Conda
and will only upgrade them if a newer version is available in PyPI.

> **NOTE:**  Usually these upgrades are minor and harmless, but in case of
> problems you may need to specify the correct package version in
> `pyproject.toml` to match the version installed by Conda.

> **NOTE:** There is a [bug](https://github.com/python-poetry/poetry/issues/6408),
> which causes Poetry to try to upgrade packages installed by Conda even if
> their version is exactly the same. We work around this problem here, see the
> `Makefile`.

Conda doesn't support lock files by default, so we use
[conda-lock](https://github.com/conda/conda-lock) to generate `conda-lock.yml`,
which is an equivalent to `poetry.lock`.

We use a version of Conda called
[**micromamba**](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html),
which (unlike other versions Conda and Mamba) [can create environments directly
from `conda-lock.yml` files](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html#conda-lock-yaml-spec-files).

## Prerequisites

1. [**cookiecutter**](https://github.com/cookiecutter/cookiecutter). This is a
standalone command-line utility, so the recommended installation procedure is
through <code>[pipx](https://pypa.github.io/pipx/) install cookiecutter</code> or
<code>[condax](https://github.com/mariusvniekerk/condax) install cookiecutter</code>.

2. [**micromamba**](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html)
is basically a non-bloated version of Conda with almost no dependencies. It can
be installed using package managers, e.g. <code>brew install micromamba</code>,
<code>[condax](https://github.com/mariusvniekerk/condax) install micromamba</code> or
<code>conda install micromamba</code>. Alternatively, it can be installed using an
[install script](https://mamba.readthedocs.io/en/latest/installation.html#install-script).

## Usage

### Create a new project

Create a new project with:

    cookiecutter gh:kxmh42/poetic-conda

Fill in the following details:

- `project_slug`: the project directory name with words separated by
  underscores, and also the default name for `tool.poetry.name`.
- `environment_name`: the name of the micromamba environment to create,
  defaults to the value of `project_slug`.
- `generate_envrc`: if true, it will create an `.envrc` file, which is used by
  [direnv](https://direnv.net/) to automatically activate your project's
  environment when you enter the project directory,
- `poetry_init_args`: arguments to pass to `poetry init`. The default value
  `-n` tells Poetry not to ask any questions and create a default
  `pyproject.toml`. If you want your project to stick to a specific Python
  version, you can specify it here, e.g. `--python=~3.9` means that only Python
  3.9.* is allowed. This condition must also be specified in `environment.yml`,
  e.g. as `- python=3.9`.
- `platform_XXX`: platforms that should be taken into account in
  `conda-lock.yml`.

### Create an environment and install dependencies for an existing project based on this template

When users/developers download the project and want to create an environment
and install project dependencies, they need to run:
<pre>
make env name=<i>my_env_name</i>
</pre>
*`my_env_name`* can be any name for a micromamba environment, it can be different
for different developers.

### Activate/deactivate the new environment

If `.envrc` has been generated, `direnv allow` must be run in the project
directory to automatically activate the new environment on directory entry and
deactivate it on exit. The `.envrc` file can always be generated later with
<code>make .envrc name=*my_env_name*</code>

Otherwise, the new environment can be activated/deactivated with:
<pre>
micromamba activate <i>my_env_name</i>
...
micromamba deactivate
</pre>
### Manage Poetry packages

Poetry-installed packages can be managed by editing `pyproject.toml` and/or
using standard Poetry commands, such as `poetry add ...`, `poetry remove ...`,
`poetry update ...`, `poetry lock --no-update ...`, etc.

### Manage Conda packages

When adding/removing/upgrading/downgrading Conda packages, make the necessary
changes to `environment.yml` and run `make update`, which will update both
`conda-lock.yml` and `poetry.lock` according to the updated package
specifications. Note that this may also update packages unrelated to your
change, which is due to Conda's less fine-grained package management compared
to Poetry.

> **NOTE:** If you are adding a Conda package that is also in PyPI, the best
> practice is to pin an exact version of the package in both Conda and Poetry
> files, e.g. `- tensorflow=2.8.0` (`environment.yml`) and `tensorflow = "2.8.0"`
> (`pyproject.toml`). Then you can run `make update` and the Conda package will
> be installed, and Poetry will be prevented from updating it.

### Configure micromamba

The micromamba config is in `.mambarc` in the project root. By default it sets the
channel priority to `strict`. It can be adjusted as needed. This config file is
used when micromamba is invoked from the `Makafile`. On the other hand,
`~/.mambarc` from the home directory is **not** used in such a situation, in order
to make the behaviour of micromamba as reproducible as possible.

### Add virtual packages

See the [virtual package specification](https://github.com/conda/conda-lock#--virtual-package-spec)
in conda-lock, and an [example](https://stackoverflow.com/a/71110028) of using
`virtual-packages.yml` to generate CUDA-enabled lock files even on platforms without CUDA. 
Such changes require running `make update` to regenerate the lock files.
