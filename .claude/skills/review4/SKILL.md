---
name: review4
description: Opus 4.6/4.5 + Codex 5.3/5.2 を並列実行してコードレビューを統合する
disable-model-invocation: true
allowed-tools: Bash(bash .claude/skills/review4/scripts/review4.sh *), Read
---

# /review4 - 4モデル並列コードレビュー

## 実行手順

1. 以下のコマンドを実行して4モデルの並列レビュー結果を取得してください:

```
bash .claude/skills/review4/scripts/review4.sh $ARGUMENTS
```

引数の仕様:
- 引数なし or `staged` → staged changes をレビュー（デフォルト）
- `unstaged` → unstaged changes をレビュー
- `all` → staged + unstaged 両方をレビュー

2. コマンド出力（4モデルのレビュー結果）を受け取ったら、以下の手順で統合レビューを作成してください:

## 統合レビューの作成指示

4つのモデルからのレビュー結果を分析し、以下の形式で **統合レビュー** を日本語で作成してください:

### 出力形式

```
## 統合コードレビュー

### Critical（複数モデルが指摘 or 重大な問題）
- ...

### Warning（注意すべき点）
- ...

### Suggestion（改善提案）
- ...

### Good（良い点）
- ...

### モデル間の見解の相違
- ...（ある場合のみ）
```

### 統合ルール

- **複数モデルが同じ問題を指摘** → 信頼度が高い。Critical に格上げを検討
- **1モデルのみの指摘** → 内容を精査し、妥当なら残す
- **モデル間で矛盾する指摘** → 両方の見解を「見解の相違」セクションに記載
- **具体的な修正案がある場合** → コードブロックで提示
- 各指摘にはどのモデルが指摘したかを `[Opus4.6]` `[Opus4.5]` `[Codex5.3]` `[Codex5.2]` のタグで示す
