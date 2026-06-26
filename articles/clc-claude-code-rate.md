---
title: "Claude Codeのレート残量をCLI一発で確認する"
emoji: "📊"
type: "tech"
topics: ["claudecode", "python", "cli"]
published: true
---


Claude Codeを使っていると, レート制限 (5時間枠・週間枠・追加枠) の残量が気になる場面が多いです. 「あと何%使える?」「あと何時間でリセットされる?」を確認するたびにブラウザを開くのが手間だったので, ターミナルで `clc rate` と打つだけで確認できるCLIツールをPythonで作りました.

https://github.com/masa0902dev/claude-code-rate


---

# 使い方

## インストール

Python 3 があれば動きます. 外部パッケージのインストールは不要です.

```sh
git clone https://github.com/masa0902dev/claude-code-rate
cd claude-code-rate

# 方法1: symlink (~/bin が PATH に入っている場合)
ln -s "$(pwd)/clc" ~/bin/clc

# 方法2: .zshrc に alias を追加
echo "alias clc='$(pwd)/clc'" >> ~/.zshrc && source ~/.zshrc
```
`command not found: git`と表示される場合は, gitがインストールされていません. 下記の記事を参考にインストールして下さい. (Windows用の記事ですが, 該当部分はmacOSでも同様です)

https://zenn.dev/masa0902dev/articles/lab-git-github#3.-git%E3%81%AE%E5%A7%8B%E3%82%81%E6%96%B9


Claude Codeにログイン済みであれば, これだけで使えます.
認証情報はmacOS KeychainまたはClaude Codeの認証情報ファイルから自動取得します (後述. macOSだけでなくWindowsやLinuxでも可能).

## 実行例

```log
❯ clc rate
5Hours [██░░░░░░░░░░░]  17.0% used
       resets in 01h59m

Weekly [█░░░░░░░░░░░░]   4.0% used
       resets in 6d,39m

Extra  [███░░░░░░░░░░]  24.6% used
       used $2.46
```

![実際の見た目](/images/clc-claude-code-rate/img-cmd.png)


:::message alert
短時間に何度も実行すると, APIのレートリミットにすぐ引っかかったので注意.
:::

## コマンド一覧

```sh
clc rate          # レート残量を表示
clc rate --json   # APIの生レスポンスをjsonで表示
```

常時表示したい場合:
```sh
brew install watch
watch -n 60 clc rate  # 60秒ごとにレート残量を表示
```

## 手軽にカスタマイズ

`config.json`を編集することで, コードを触らずに表示をカスタマイズできます.

| キー                     | デフォルト値                      | 説明                                                          |
| ------------------------ | --------------------------------- | ------------------------------------------------------------- |
| `bar_width`              | `13`                              | プログレスバーの文字数                                        |
| `label_width`            | `7`                               | ラベル列の表示幅 (半角換算)                                   |
| `monthly_limit_usd`      | `10.0`                            | Extra枠の月間上限額 (USD). 自身のClaude設定に合わせてください |
| `color_warn_threshold`   | `50`                              | この使用率 (%) 以上で黄色表示                                 |
| `color_danger_threshold` | `80`                              | この使用率 (%) 以上で赤表示                                   |
| `window_labels`          | `{"five_hour": "5Hours", ...}`    | 各ウィンドウの表示名                                          |
| `window_order`           | `["five_hour", "seven_day", ...]` | ウィンドウの表示順                                            |


`config.json` が存在しない場合はすべてデフォルト値で動作します. 書いたキーだけが上書きされ, 省略したキーはデフォルト値のままです.


## エラーが出る場合

- **「認証情報が見つかりません」「トークンの有効期限が切れています」**
  → Claude Codeを一度起動するとトークンが自動更新されます. または, ウェブ上でClaudeにログインし直すとトークンが更新されます.

:::message
本ツールはClaude Code内部のOAuth APIを利用しており, 公式のAPIではありません. 将来的に仕様変更や廃止の可能性があります.
:::

---

# 先行ツールとの違い

