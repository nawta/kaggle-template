---
name: review4
description: |
  Opus 4.7/4.6 + Codex 5.3-codex/5.4 + CodeRabbit を並列実行し、Deepwiki MCP で外部リポジトリ文脈を補完してコードレビューを統合する。

  TRIGGER when: ユーザーがコードレビューを依頼したとき。例: "レビューして", "review", "コードレビューお願い",
  "この変更チェックして", "PRをレビュー", "diff見て指摘して", "/review4"。
  staged / unstaged / all / last-commit のスコープが明示された場合も含む。
allowed-tools: Bash(bash ~/.claude/skills/review4/scripts/review4.sh *), Read, mcp__deepwiki__read_wiki_structure, mcp__deepwiki__read_wiki_contents, mcp__deepwiki__ask_question
---

# /review4 - 5レビュアー並列コードレビュー

## 実行手順

1. 以下のコマンドを実行して5レビュアー（Claude×2 / Codex×2 / CodeRabbit）の並列レビュー結果を取得してください:

```
bash ~/.claude/skills/review4/scripts/review4.sh $ARGUMENTS
```

引数の仕様:
- 引数なし or `staged` → staged changes をレビュー（デフォルト）。空なら自動で `last-commit` にフォールバック
- `unstaged` → unstaged changes をレビュー
- `all` → staged + unstaged 両方をレビュー。両方空なら `last-commit` にフォールバック
- `last-commit` → 直近コミット（HEAD）をレビュー

2. **(任意) Deepwiki MCP で外部リポジトリ文脈を補完**: 変更が著名な OSS（PyTorch, transformers, lightning, sklearn, Kaggle 公開ノートブック等）の API を呼び出している場合、`mcp__deepwiki__ask_question` で `repoName` を指定してその使い方の正解を確認してください。レビュアーの指摘が API 仕様と一致するか裏取りできます。スキップしてもよいです。

3. コマンド出力（5レビュアーの結果）を受け取ったら、以下の手順で統合レビューを作成してください:

## 統合レビューの作成指示

5つのレビュアーからの結果を分析し、以下の形式で **統合レビュー** を日本語で作成してください:

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

- **複数レビュアーが同じ問題を指摘** → 信頼度が高い。Critical に格上げを検討
- **1レビュアーのみの指摘** → 内容を精査し、妥当なら残す
- **レビュアー間で矛盾する指摘** → 両方の見解を「見解の相違」セクションに記載
- **具体的な修正案がある場合** → コードブロックで提示
- 各指摘にはどのレビュアーが指摘したかを `[Opus4.7]` `[Opus4.6]` `[Codex5.3]` `[Codex5.4]` `[CodeRabbit]` のタグで示す
- **Deepwiki で API 仕様を裏取りした場合** → `[Deepwiki: <repo>]` の引用タグを付ける
- **CodeRabbit が出力なし/失敗した場合** → 4レビュアーで統合し、その旨を末尾に注記
