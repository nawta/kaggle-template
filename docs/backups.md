# バックアップ情報

## HuggingFace Hub バックアップ

**リポジトリ**: [nawta/akkadian-checkpoints-backup](https://huggingface.co/nawta/akkadian-checkpoints-backup) (private)

削除済みチェックポイントのバックアップ先です。

### バックアップ一覧

| ローカルパス (相対: `Akkadian_to_English/output/experiments/`) | HF パス | サイズ | 削除日 | 備考 |
|--------------------------------------------------------------|---------|--------|--------|------|
| `expA00_baseline/000` | `expA00_baseline/000/` | 4.4GB | 2026-02-11 | baseline 古い run |
| `expA00_baseline/003` | `expA00_baseline/003/` | 6.6GB | 2026-02-11 | baseline 最新 run |
| `expC01_preprocess_v2/000` | `expC01_preprocess_v2/000/` | 2.2GB | 2026-02-11 | 古い run |
| `expC01_preprocess_v2/001` | `expC01_preprocess_v2/001/` | 11GB | 2026-02-11 | 古い run |
| `expC04_data_augmentation/000` | `expC04_data_augmentation/000/` | 6.6GB | 2026-02-11 | 古い run |
| `expH00_cpt_400/step_100` | `expH00_cpt_400/step_100/` | 7GB | 2026-03-04 | CPT 中間チェックポイント |
| `expH00_cpt_400/step_200` | `expH00_cpt_400/step_200/` | 7GB | 2026-03-04 | CPT 中間チェックポイント |
| `expH00_cpt_400/step_300` | `expH00_cpt_400/step_300/` | 7GB | 2026-03-04 | CPT 中間チェックポイント |
| `expH00_cpt_400/step_400` | `expH00_cpt_400/step_400/` | 7GB | 2026-03-04 | CPT 中間チェックポイント |
| `expH00_ft_400/fold0` | `expH00_ft_400/fold0/` | 7GB | 2026-03-04 | allfolds に同じ fold0 あり |
| `expB00_finetune_public/001` | `expB00_finetune_public/001/` | 8.7GB | 2026-03-04 | 旧実験 |
| `expB00_finetune_public/001_fold4` | `expB00_finetune_public/001_fold4/` | 2.2GB | 2026-03-04 | 旧実験 |
| `expC01_preprocess_v2/003` | `expC01_preprocess_v2/003/` | 11GB | 2026-03-04 | 旧実験 最終 run |
| `expC04_data_augmentation/001` | `expC04_data_augmentation/001/` | 16GB | 2026-03-04 | 旧実験 最終 run |

### 復元方法

```bash
# 特定のディレクトリを復元
huggingface-cli download nawta/akkadian-checkpoints-backup \
  --include "expH00_cpt_400/step_100/*" \
  --local-dir /path/to/restore/

# 全体を復元
huggingface-cli download nawta/akkadian-checkpoints-backup \
  --local-dir /path/to/restore/
```

### ローカルに残っているチェックポイント

削除後にローカルに残る実験データ:

| パス | サイズ | 内容 |
|------|--------|------|
| `expH00_cpt_400/final` | 7GB | CPT 最終チェックポイント |
| `expH00_ft_400_allfolds/fold0〜4` | 35GB | FT best_model × 5 fold |
