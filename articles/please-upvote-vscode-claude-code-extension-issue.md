---
title: "VScode拡張機能ClaudeCodeのIssue#66291にUpvoteを!"
emoji: "❗️"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["VScode", "ClaudeCode", "issue"]
published: true
---


# TL;DR
VScodeの拡張機能 `Claude Code for VScode` (by Anthropic) のチャット入力欄で, `ctrl+P` や `ctrl+F` といったmacOS標準のカーソル移動キーが効かない問題があります. これはあまりにも不便です.
ユーザが動かないとIssueが自動クローズされてしまうため, 同じ問題で困っている方はぜひ下記のご協力をお願いします.


# Upvoteのお願い

https://github.com/anthropics/claude-code/issues/66291

上記Issueページにアクセスし, 下記の2つをどうかお願いします.
- dvdrtrgn氏(投稿者)のコメントに「👍」をつける.
- Botのコメントに「👎」をつける.

Upvoteが集まることで, Anthropic社がこの問題を優先対応する可能性が高まります. また, Botにbadを付けないとIssueが自動クローズされてしまいます. (過去も複数の類似Issueが自動クローズされています…)

| 👍                                                                                                        | 👎                                                                                                      |
| -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| ![good-emoji-target.png](/images/please-upvote-vscode-claude-code-extension-issue/good-emoji-target.png) | ![bad-emoji-target.png](/images/please-upvote-vscode-claude-code-extension-issue/bad-emoji-target.png) |


## このUpvoteが必要な理由

過去にも, 同様のキーバインド関連Issue (#8177, #12358, #21137 等) が複数報告されていますが, そのほとんどは `NOT_PLANNED` と処理されるか, Botによって未解決のまま自動クローズされています.

VS Code拡張機能のGUIにおけるキーバインディング問題については, 開発元による優先度が低く設定されがちなようです. **多くのユーザーが困っているという声を数字で示すことが, 対応を促す最も有効な手段でしょう.**


## 問題の詳細

`ctrl+P` (カーソルを上に移動) や `ctrl+F` (カーソルを右に移動) といったEmacsスタイルの標準キーバインディングが, Claude CodeのチャットGUI上では機能しません. VScodeの `keybindings.json` を編集しても解決せず, CLI版では対応済みであるにもかかわらず, GUI版では未解決のままになっています.

- **根本原因**
  - VS Codeのワークベンチコマンドが, macOSのCocoaテキストレイヤーへキーイベントが到達する前に `ctrl+F` や `ctrl+P` を消費してしまっています. 拡張機能側がキーイベントを透過させるか, VS Code本体側が修正しない限り, ユーザー側の設定では完全な解決が難しい状態です. (参考: microsoft/vscode#320435)

- **現時点での回避策**
  - Karabiner-Elements を使用することで回避できますが, 外部ツールを別途導入する必要があり, 標準での解決が望まれます.

`Developer: Inspect Context Keys`を使えば指定UIコンテキストでどのコマンドが有効になっているかを確認できるのですが, Claude Codeのパネルではそれさえできない状態です. これでは, ユーザー側での回避策も非常に限られてしまいます.


# 拡散のお願い

この記事とIssueをSNS・ブログ等でシェアしていただけると, より多くの人に問題を知ってもらえます. ご協力よろしくお願いします.

```txt:please-share!
VScodeでのClaudeCodeで ctrl+P, ctrl+F といったmacOS標準のカーソル移動キーが効かない問題があります. これはあまりにも不便です.

ユーザが動かないとIssueが自動クローズされてしまうため, 同じ問題で困っている方はぜひ記事内のご協力を!!!

#ClaudeCode #VScode

https://zenn.dev/masa0902dev/articles/please-upvote-vscode-claude-code-extension-issue
```
