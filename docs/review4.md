# /review4 - 4モデル並列コードレビュー

## 概要

`/review4` は、4つのAIモデル（Claude 2モデル + Codex 2モデル）を並列実行してコードレビューを行い、結果を統合するスキルです。

複数モデルの視点を組み合わせることで、単一モデルでは見落としがちなバグやセキュリティ問題を検出します。

## 使い方

Claude Code のチャットで以下のように入力します:

```
/review4              # staged changes をレビュー（デフォルト）
/review4 staged       # staged changes をレビュー
/review4 unstaged     # unstaged changes をレビュー
/review4 all          # staged + unstaged 両方をレビュー
```

## 使用モデル

| ラベル | デフォルトモデル | 環境変数 |
|--------|-----------------|----------|
| Claude-1 | `claude-opus-4-6` | `CLAUDE_MODEL_1` |
| Claude-2 | `claude-opus-4-5-20251101` | `CLAUDE_MODEL_2` |
| Codex-1 | `gpt-5.3-codex` | `CODEX_MODEL_1` |
| Codex-2 | `gpt-5.2-codex` | `CODEX_MODEL_2` |

モデルを変更したい場合は、環境変数を設定してから Claude Code を起動してください:

```bash
export CLAUDE_MODEL_1="claude-sonnet-4-5-20250929"
```

## 動作フロー

1. `git status` と `git diff` でコード変更を収集
2. レビュー用プロンプトを構築
3. 4モデルをバックグラウンドで並列実行
4. 全モデルの完了を待機
5. 各モデルの出力を統合して返却
6. Claude が4者のレビューを分析し、統合レビューを作成

## 統合レビューの形式

最終出力は以下のセクションで構成されます:

- **Critical** - 複数モデルが指摘 or 重大な問題
- **Warning** - 注意すべき点
- **Suggestion** - 改善提案
- **Good** - 良い点
- **モデル間の見解の相違** - モデル間で矛盾がある場合

各指摘には `[Opus4.6]` `[Opus4.5]` `[Codex5.3]` `[Codex5.2]` のタグが付きます。

## レビュー観点

各モデルは以下の観点でレビューを行います:

1. **バグ・ロジックエラー** - off-by-one、race condition、null pointer
2. **セキュリティ** - SQL injection、XSS、command injection、OWASP top 10
3. **パフォーマンス** - N+1クエリ、不要なアロケーション、計算量
4. **可読性・保守性** - 命名、構造、重複、マジックナンバー
5. **ベストプラクティス** - エラーハンドリング、エッジケース、テスト

## Codex タイムアウト・リトライ

Codex MCP サーバーが応答しない場合に備え、タイムアウトとリトライ機構があります。

| 設定 | デフォルト | 環境変数 |
|------|-----------|----------|
| タイムアウト | 3600秒（1時間） | `CODEX_TIMEOUT` |
| 最大リトライ回数 | 3回 | `CODEX_MAX_RETRIES` |

- タイムアウトに達するとプロセスを kill し、自動でリトライします
- 全リトライ失敗時はエラーメッセージが出力に含まれます

## 前提条件

- `claude` CLI がインストール済みであること
- `codex` CLI がインストール済みであること
- `.claude/settings.local.json` にスクリプト実行パーミッションが設定済みであること

## ファイル構成

```
.claude/skills/review4/
├── SKILL.md                    # スキル定義
└── scripts/
    └── review4.sh              # メインスクリプト
```
