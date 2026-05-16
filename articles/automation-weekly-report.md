---
title: "[研究関連の自動化] 週報のPDF化とアップロードを自動化しよう"
emoji: "🤖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["自動化", "launchd", "python"]
published: true
---



# モチベーション

研究の週報を毎週GitHubリポジトリにアップロードしていましたが、ゼミ前にアップロードするのをよく忘れてしまっていました。また、週1回という高頻度で行う作業のため、自動化することにしました。

今回の自動化では、以下を実現します。

- Keynote (.key) ファイルをPDFに変換する
- GitHubリポジトリへgit push する
- ローカルのPDFを削除する
- launchdで定刻に自動実行する（週4回: 月・火・火・金）

実際のコードはGitHubに公開しています:

https://github.com/masa0902dev/automation-weekly-report



# 前提
- Shell, Python, Git/GitHubの基礎知識があること
- GitHubとSSH通信できる状態であること（未設定の場合は[下記の記事](https://zenn.dev/masa0902dev/articles/lab-git-github#4.-github%E3%81%AE%E5%A7%8B%E3%82%81%E6%96%B9)を参考にSSHキーの生成と登録を行ってください）

https://zenn.dev/masa0902dev/articles/lab-git-github#4.-github%E3%81%AE%E5%A7%8B%E3%82%81%E6%96%B9

## 動作確認環境
- macOS (M4 chip), Tahoe 26.3.1
- launchd, launchctl: Darwin Bootstrapper Version 7.0.0
- Python 3.13.4



# 全体像

## ディレクトリ構成

```text
my-automation
└── weekly
    ├── com.masa.weekly.push.plist   # launchd設定ファイル
    ├── main.py                      # 自動化スクリプト
    └── miwa                         # GitHubリポジトリ（週報の保存先）
```

`miwa` は週報をpushするGitHubリポジトリをcloneしたディレクトリです。他の自動化とは分けるために `my-automation/weekly/` 以下にまとめています。

## 動作フロー

1. 今月・先月のKeynoteファイルが指定ディレクトリに存在するか確認する
2. AppleScriptを使ってKeynoteをPDFに書き出す（`/tmp` に一時保存）
3. PDFをGitリポジトリディレクトリに移動する
4. `git add`, `git commit`, `git push` を実行する
5. ローカルに残ったPDFを削除する

今月と先月の2か月分を対象にしているのは、月をまたいだタイミングで先月分を更新したい場合があるためです。
また、最後にローカルのPDFを削除しているのは、次回実行時に更新されたPDFをコミットするためです（削除しないと, 変更があるにも関わらず `git status` で変更なしとなってしまう場合があります）。



# コード解説

## main.py

```python
import os
from os import path
import subprocess
from datetime import datetime
from dateutil.relativedelta import relativedelta

# launchd は SSH_AUTH_SOCK を引き継がないため、鍵を明示指定する
SSH_KEY = path.expanduser("~/.ssh/id_ed25519")
os.environ.setdefault(
    "GIT_SSH_COMMAND",
    f"ssh -i {SSH_KEY} -o AddKeysToAgent=yes -o UseKeychain=yes",
)

# 1. パス設定 (環境に合わせて調整してください)
cur_dpath = path.dirname(path.abspath(__file__))
REPO_DIR = path.expanduser(path.join(cur_dpath, "miwa"))  # Gitリポジトリのルート
SOURCE_DIR = path.expanduser("~/Desktop/research/notes")  # 元のKeynoteがある場所
TARGET_REL_DIR = REPO_DIR  # リポジトリ内の保存先

# 2. Git設定
BRANCH_NAME = "miwa"
COMMIT_MESSAGE = (
    f"upload weekly-reports: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
)


def run_command(cmd, cwd=None):
    """コマンドを実行し、失敗したら例外を投げる"""
    result = subprocess.run(cmd, cwd=cwd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        result.check_returncode()
    return result.stdout


def export_keynote_to_pdf(keynote_path, pdf_path):
    """AppleScriptでKeynoteをPDFに書き出す"""
    applescript = f'''
    tell application "Keynote"
        activate
        set theDoc to open POSIX file "{keynote_path}"
        export theDoc to POSIX file "{pdf_path}" as PDF
        close theDoc saving no
    end tell
    '''
    subprocess.run(["osascript", "-e", applescript])


def main():
    def _prepare_git():
        run_command("git status", cwd=REPO_DIR)
        run_command(f"git switch {BRANCH_NAME}", cwd=REPO_DIR)
        run_command(f"git pull origin {BRANCH_NAME}", cwd=REPO_DIR)

    def _export_and_move_pdf():
        for date_obj in target_dates:
            fname = f"weekly{date_obj.strftime('%Y%m')}"
            key_fpath = os.path.join(SOURCE_DIR, f"{fname}.key")
            temp_fpath = os.path.join("/tmp", f"{fname}.pdf")
            pdf_fpath = os.path.join(dest_full_dir, f"{fname}.pdf")
            if os.path.exists(key_fpath):
                print(f"Exporting {fname}.key...")
                export_keynote_to_pdf(key_fpath, temp_fpath)
                # 移動（既存ファイルは上書き）
                if os.path.exists(temp_fpath):
                    os.replace(temp_fpath, pdf_fpath)
                    print(f"Moved to: {pdf_fpath}")
                else:
                    print(f"❌Error: PDF export failed for {key_fpath}")
            else:
                print(f"Skip: {key_fpath} not found.")

    def _git_add_commit_push():
        # 変更があるか確認
        status = run_command("git status --porcelain", cwd=REPO_DIR)
        if status.strip():
            run_command("git add .", cwd=REPO_DIR)
            run_command(f'git commit -m "{COMMIT_MESSAGE}"', cwd=REPO_DIR)
            run_command(f"git push origin {BRANCH_NAME}", cwd=REPO_DIR)
            print("Successfully pushed to origin.")
        else:
            print("No changes to commit.")

    def _remove_committed_pdfs():
        for date_obj in target_dates:
            fname = f"weekly{date_obj.strftime('%Y%m')}"
            pdf_fpath = os.path.join(dest_full_dir, f"{fname}.pdf")
            if os.path.exists(pdf_fpath):
                os.remove(pdf_fpath)
                print(f"Removed local file: {pdf_fpath}")

    dest_full_dir = os.path.join(REPO_DIR, TARGET_REL_DIR)
    os.makedirs(dest_full_dir, exist_ok=True)
    today = datetime.now()
    target_dates = [today, today - relativedelta(months=1)]
    try:
        print("--- Step 1: Git Status & Switch & Pull ---")
        _prepare_git()

        print("--- Step 2: PDF Generation & Move ---")
        _export_and_move_pdf()

        print("--- Step 3: Git Add & Commit & Push ---")
        _git_add_commit_push()

        print("--- Step 4: Remove committed PDFs from local ---")
        _remove_committed_pdfs()
    except subprocess.CalledProcessError as e:
        print(f"\n[FAILED] Script stopped due to an error in command.")
    except Exception as e:
        print(f"\n[ERROR] {e}")


if __name__ == "__main__":
    print(f"weekly report automation at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    main()
    print("\n")
```

冒頭の `GIT_SSH_COMMAND` の設定は、後述するlaunchdのSSH問題への対処です。

ファイル名のルールとして、`weeklyYYYYMM.key`をYYYY年MM月の週報として扱います。（例: `weekly202605.key` → 2026年5月の週報）

## com.masa.weekly.push.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.masa.weekly.push</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/caffeinate</string>
        <string>-i</string>
        <string>/Users/masa/.local/share/mise/installs/python/3.13.4/bin/python3</string>
        <string>/Users/masa/formycode/my-automation/weekly/main.py</string>
    </array>
    <key>StartCalendarInterval</key>
    <array>
        <dict>
            <key>Weekday</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>30</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>30</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>2</integer>
            <key>Hour</key>
            <integer>18</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <dict>
            <key>Weekday</key>
            <integer>5</integer>
            <key>Hour</key>
            <integer>14</integer>
            <key>Minute</key>
            <integer>30</integer>
        </dict>
    </array>
    <key>StandardOutPath</key>
    <string>/tmp/my-automation/weekly.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/my-automation/weekly_err.log</string>
</dict>
</plist>
```

`ProgramArguments` の先頭に `/usr/bin/caffeinate -i` を指定しています。これにより、スクリプト実行中にmacOSがスリープに入らないようにしています。なお、PCがスリープ中はlaunchdによるジョブ実行はされません。スリープが解除されたタイミングで実行されます。

`StartCalendarInterval` の `Weekday` は `0` が日曜日、`1` が月曜日で始まります。上記の設定では, 月（14:30）・火（14:30）・火（18:00）・金（14:30）の週4回実行します。火曜日の2回分は、ゼミ前の分（14:30）・ゼミ後に追記した内容をアップロードするための分（18:00）です。

plistで指定するパスはエイリアスや相対パスが使用できないため、pythonのパスも絶対パスで指定する必要があることに注意.



# セットアップ手順

## 1. 外部パッケージのインストール

```bash
pip install -r requirements.txt
# または
python3 -m pip install -r requirements.txt
```

## 2. main.py の設定変更

以下の変数を自身の環境に合わせて変更してください。

- `SSH_KEY`: GitHubとのSSH秘密鍵ファイルパス
- `REPO_DIR`: 週報をpushするGitリポジトリのルートパス
- `SOURCE_DIR`: Keynoteファイルが置いてあるパス
- `BRANCH_NAME`: pushするブランチ名

## 3. plist の設定変更

以下の箇所を変更してください。

- `Label`: ファイル名と合わせて変更（例: `com.yourname.weekly.push`）
- Pythonのパス: `which python3` などで確認した絶対パスに変更
- `main.py` のパス: 自身のファイルパスの絶対パスに変更
- `StartCalendarInterval`: 実行したい日時に変更
- `StandardOutPath`, `StandardErrorPath`: ログ出力先（そのままでも問題ありません）

## 4. LaunchAgents にplistのシンボリックリンクを配置

```bash
ln -s "$(pwd)/com.masa.weekly.push.plist" ~/Library/LaunchAgents/com.masa.weekly.push.plist
```

## 5. launchd にジョブを登録

```bash
launchctl load ~/Library/LaunchAgents/com.masa.weekly.push.plist
```

plistの内容を変更した場合は、`unload` してから `load` すると確実に反映されます。

```bash
launchctl unload ~/Library/LaunchAgents/com.masa.weekly.push.plist
launchctl load  ~/Library/LaunchAgents/com.masa.weekly.push.plist
```

## 6. Keynoteファイルの準備

`SOURCE_DIR` に `weeklyYYYYMM.key` の形式でKeynoteファイルを置いてください。

```text
例: weekly202605.key  →  2026年5月の週報として扱われます
```

## 7. 動作確認

`launchctl start` で即時実行できます。

```bash
launchctl start com.masa.weekly.push
```

ログを確認して、下記のように出力されていれば成功です。

```log
weekly report automation at 2026-05-16 13:30:05
--- Step 1: Git Status & Switch & Pull ---
--- Step 2: PDF Generation & Move ---
Exporting weekly202605.key...
Moved to: /yourpath/weekly202605.pdf
Exporting weekly202604.key...
Moved to: /yourpath/weekly202604.pdf
--- Step 3: Git Add & Commit & Push ---
Successfully pushed to origin.
--- Step 4: Remove committed PDFs from local ---
Removed local file: /yourpath/weekly202605.pdf
Removed local file: /yourpath/weekly202604.pdf
```

エラーが発生した場合は `weekly_err.log` を確認してください。

# ハマりポイント: launchd が SSH エージェントを継承しない

launchdで `git push` を実行しようとすると、以下のようなエラーが発生しました。

```log
Error: ssh: connect to host github.com port 22: Undefined error: 0
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.

[FAILED] Script stopped due to an error in command.
```

**原因:** launchdによって起動されたプロセスは、ログインセッションのSSHエージェント（`ssh-agent`）を継承しません。通常のターミナルでは `SSH_AUTH_SOCK` 環境変数が設定されており、SSH鍵が自動的に読み込まれますが、launchd経由で実行された場合はこの変数がなく、SSHが秘密鍵を見つけられないため接続に失敗します。

**解決策:** コード先頭で `GIT_SSH_COMMAND` 環境変数を設定し、SSH鍵を明示的に指定します。

```python
SSH_KEY = path.expanduser("~/.ssh/id_ed25519")
os.environ.setdefault(
    "GIT_SSH_COMMAND",
    f"ssh -i {SSH_KEY} -o AddKeysToAgent=yes -o UseKeychain=yes",
)
```

- `-i {SSH_KEY}` で秘密鍵ファイルを明示的に指定する
- `UseKeychain=yes` によりパスフレーズはmacOS Keychainから取得されるので、launchd環境でも対話なしで認証できる
- `setdefault` を使っているので、手動実行時にすでに環境変数が設定されていれば上書きしない

# おわりに

週報のPDF化とGitHubへのpushを自動化することで、ゼミ前後のアップロード忘れがなくなりました。

KeynoteのAppleScript書き出しの部分はPagesでも同様の対応が可能かと思います。PowerPointについては未確認のため、知見がある方はコメントをいただけると幸いです。

コード全体はGitHubに公開しています: https://github.com/masa0902dev/automation-weekly-report
