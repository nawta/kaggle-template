# MLコンペ用実験テンプレート

## 特徴
- Docker によるポータブルなKaggleと同一の環境
- Hydra による実験管理
- 実験用スクリプトファイルを major バージョンごとにフォルダごとに管理 & 実験パラメータ設定を minor バージョンとしてファイルとして管理
   - 実験用スクリプトと実験パラメータ設定を同一フォルダで局所的に管理して把握しやすくする
- dataclass を用いた config 定義を用いることで、エディタの補完機能を利用できるように

### Hydra による Config 管理
- Config は yamlとdictで定義するのではなく、dataclass を用いて定義することで、エディタの補完などの機能を使いつつタイポを防止できるようにする
- 各スクリプトに共通する環境依存となる設定は utils/env.py の EnvConfig で定義される
- 各スクリプトによって変わる設定は、実行スクリプトのあるフォルダ(`{major_exp_name}`)の中に `exp/{minor_exp_name}.yaml` として配置することで管理。
    - 実行時に `exp={minor_exp_name}` で上書きする
    - `{major_exp_name}` と `{minor_exp_name}` の組み合わせで実験が再現できるようにする

## Structure
```text
.
├── experiments
├── input
├── notebook
├── output
├── tools
├── utils
├── .python-version
├── Dockerfile
├── Dockerfile.cpu
├── LICENSE
├── Makefile
├── README.md
├── compose.cpu.yaml
├── compose.yaml
└── pyproject.toml

```

## 環境構築

環境構築には uv と Docker の2つの方法があります。ローカルで手軽に開発したい場合は uv、Kaggle環境と同一の環境で実行したい場合は Docker を使用してください。

### uv による環境構築

```sh
# セットアップ
make uv-setup

# jupyter lab を起動する場合
make uv-jupyter

# スクリプトを実行する場合
uv run python -m experiments.exp000_sample.run exp=001
```

### Docker による環境構築

```sh
# imageのbuild
make build

# bash に入る場合
make bash

# jupyter lab を起動する場合
make jupyter

# CPUで起動する場合はCPU=1やCPU=True などをつける
```

## スクリプトの実行方法

```sh
# python -m experiments.{major_version_name}.run exp={minor_version_name}

python -m experiments.exp000_sample.run
python -m experiments.exp000_sample.run exp=001
```

※ `python -m` を使用することで、カレントディレクトリがPythonパスに追加され、`utils` モジュールを正しくインポートできます。