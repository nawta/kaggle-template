# ディスカッション定点観測ガイド

## 概要

Kaggle コンペティションの Discussion を定期的に確認し、重要な情報を記録する。

## ワークフロー

### 1. 情報収集方法

#### Kaggle API を使用
```bash
kaggle competitions list
kaggle kernels list -s {competition_name} --sort-by voteCount
```

#### Playwright / MCP によるスクレイピング
- Discussion ページの自動取得
- スナップショットを JSON 形式で保存

### 2. 定点観測の頻度

- **コンペ序盤**: 週1-2回
- **コンペ中盤**: 週2-3回
- **コンペ終盤**: 毎日

### 3. 記録フォーマット

各ディスカッションのまとめ：

```markdown
# {ディスカッションタイトル}

- **日付**: YYYY-MM-DD
- **投稿者**:
- **Vote数**:
- **URL**:

## 要約
（主要なポイント）

## コンペへの影響
（このディスカッションから得られる示唆）

## アクションアイテム
- [ ] 試すべきこと
```

### 4. スナップショット管理

- JSON ファイルは `.gitignore` で除外済み（容量が大きいため）
- 重要な情報はマークダウンに転記して保存

## ディレクトリ構成

```
discussion/
├── README.md          # このファイル
├── .gitkeep
├── *.md               # 各ディスカッションのまとめ
└── *.json             # スクレイピングデータ（gitignore対象）
```