本ツールは [@tatsuya582 さんの記事](https://qiita.com/tatsuya582/items/5ca0c12a8495530f7d09) を参考に作成しました. 先行ツールはdaemon + viewerの分離アーキテクチャで, tmuxペインに常時表示するための設計になっています.

本ツールは「macOSじゃなくてWindows」「tmuxを使っていない」「単発でサッと確認したい」という場面を想定して, よりシンプルな構成にしました.

| 比較項目        | 先行ツール                 | clc                             |
| --------------- | -------------------------- | ------------------------------- |
| 構成            | daemon + viewer            | 単一スクリプト                  |
| 常時表示        | tmuxペインに表示           | `watch -n 60` で代替可能        |
| カラー表示      | -                          | 使用率で3色                     |
| extra_usage表示 | -                          | 使用金額を表示                  |
| 外部パッケージ  | あり                       | なし (Python標準ライブラリのみ) |
| 対応OS          | macOSのみ (書き換えが必要) | macOS, Windows, Linux           |


---

# 仕組み

## APIエンドポイント

Claude Code内部で使われているOAuth APIを直接叩いています.

```log
GET https://api.anthropic.com/api/oauth/usage
Authorization: Bearer {access_token}
anthropic-beta: oauth-2025-04-20
```

レスポンスの主な構造は次の通りです.

```json
{
  "five_hour": {
    "utilization": 17.0,
    "resets_at": "2026-06-23T12:19:59+00:00"
  },
  "seven_day": {
    "utilization": 4.0,
    "resets_at": "2026-06-29T10:59:59+00:00"
  },
  "extra_usage": {
    "utilization": 24.6,
    "monthly_limit": 1000,
    "used_credits": 246.0,
    "currency": "USD",
    "decimal_places": 2
  }
}
```

`utilization` が使用率 (%), `resets_at` がリセット時刻です. `extra_usage` は追加クレジット枠で, `resets_at` の代わりに月間使用金額が入っています.

## 認証トークンの取得

Claude Codeにログイン済みであれば, OAuthトークンは次のいずれかに保存されています.

1. macOS Keychain (サービス名: `Claude Code-credentials`)
2. `~/.claude/.credentials.json`

macOSではKeychainを優先して参照し, なければファイルにフォールバックします.

```python
def load_credentials():
    raw = None
    if sys.platform == "darwin":
        result = subprocess.run(
            ["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
            capture_output=True, text=True,
        )
        if result.returncode == 0 and result.stdout.strip():
            raw = result.stdout.strip()

    if raw is None and os.path.exists(CREDENTIALS_PATH):
        with open(CREDENTIALS_PATH) as f:
            raw = f.read()
    ...
```

トークンの有効期限が切れていても, Claude Codeを起動するだけで自動更新されます.

---

# コード解説

## プログレスバーとカラーリング

使用率をバー幅に換算し, `█` と `░` で描きます. バー幅はBAR_WIDTHを変更することで調整可能です.
```python
BAR_WIDTH = 13
filled = round(BAR_WIDTH * min(utilization, 100) / 100)
bar = "█" * filled + "░" * (BAR_WIDTH - filled)
```

`sys.stdout.isatty()` でttyかどうかを確認し, パイプやリダイレクトへの出力時はANSIエスケープコードを付けません.
```python
def colorize(text, utilization, use_color):
    if not use_color:
        return text
    if utilization >= 80:
        code = "31"  # 赤
    elif utilization >= 50:
        code = "33"  # 黄
    else:
        code = "32"  # 緑
    return f"\033[{code}m{text}\033[0m"
```


## extra_usageの表示

`extra_usage` にはレート枠のような `resets_at` がありません. 代わりに, 使用率と月間上限額から使用金額を計算して表示しています.

```python
MONTHLY_LIMIT = 10.0  # USD: 自分のClaude設定での月間制限額

if key == "extra_usage":
    used_amount = (utilization / 100.0) * MONTHLY_LIMIT
    lines.append(f"used ${used_amount:.2f}")
```

`MONTHLY_LIMIT` はコード内の定数なので, 自身の設定値に合わせて変更してください (デフォルトは $10.00).

APIレスポンスの `monthly_limit` フィールドは小数点以下桁数を含む整数形式です (`decimal_places: 2` のとき `1000` → $10.00). そのため現状はコードを読んで手動で設定する形になっています.

## 全角文字の幅対応

ラベルを揃えるために, 全角文字を幅2として計算しています.

```python
def pad_display(text, width):
    w = sum(2 if unicodedata.east_asian_width(c) in "FW" else 1 for c in text)
    return text + " " * max(0, width - w)
```

---

# おわりに

`clc rate` 一発でClaude Codeのレート残量を確認できるようにしました. コードはシンプルなので, 表示カスタマイズやコマンド追加がしやすいかと思います.

macOSだけでなくWindowsでもそのまま使えるので, ぜひ使って頂けると嬉しいです! その際はZennのイイネ❤️やGitHubのスター⭐を頂けると励みになります! issueやPRも大歓迎です!!!

https://github.com/masa0902dev/claude-code-rate
