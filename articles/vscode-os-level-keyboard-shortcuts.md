---
title: "VSCode 1.128 の OS-level keyboard shortcuts を実機で検証してわかったこと"
emoji: "⌨️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vscode", "electron", "macos", "claudecode"]
published: true
---

VSCode 1.128 にて "OS-level keyboard shortcuts" という, VSCodeがフォーカスされていなくても発火するキーボードショートカットを登録できる機能が追加されました.
`keybindings.json`のキーバインド定義に`"systemWide": true`を追加するだけで, そのキーバインドがOSレベルのグローバルショートカットとして登録されます.

```jsonc
{
  "key": "cmd+shift+a",
  "command": "workbench.action.openAgentsWindow",
  "systemWide": true,
}
```

ただし, 公式のリリースノートの説明はかなり薄く, 実際にどう動くのか, どんな制約があるのかはあまり書かれていません.

そこで本記事では, 実装元のPRと, 実機 (VSCode 1.128.0, macOS) での検証を通して分かった, 実用上の注意点やユースケースをまとめます.

https://code.visualstudio.com/updates/v1_128

## 基本の使い方

`keybindings.json`に登録したいキーバインドを追加し, `"systemWide": true`を付けるだけ.

例えば, 他のアプリで作業中でもQuick Openを呼び出せるようにする場合は, 次のように書きます.

```jsonc
{
  "key": "shift+cmd+p",
  "command": "runCommands",
  "args": {
    "commands": ["workbench.action.focusWindow", "workbench.action.quickOpen"],
  },
  "systemWide": true,
}
```

単に`command`にコマンドを1つ指定するだけでも動きますが, この例のように`runCommands`で`workbench.action.focusWindow`を先に実行しているのには理由があります. systemWideキーバインドは, デフォルトではVSCodeのウィンドウを前面に出しません. トリガーされたコマンド自身がウィンドウを出す/フォーカスするかどうかを決める仕組みになっているため, Quick Openのように「今のウィンドウにUIを出したい」コマンドの場合は, 新設された`workbench.action.focusWindow`をあわせて実行してウィンドウを前面に出してあげる必要があります.

## 仕様上の制約

実装元のPR (後述) やVSCode本体の設定説明文には, 以下のような制約が明記されています.

- デスクトップ版のみ, かつユーザーの`keybindings.json`のみが対象. 拡張機能が寄与するキーバインドやデフォルトキーバインドをsystemWide化することはできない.

- 単一キーコンボのみ対応しており, chord (連続キー) は指定できない. 指定した場合は登録時に警告が出て無視される.

- `when`句はグローバル発火では無視され, 常に有効になる. 特定のエディタ状態に限定した発火はできない.

- OSや他のアプリケーションにキーの組み合わせを奪われている場合は, 登録自体に失敗する.

## 実際に試して分かったハマりどころ

ここからは, 実際にVSCode 1.128.0 (macOS) で試して分かったことです.

### 初回確認ダイアログが出ない

実装元のPRの説明では, systemWideキーバインドを初めて登録する際に「I Understand」ボタン付きの確認ダイアログが一度だけ表示される, と書かれていました. しかし, 実機で試したところこのダイアログは表示されませんでした.

VSCodeのグローバルストレージや, 本体の圧縮済みソースコード内の文字列を調べても, それらしい通知文言は見当たりませんでした. PRの説明にあった実装が, 最終的なリリースには含まれなかった可能性があります. PRの記述と実際にリリースされた挙動が食い違っている, という点は覚えておいて良さそうです.

### 複数ウィンドウでの発火ルール

VSCodeのウィンドウを複数開いた状態でsystemWideキーバインドを使うと, 意図しないウィンドウでコマンドが発火することがあります.

実際に2〜3ウィンドウを開いて検証したところ, 次のような規則性が確認できました.

- 先に開いた (先に登録した) ウィンドウが優先される. フォーカス状態によって優先が変わることはない.

- 優先されているウィンドウを閉じると, 次に古い生存ウィンドウに引き継がれる.

- 一度閉じたウィンドウを再度開いても, 優先権は戻らない.

例えば, ウィンドウをA→B→Cの順で開いた場合, ショートカットは常にAで発火します. Aを閉じるとBに引き継がれ, さらにBを閉じるとCに引き継がれます. 「今アクティブなウィンドウで発火する」と誤解しやすいところなので, 複数ウィンドウで作業する人は注意が必要です.

### systemWideをfalseに戻してもショートカットが復活しない

`systemWide: true`にしていたキーバインドを試しに`false`へ戻したところ, そのショートカットがVSCode内でも使えなくなる現象が発生しました.

コマンドパレットから「Developer: Reload Window」を実行しても直らず, VSCodeを完全に終了 (cmd+Q) してから起動すると, ショートカットが元通り使えるようになりました.

