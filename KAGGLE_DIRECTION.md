# KAGGLE_DIRECTION: コンペティション ワークフロー

<!-- 新しいコンペ開始時にこのファイルを記入する -->

## 対象コンペ情報

- **コンペ名**: （ここに記入）
- **URL**: （ここに記入）
- **期間**: （ここに記入）
- **評価指標**: （ここに記入）

## ディレクトリ構造ガイド

```text
kaggle-template/
├── competition/           # コンペ情報（EDA結果、類似コンペ調査）
│   ├── overview.md        #   コンペ概要・EDAまとめ
│   └── related_competitions.md  #   類似コンペの知見
│
├── survey/                # 調査蓄積
│   ├── papers/            #   論文調査
│   └── discussion/        #   ディスカッション定点観測
│
├── experiments/           # 実験コード
│   ├── exp{NNN}_{名前}/   #   人間用実験
│   └── exp{A-Z}{NN}_{名前}/  #   Claude用実験
│
├── docs/
│   └── experiments.md     # 実験記録 & 知見集約
│
├── input/                 # 入力データ
├── output/                # 実験出力
├── notebooks/             # Jupyter notebooks
├── tools/                 # ユーティリティツール
└── utils/                 # 共通ユーティリティ
```

## 実験フォルダ命名規則

### 人間用実験
`experiments/exp{NNN}_{実験名}/`
- `NNN`: 3桁の数字（000, 001, 002, ...）
- 例: `exp001_baseline`, `exp002_feature_engineering`

### Claude用実験
`experiments/exp{A-Z}{NN}_{実験名}/`
- `{A-Z}`: アルファベット1文字。方針変更時にインクリメント（A→B→C...）
- `{NN}`: 2桁の数字。同一方針内の実験番号（00, 01, 02, ...）
- 例: `expA00_baseline`, `expA01_add_features`, `expB00_new_approach`

### minor バージョン（exp/ 配下の yaml）
- 各実験フォルダ内の `exp/` ディレクトリに配置
- `exp/{NNN}.yaml` で管理（000, 001, 002, ...）

## セッション記録ルール

各実験フォルダには `SESSION_NOTES.md` を必ず配置する。

### SESSION_NOTES.md の構造

```markdown
# SESSION_NOTES: {実験名}

## セッション N
- **日付**: YYYY-MM-DD
- **目標**: （このセッションで達成したいこと）

### 仮説
### 試したアプローチと結果（定量値含む）
### ファイル構成
### 重要な知見
### 次のステップ
### 性能変化の記録
### コマンド履歴
```

### 運用ルール
- セッション開始時に新しいセッションセクションを追加
- 実験結果は定量値（CV, LB スコア）を必ず記録
- セッション終了時に「次のステップ」を記入し、次回セッションの引き継ぎに使う

## コンペ進行方法

### 1. EDA フェーズ
1. データを `input/` に配置
2. `notebooks/` で EDA を実施
3. 結果を `competition/overview.md` にまとめる

### 2. 調査フェーズ
1. 類似コンペの上位解法を調査 → `competition/related_competitions.md`
2. 関連論文を調査 → `survey/papers/`
3. Kaggle Discussion を定期的に確認 → `survey/discussion/`

### 3. ベースライン構築
1. 最初の実験フォルダを作成（例: `exp001_baseline` or `expA00_baseline`）
2. シンプルなモデルで End-to-End パイプラインを構築
3. CV と LB の相関を確認

### 4. 改善サイクル
1. 仮説を立てる → SESSION_NOTES.md に記録
2. 実験を実施 → 結果を記録
3. 知見を `docs/experiments.md` に集約
4. 次の仮説を立てる

## 学習コードの要件

- **学習ログ**: wandb で損失値、評価指標、学習率を記録
- **途中再開**: チェックポイントからの再開をサポート（長時間学習の場合）
- **AMP (Automatic Mixed Precision)**: GPU メモリ効率化のため推奨
- **シード固定**: 再現性のため `seed` を設定で管理

## survey/ の運用ガイド

### 論文調査 (`survey/papers/`)
- 詳細は `survey/papers/README.md` を参照
- ファイル命名: `{YYYY}_{著者名}_{短縮タイトル}.md`

### ディスカッション定点観測 (`survey/discussion/`)
- 詳細は `survey/discussion/README.md` を参照
- JSON スクレイピングデータは gitignore 対象

## competition/ の運用ガイド

- `competition/overview.md`: EDA 結果のまとめ。コンペ開始時に記入。
- `competition/related_competitions.md`: 類似コンペの調査結果。ベースライン構築前に記入。

## Codex MCP サーバーの活用

Codex MCP サーバー（`mcp__codex__codex`）を以下の場面で積極的に活用する。

### サーベイ時の活用
- 論文調査（`survey/papers/`）や類似コンペ調査（`competition/related_competitions.md`）を行う際、Codex を使って情報収集・要約を行う
- Kaggle Discussion の調査時にも Codex を活用し、効率的に知見を収集する
- 調査フェーズ全般で Codex のネット検索・分析能力を活かす

### コードレビュー時の活用
- 実験コードの実装後、Codex を使ってコードレビューを実施する
- レビュー観点: バグの有無、パフォーマンス改善点、可読性、ベストプラクティスとの整合性
- 重要な変更（モデルアーキテクチャ変更、学習パイプライン変更など）は特に Codex レビューを推奨
