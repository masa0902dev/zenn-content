---
title: "Claude Codeで /remote-control ができないときの原因と解決法"
emoji: "📱"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["claudecode", "remote", "smartphone"]
published: false
---

# 概要

Claude Codeには, PCで実行しているセッションをスマホ・タブレット・ブラウザから操作できる「Remote Control」という機能があります.

ところが, 環境によっては下記エラーに遭遇することがあります.

```text
Unknown command: /remote-control
```

一見すると「自分のClaude Codeのバージョンが古くてRemote Control機能自体が存在しない」ように思えますが, 実際には最新版のClaude Codeでも, 設定次第でこのエラーが発生します. (npmインストールではなくnativeインストールしていても同様です)

この記事では, 上記のエラーが起きる原因の1つと, その切り分け方・解決法をまとめます.

## 対象読者

- **スマホやタブレットからもClaude Codeを操作したい方**

- **Claude Codeで `/remote-control` や `claude remote-control` を実行してもエラーになって使えない方**

- プライバシーを重視して, テレメトリ送信やエラーレポート送信を無効化する設定を入れている方

## 検証環境

検証に使用した環境は次の通りです.
仕様変更のスピードが早めなので, バージョンが変わると表示されるエラーメッセージや対象となる環境変数が変わる可能性が大いにあります.

- OS: macOS Tahoe 26.5.2

- シェル: zsh 5.9

- Claude Code: v2.1.220 (native インストール, npmインストールではない)

# Remote Controlとは