systemWideの登録はElectronのメインプロセス側が保持しており, `keybindings.json`の変更はレンダラーからメインプロセスへ同期される仕組みです. Reload Windowはレンダラーの再起動にとどまりメインプロセスは再起動されないため, 一度OSに奪われたキーの登録が残ったままになり, 完全に終了して再起動するまで解除されないのだと考えられます.

一度`systemWide: true`を試してみて, やはり通常のローカルなキーバインドに戻したい場合は, ウィンドウのリロードではなくVSCode自体の完全な終了と再起動が必要になる点に注意してください.

## Claude Codeの機能をどこからでも呼び出し

普段使っている拡張機能であるClaude Codeを題材に, 実際のユースケースを試してみました.

### Claude Codeサイドバーの呼び出し

まず, Claude Codeのサイドバーを他のアプリからでも呼び出せるようにしたいと考え, 素直に次のようなキーバインドを作りました.

```jsonc
{
  "key": "ctrl+cmd+i",
  "command": "workbench.view.extension.claude-sidebar-secondary",
  "systemWide": true,
}
```

しかし, このキーを押してもサイドバーが表示された様子はありませんでした. `workbench.action.openAgentsWindow`のように自前でウィンドウを前面に出す実装を持つコマンドではないため, サイドバーの切り替え自体は起きていても, VSCodeのウィンドウが背面のままで見えていなかったと考えられます.

そこで, 前述の`workbench.action.focusWindow`と`runCommands`で組み合わせたところ, 解決しました.

```jsonc
{
  "key": "ctrl+cmd+i",
  "command": "runCommands",
  "args": {
    "commands": [
      "workbench.action.focusWindow",
      "workbench.view.extension.claude-sidebar-secondary",
    ],
  },
  "systemWide": true,
}
```

他のアプリで作業中でも, ウィンドウが前面に出た上でClaude Codeサイドバーが開くようになりました.

### セッション履歴の呼び出しとキーボード操作の制約

同じ要領で, Claude Codeのセッション履歴サイドバー (`workbench.view.extension.claude-sessions-sidebar`) も呼び出せるようにしてみました.

```jsonc
{
  "key": "ctrl+cmd+h",
  "command": "runCommands",
  "args": {
    "commands": [
      "workbench.action.focusWindow",
      "workbench.view.extension.claude-sessions-sidebar",
    ],
  },
  "systemWide": true,
}
```

表示自体はVSCode内外どちらからでも問題なく成功しました. しかし, 開いた履歴一覧を十字キーやTabで選択しようとしたところ, 反応しませんでした.

切り分けとして, 同じセッション履歴をsystemWideショートカットを使わず, アクティビティバーのアイコンを普通にクリックして開いた場合を試すと, 十字キーやTabでの選択は問題なくできました. つまり, systemWide経由で開いた場合に特有の問題だと確認できました.

## 表示/実行はできても, フォーカスは移譲されない

セッション履歴でのキーボード操作不能問題は, systemWide経由のコマンド実行の性質から説明できると考えています.

systemWide経由のコマンド実行は, OSのグローバルショートカットからメインプロセスを経由してコマンドを実行する, プログラム的な経路です. 実際のキーボードイベントやフォーカスの移譲を伴いません.

そのため,

- 表示状態の切り替えだけで完結するコマンド (`togglePanel`や`terminal.focus`など) は問題なく動く

- webview内部のキーボード操作のように, 実際のDOMフォーカスを必要とする操作は, 表示こそされてもフォーカスが伴わないため機能しない

`workbench.action.focusWindow`は, あくまで「ウィンドウ」を前面に出すだけであり, ウィンドウ内の特定の要素へのフォーカスまでは面倒を見てくれません. systemWideキーバインドは, UIの表示や単純なコマンドの実行はできても, その後のキーボード操作の主体そのものにはなれない, という前提で使うのが良さそうです.

## まとめ

VSCode 1.128で追加されたOS-level keyboard shortcutsは, 公式の説明が薄いわりに, 実際に触ってみると独自の癖が多い印象でした.

- 表示切り替えのような単純なコマンドは問題なく動く

- ウィンドウを前面に出したい場合は`workbench.action.focusWindow`との組み合わせが定石になる

- webview内部のキーボード操作のように, 実際のフォーカスを必要とする操作は期待通りに動かないことがある

- 複数ウィンドウ環境では, 発火先が「今アクティブなウィンドウ」ではなく「先に開いたウィンドウ」になる

- systemWideをfalseに戻す場合は, ウィンドウのリロードではなくVSCode自体の完全な終了と再起動(cmd+Q)が必要になる

リリースされたばかりの機能のため, 今後のアップデートで挙動が変わる可能性は十分にあります. 気になる方は, ぜひ手元でも試してみてください.

## 参考資料

https://code.visualstudio.com/updates/v1_128

https://github.com/microsoft/vscode/pull/323871

https://www.neowin.net/news/microsoft-releases-visual-studio-code-1128-with-os-level-keyboard-shortcuts/

https://windowsforum.com/threads/vs-code-1-128-windows-11-os-level-shortcuts-and-browser-tab-placement.435874/
