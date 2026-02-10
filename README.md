# MLコンペ用実験テンプレート

Claude Code との協働を前提とした Kaggle コンペティション用テンプレート。

## 特徴

- **Docker** によるポータブルな Kaggle と同一の環境
- **Hydra** による実験管理（dataclass ベースで補完・型チェック対応）
- **実験の分離管理**: 人間用 (`exp{NNN}_`) と Claude 用 (`exp{A-Z}{NN}_`) の命名規則
- **SESSION_NOTES.md** によるセッション間の知識継続
- **知見集約** (`docs/experiments.md`): 実験結果・ベストスコア・有効テクニックを一元管理
- **調査の体系化**: `survey/` (論文・ディスカッション) と `competition/` (EDA・類似コンペ) の分離
- **wandb** による実験ログの記録

## Quickstart: 新しいコンペを始める

1. このテンプレートからリポジトリを作成
2. `pyproject.toml` の `name` をプロジェクト名に変更
3. `KAGGLE_DIRECTION.md` に対象コンペ情報を記入
4. データを `input/` に配置
5. EDA を実施し `competition/overview.md` にまとめる
6. `survey/` で論文・ディスカッション調査
7. 最初のベースライン実験を作成

## Structure

```text
.
├── competition/              # コンペ情報
│   ├── overview.md           #   EDA結果・データ概要
│   └── related_competitions.md #   類似コンペの知見
│
├── survey/                   # 調査蓄積
│   ├── papers/               #   論文調査
│   └── discussion/           #   ディスカッション定点観測
│
├── experiments/              # 実験スクリプト
│   ├── exp{NNN}_{名前}/      #   人間用実験（例: exp001_baseline）
│   └── exp{A-Z}{NN}_{名前}/  #   Claude用実験（例: expA00_baseline）
│
├── docs/
│   └── experiments.md        # 実験記録 & 知見集約
│
├── input/                    # 入力データ
├── output/                   # 実験出力
├── logs/                     # 開発ログ
├── notebooks/                # Jupyter notebooks
├── tests/                    # テストコード
├── tools/                    # ユーティリティツール（提出確認、モデルアップロード）
├── utils/                    # 共通ユーティリティ（env, logger, timing）
│
├── CLAUDE.md                 # Claude Code 開発ガイドライン
├── KAGGLE_DIRECTION.md       # コンペ固有ワークフロー
├── TODO.md                   # タスク管理
├── Makefile
├── pyproject.toml
├── Dockerfile / Dockerfile.cpu
└── compose.yaml / compose.cpu.yaml
```

## 実験フォルダ命名規則

| 所有者 | パターン | 例 | 説明 |
|--------|---------|-----|------|
| 人間 | `exp{NNN}_{名前}` | `exp001_baseline` | NNN: 3桁の連番 |
| Claude | `exp{A-Z}{NN}_{名前}` | `expA00_baseline` | アルファベットは方針変更時にインクリメント |

各実験フォルダには `SESSION_NOTES.md` を必ず配置し、セッション間の知識継続に使用する。

## Hydra による Config 管理

- Config は dataclass で定義（エディタ補完・タイポ防止）
- 共通設定: `utils/env.py` の `EnvConfig`
- 実験固有設定: `experiments/{実験名}/exp/{minor}.yaml`
- 実行時に `exp={minor_version}` でオーバーライド
- `{major_exp_name}` と `{minor_exp_name}` の組み合わせで実験を再現

## プロジェクト初期設定

このテンプレートを新しいコンペで使用する際に、以下の項目を変更してください。

- [ ] `pyproject.toml` の `name` をプロジェクト名に変更
- [ ] `experiments/exp000_sample/run.py` の `WANDB_PROJECT_NAME` をプロジェクト名に変更
- [ ] `KAGGLE_DIRECTION.md` にコンペ情報を記入

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

## 関連ドキュメント

| ファイル | 内容 |
|---------|------|
| `CLAUDE.md` | Claude Code 開発ガイドライン（標準ルール、禁止事項） |
| `KAGGLE_DIRECTION.md` | コンペ固有ワークフロー（命名規則、進行方法、SESSION_NOTES仕様） |
| `docs/experiments.md` | 実験記録 & 知見集約 |
| `competition/overview.md` | EDA・データ概要テンプレート |
| `survey/papers/README.md` | 論文調査ガイド |
| `survey/discussion/README.md` | ディスカッション定点観測ガイド |
