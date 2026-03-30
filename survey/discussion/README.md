# ディスカッション定点観測

## 概要

Kaggle コンペティションの Discussion を定期的に収集し、重要な知見をまとめる。
`/kaggle-discussion-sync` スキルで自動化されている。

## ワークフロー

### 1. Discussion 収集

```bash
# Claude Code で実行
/kaggle-discussion-sync --competition 'competition id' --include-comments
```

- competition id: e.g, ai-mathematical-olympiad-progress-prize-3
- Vote 順で上位 N 件を取得（デフォルト10件）
- `scraped_discussions/` に個別 Markdown ファイルとして保存
- 差分検知: コメント数・投票数の変化があったものだけ再取得

### 2. 知見サマリー生成

```bash
# Claude Code で実行（sync + 知見抽出）
/kaggle-discussion-sync --competition 'competition id' --include-comments --summarize
```

- Python スクリプトが各ファイルから compact record を抽出 → `discussion_index.jsonl`
- Claude が compact records を読んで `discussion_insights.md` を更新
- 差分更新: 新規/更新分だけ処理（`content_hash` で管理）

### 3. 定点観測の頻度

- **コンペ序盤**: 週1-2回
- **コンペ中盤**: 週2-3回
- **コンペ終盤**: 毎日

## ディレクトリ構成

```
discussion/
├── README.md                        # このファイル
├── discussion_insights.md           # 知見サマリー（最新）
├── discussion_index.jsonl           # compact records（全件）
├── discussion_state.json            # 差分管理用 state
├── aimo3_discussions_YYYY-MM-DD.md  # 過去の手動サマリー
└── scraped_discussions/             # スクレイプ生データ
    └── <competition>__<id>.md       # 個別 discussion（YAML front matter付き）
```

## 技術詳細

### スキルの仕組み

1. **データ収集**: Kaggle MCP サーバー (`https://www.kaggle.com/mcp`) に JSON-RPC で通信
2. **認証**: `~/.kaggle/kaggle.json` の Basic Auth（ブラウザ/SSO 不要）
3. **差分検知**: `comment_count` / `vote_count` の変化で再取得を判断
4. **知見抽出**: Python で key_points + notable_comments を compact record に圧縮
5. **サマリー生成**: Claude が compact records を読んで構造化サマリーを作成

### コンテクスト効率

- 生 Markdown: 10件で ~112KB → Claude のコンテクストを圧迫
- compact records: 10件で ~5KB → Claude が効率的に処理可能
- 差分更新: 変更のないファイルはスキップ