Remote Controlは, PC上で動いているClaude Codeのセッションに, [claude.ai/code](https://claude.ai/code) やスマホのClaudeアプリから接続して, 続きの操作ができる機能です.

似た名前の機能として, コードをクラウドにアップロードして実行させる「Web上のClaude Code」もありますが, こちらはPCを閉じても処理が継続する代わりに, ローカルのファイルシステムには直接アクセスできません. 一方Remote Controlは, あくまでPC上のプロセスを遠隔操作するだけなので, PCを起動したままにしておく必要があります. この2つの機能はよく混同されるので注意してください.

Remote Controlの起動方法は主に3通りあります.

- 対話セッション中に `/remote-control` (または `/rc`) を実行する

- `claude --remote-control` (または `--rc`) で最初から有効にして起動する

- `claude remote-control` で, サーバーモードとして起動する (複数セッションを同時に受け付けられる)

:::details 「サーバーモード」は「Web上のClaude Code」とは別物
`claude remote-control` の「サーバーモード」は, あくまでRemote Controlの起動方法の1つです. Claudeはローカルマシン上で実行され続ける点は他の起動方法と変わらず, 1つのローカルプロセスが複数のリモートセッションを同時に受け付けられる待受け状態になる, という意味に過ぎません.

一方の「Web上のClaude Code」は, Anthropicが管理するクラウドインフラ上でClaudeが実行される, 全く別の機能です.
:::

詳細は公式ドキュメントを参照してください.

https://code.claude.com/docs/ja/remote-control

# 症状の切り分け

対話セッション中に `/remote-control` を実行して `Unknown command: /remote-control` と表示された場合, このメッセージだけでは原因がまったく分かりません.

そこで, 同じ機能をCLIのサブコマンドとして呼び出してみます.

```bash
claude remote-control --help
```

環境によっては, ここで次のような, より具体的なエラーが表示されます.

```text
Error: Remote Control requires feature-flag evaluation, which is disabled
because DISABLE_TELEMETRY is set. Unset it (or run in a shell without it) to
use Remote Control.
```

つまり, 対話セッション中のスラッシュコマンドでは詳細なエラーが隠蔽されて一律で`Unknown command`と表示されてしまう一方, CLIのサブコマンドとして実行すると, 本当の原因がエラーメッセージとして出てきます. `Unknown command` で行き詰まったときは, まずこのコマンドで原因を切り分けましょう.

# 原因: feature-flag評価のブロック

Remote Controlを使えるかどうかは, サーバー側のfeature-flagを評価して判定されています. この評価には非必須通信 (アカウントの権利確認など) が必要なのですが, いくつかの環境変数が設定されていると, その通信自体がブロックされてしまい, 結果としてRemote Controlが使えなくなります.

公式ドキュメント(英語版)では, 次の4つの環境変数のいずれかが原因になるとされています.

- `DISABLE_TELEMETRY`

- `DO_NOT_TRACK`

- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`

- `DISABLE_GROWTHBOOK`

一方, 筆者が実際に検証した際には, これらに加えて `DISABLE_ERROR_REPORTING` を設定している状態でも同様のエラーが発生しました(`DISABLE_GROWTHBOOK` は未設定だったため, 今回は確認できていません). 公式ドキュメントに明記された4つと, 実際に確認できた組み合わせが完全には一致していないため, バージョンや評価ロジックの詳細によって対象範囲が変わる可能性がある, という前提で読んでください.

いずれにせよ, これらは名前の通り, テレメトリ送信・トラッキング・エラーレポート送信・非必須通信をそれぞれ無効化するための設定で, プライバシーを重視して意図的に設定しているケースが多いと思われます. 1つでも設定されていると他を外してもエラーが再現するため, 心当たりのあるものは全て解除する必要があります.

なお `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` はこの問題とは無関係で, 設定したまま残しても問題ありません.

これらの環境変数は, `~/.claude/settings.json` の `env` に設定されていることが多いでしょう.

:::message
ちなみに, 日本語版の公式ドキュメントのトラブルシューティングページには, このエラーに対応する項目が見当たりませんでした. しかし英語版ドキュメントには「Remote Control requires feature-flag evaluation」という項目が明記されています(バージョン注記によると, v2.1.154で追加されたようです). つまり「公式ドキュメントに載っていない」のではなく, 日本語訳がまだ追いついていないだけのようです.
:::

## 他に考えられる原因: ANTHROPIC_BASE_URL

上記以外にも, `ANTHROPIC_BASE_URL` が `api.anthropic.com` 以外のホスト (LLM Gateway, 自社プロキシなど) を指している場合も, Remote Controlは無効になります. Amazon Bedrock, Google CloudのAgent Platform, Microsoft Foundry経由でClaude Codeを使っている場合も同様に対象外です.

こちらは今回の「feature-flag評価のブロック」とは別の, 「Remote Control is only available when using Claude via api.anthropic.com」という専用のエラーメッセージで案内されます(v2.1.219以降は, 原因となった変数名がメッセージに直接表示されるようです). 心当たりがある場合は, こちらも合わせて確認してください.

# 解決法: 環境変数を外す

`~/.claude/settings.json` の `env` から, 該当する環境変数を削除します. 対象は, 前述の `DISABLE_TELEMETRY` / `DO_NOT_TRACK` / `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` / `DISABLE_GROWTHBOOK` / `DISABLE_ERROR_REPORTING` のうち, 自身の環境で設定しているものです.

```json
{
  "env": {
    "DISABLE_TELEMETRY": "1",
    "DO_NOT_TRACK": "1",
    "DISABLE_ERROR_REPORTING": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

上記のように複数設定されている場合, 該当するものをすべて削除します.

```json
{
  "env": {}
}
```

:::message
Claude Codeの `settings.json` はJSONCではなく通常のJSONとして扱われるため, `//` などによるコメントアウトはできません. 一時的に無効化したいだけの場合でも, 行ごと削除するか, 別ファイルに退避してください.
:::

シェルの環境変数として設定している場合は, `.zshrc` や `.bashrc` などから該当行を削除するか, 一時的に別のシェルで `unset` してから `claude` を起動します.

:::message alert

上記の環境変数を外すと, Claude Codeからのテレメトリ送信・エラーレポート送信・トラッキングがすべて有効に戻ります. もともと意図的にプライバシーを重視してこれらを設定していた場合は, Remote Controlの利便性と天秤にかけて判断してください.

「Remote Controlは使わないと決めている」という場合は, 副作用としてこれらの環境変数に頼るのではなく, Remote Control専用のオフスイッチである `disableRemoteControl` 設定を使う方が, 意図が明確になり分かりやすいです.
:::

# 設定変更後の確認

環境変数を外したら, あらためて `/remote-control` を実行します.

```text
/remote-control

/remote-control is active · Continue here, on your phone, or at https://claude.ai/code/session_xxxxxxxxxxxxxxxx
```

上記のようにセッションURLが表示されれば成功です. スペースバーでQRコードを表示できるので, スマホのClaudeアプリでスキャンして接続を確認してください.

# まとめ

- `/remote-control` が `Unknown command` になる場合, まず `claude remote-control --help` を実行して, より詳しいエラーメッセージが出ないか確認する

- `DISABLE_TELEMETRY` / `DO_NOT_TRACK` / `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` / `DISABLE_GROWTHBOOK` (公式ドキュメント記載) や `DISABLE_ERROR_REPORTING` (筆者の実機検証) が設定されていると, feature-flag評価がブロックされてRemote Controlが使えなくなる

- 解決するには, 心当たりのある環境変数をすべて解除する必要があり, プライバシー設定とのトレードオフになる

- この事象は英語版の公式ドキュメントには載っているが, 日本語版にはまだ反映されていない

- `ANTHROPIC_BASE_URL` が非標準のホストを指している場合も別の原因になり得る

# 参考

https://code.claude.com/docs/ja/remote-control

https://code.claude.com/docs/en/remote-control

https://note.com/suke_ai_code/n/nc438b66af152
