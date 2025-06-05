---
title: "研究室のためのターミナルとエディタの環境構築: bash, VScode"
emoji: "✏️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["terminal", "bash", "editor", "VScode"]
published: false
---

# 0. はじめに
## 扱う内容
- コマンドを打つターミナル・コード(プログラム)を編集するエディタの環境を整える．
  - ターミナルにはGit Bash，シェルにbashを使用する
  - エディタにはVScodeを使用する．
- そもそもターミナル，シェルとは何か？エディタは何ができるのか？

## 対象読者
- 開発環境をお手軽に作りたい人
- VScode, bashで業界標準(?)な環境を作りたい人
- 研究室配属時に開発環境の構築をミスっちゃった人
- エディタやターミナルと聞いても「なにそれ？」な人

基本的にWindowsOS向けです．



# 1. ターミナル: Git Bash
## そもそもターミナルとは？
ターミナルとは，コンピュータに「文字だけ」で命令を伝えるための画面やアプリケーションです．一方で，ボタンをクリックしたりファイルを見た目で表示したりと，直感的な操作が可能になっている物もあります．これらは対比して CLI (Command Line Interface), GUI (Graphical User Interface)と呼ばれます．
ターミナルはコマンドプロンプト・コンソールなどと呼ばれることもあります．Windowsの場合はWindowsターミナルという名称のものがデフォルトで入っており，Macの場合はターミナルという名称のものがデフォルトで入っています．

ターミナルでは例えば，ファイルやディレクトリ(フォルダ)の作成や移動，プログラムの実行などを，コマンドを入力して操作します．初心者には難しく感じるかもしれませんが，慣れると作業がとても効率的になります．そもそも，ターミナル経由でしか行えない処理がたくさんあります．

コマンドの例↓ いま覚える必要は全くありません．
ターミナルで色々便利なことができるんだな，と実感してもらえればOKです．
```bash
# Pythonファイルを実行し，出力をコピーする
python main.py | pbcopy

# ファイル内でbashという単語が何回使われているかを調べる例（大文字小文字を問わない）
cat articles/editor-terminal-vscode-git-bash.md | grep -i "bash" | wc -l

# GithubのPRを作成する例
gh pr create --base main --head fix/api-xxx \
--title "fix: pr title yyy" --fill-verbose --reviewer awesomedev
```

### ターミナルとシェル
少し紛らわしい概念として，シェル(Shell)があります．
シェルとは，ターミナルの命令を受け取って解釈し，OSへ伝える役割を持つCLIです．つまり，人間が打ったコマンドは ターミナル -> シェル -> OS というように流れていきます．

ターミナルは人間が目にする表面を担当しているに過ぎず，ターミナルよりもシェルの方がマシンにとって重要と表現できます．
そこで，何のシェルを使っているか，というのが問題になってきます．なぜなら，シェルが違えばOSへ伝える命令の内容が大きく変わってしまい，ターミナルで同じコマンドを人間が打ったとしても動かない・違う動作をする，などの現象が起こりうるからです（ターミナルは表面だけなので，種類が違ってもそこまで問題になりません）．
シェルは有名どころだけでも，sh, csh, tcsh, ksh, bash, zsh, fish, PowerShell (windows)...など多くの種類があります．では，どのシェルを使えば良いのでしょうか？

**基本的には，シェルには`bash`を使えばOKです**．なぜなら，研究室で使う計算機サーバやスパコンのシェルの多くはbashだからです（企業のシステムも大体はそうです）．
MacOSの場合はデフォルトでzshになっていますが，無理にbashに変えなくとも問題ありません．なぜなら，zshとbashで互換性のあるコマンドは多く，bash環境をエミュレートできるモードによって動作確認してから実行することも可能だからです．

本記事では，ターミナルにGit Bash，シェルにbashを使用します．
シェルの選定理由は上記の通り．ターミナルの選定理由は，お手軽に使えるからです．Git BashはGitをインストールする際に一緒についてくるため，特にWindowsOSにてお手軽にbashを使うのに適しています．


## インストール
こちらの「3. Gitのはじめ方」セクションを参照してください．
https://zenn.dev/masa0902dev/articles/lab-git-github



# 2. エディタ: VScode
## そもそもエディタとは？
エディタとは，コード(プログラム)を書くためのツールです．

じゃあWordやメモ帳でいいんじゃないの？と思うかもしれませんが，勿論そんな事はありません．現在のエディタは，サジェスト機能や言語ハイライト機能など，多くの機能が備わっており，ただのメモ帳でコードを書くよりも圧倒的に描きやすくなっています．下記の画像の通り，見やすさだけでもかなり違うことがわかると思います．

| メモ帳で書いたコードの例 | VScodeで書いたコードの例 |
| --- | --- |
| ![メモ帳で書いたコードの例](/images/code-note.png =200x) | ![VScodeで書いたコードの例](/images/code-vscode.png =225x) |

エディタにも種類はたくさんあり，emacs, vi, VScode, Atom, IntelliJ, Pycharm…等があります．
しかし現在では，実は「純粋な」エディタで有名なものは emacs, vi くらいです．多くのエディタは，コードを書くだけでなく，例えばターミナルやデバッガ，ファイルエクスプローラ等の機能を統合しているため，IDE (Integrated Development Environment)と呼ばれます．

VScodeもIDEと呼ばれるものの１つで，少なくともソフトウェアエンジニアリング領域では業界標準になっていると認識しています．

### VScodeについて
![VScodeの見た目](/images/vscode-img.png)

本記事でVScodeを使用する理由は，インストールが簡単・軽量・無料・操作がわかりやすい・多くの人が使っている，からです．
多くの人が使っていれば，問題発生時にウェブ上で記事を見つけて解決できる場合が多いですし，周りに使っている人が多いので直接聞くこともできます．著者もVScodeを使っています（少し前まではCursorでしたがVScodeに戻ってきました）．

また，VScodeではExtensionという機能があります．
Extensionはクリック操作で簡単にインストールでき，VScodeをより便利にすることができます．例えば，関数ジャンプを有効にしたり，エラーをエディタ内に表示したり，GUIでgit操作をしたり，コードフォーマッタをお手軽に使ったり…など色々な機能があります．

**さらに，学生・教員なら無料でGithub Copilot Proを使用できます！**
Copilotはいわゆる生成AIで，エディタ内でコードを提示してくれたり，VScode内でファイルを認識させた上でAIとチャットしたりすることができます．
学生・教員ならGithub Proを無料で使うことができ，その内容としてCopilot Proを無料で使えます．やり方は下記記事がわかりやすいかと思います．学生・教員はぜひ登録してください（大学規約は確認しましょう）．
https://zenn.dev/iput_app/articles/77809fa7dd59be

最後に，VScodeはGUIでのgit操作をデフォルトで提供しています．
これからgit,githubを使おうという方は，最初のうちはCLIではなくGUIを使った方がハードルが低くて良いかと思います．下記記事がVScodeのGUIでのgit,github操作について分かりやすく網羅的です．
https://zenn.dev/praha/articles/db1c4bcc4ef48c

## インストール
公式サイトからインストールしましょう．
https://code.visualstudio.com/

### インストール時のアドバイス
あなたが「32bit，64bit，ARMとか，どれを入れればいいのか分からない！」という場合は，Windowsなら大体の人は64bitを選べばOKです．

Windowsは，「設定」からシステム>バージョン情報のデバイスの使用に書いてあるものをインストールしましょう．自分のWindowsPCだと「システムの種類」が”64 ビット オペレーティング システム，x64 ベース プロセッサ”とあるので64bitです．

## インストーラーのセットアップ
特に大事なのが，`code`コマンド設定と`PATH`への追加です．

こちらの記事に従うとイイ感じになります．
https://www.kikagaku.co.jp/kikagaku-blog/visual-studio-code-windows/#i-0

codeコマンドは指定パスをvscodeで開くコマンドです．毎日使うことになります．

PATHが何か分からない場合は下記記事が分かりやすいです（分からずとも本記事では問題なし）．
https://wa3.i-3-i.info/word18470.html
https://qiita.com/ryouya3948/items/8edbd5d744c83dd41141

## 動作確認
ダウンロードされたVScodeを開いてみましょう．
Windowsなら，ホーム画面下の検索窓で検索すればアプリが見つかるはずです．

無事にVScodeを開けたら，PCを再起動します．
再起動の目的は，上述したcodeコマンドを有効化するためです．

再起動後，VScodeを開いて…
1. ctrl J を押す（VScode内のターミナルを開く）
2. `code -v`と入力してEnterを押す (codeコマンドが有効になっているか確認)
3. ターミナルに下記のように表示されればOK！
```bash
1.100.3
258e40f...{長い文字列}...
x64
```

## VScodeの最低限の設定
VScodeは設定が大量にあります．毎日使うものなので，色々設定できるのはありがたい．
しかし，よく分からないうちは下記3つだけ設定すれば十分です！


### 自動保存
コードが自動保存されるようにします．
この設定なしでは，ctrl Sを押さないとコードが保存されません．

1. ctrl shift P を押す（コマンドパネルを開く）
2. open user settings と入力してEnter（ユーザ設定をGUIで設定する）
3. 検索窓に auto save と入力し，出てきた設定項目を"off"から"onFocusChange"に変更

### デフォルトのシェルを設定
VScode内で開かれるターミナル（integrated terminla）のシェルをGit Bashに設定します．

1. ctrl shift P
2. select default profile と入力してEnter
3. Git Bashを選択

### テーマ設定
VScode全体のテーマ(Theme)を設定する事で，見た目を簡単に変えられます．
作業効率は見た目だけで変わるものです．目の疲れ，コードのハイライトなど，自分に合うものを選びましょう．気分転換にヘンなテーマを使うのも良いですね．

1. ctrl shift P
2. preferences: color theme と入力してEnter
3. お好きなテーマをEnterで選択

デフォルトでは15個ほどしかテーマはありませんが，"Browse Additional Color Themes"から大量のテーマを見ることができます．ちなみに著者はAyu Migrateというテーマを少しカスタムして使っています．

| dark | light |
| --- | --- |
| ![VScodeのダークテーマ](/images/vscode-theme-dark.png) | ![VScodeのライトテーマ](/images/vscode-theme-light.png) |

| fairyfloss | Ayu Migrate (customized) |
| --- | --- |
| ![VScodeのfairyflossテーマ](/images/vscode-theme-fairyfloss.png) | ![VScodeのAyuテーマ](/images/vscode-theme-ayu-customised.png) |

#### BONUS: フォント設定
エディタとターミナルで表示するフォント(font)を見やすいものに設定します．
十分見やすいよ！という人は飛ばしてOKです．

著者おすすめの FiraCode Nerd Font Mono を設定します．

1. [こちらのダウンロードサイト](https://www.nerdfonts.com/font-downloads)からフォントをダウンロード
2. Windowsの場合，ダウンロードした内容を[こちらを参考に](https://support.microsoft.com/ja-jp/office/%E3%83%95%E3%82%A9%E3%83%B3%E3%83%88%E3%82%92%E8%BF%BD%E5%8A%A0%E3%81%99%E3%82%8B-b7c5f17c-4426-4b53-967f-455339c564c1)フォントを使用可能にする．
3. ctrl shift P
4. open user settings でEnter
5. 検索欄にfontと入力し，EditorのFont Familyを'FiraCode Nerd Font Mono'に設定．
6. 検索欄にterminal fontと入力し，Terminal IntegratedのFont Familyを'FiraCode Nerd Font Mono'に設定．

フォントが適用されていればOK！

Macの場合は，homebrewを使ってNerdFontをインストールするのが良いでしょう．



## VScodeの最低限のショートカットキー
ショートカットキーは最低限これを覚えれば，あとは自分で調べて使っていけます．(著者が頻繁に使うのはせいぜい30個です)
- ターミナルの開閉: **ctrl J**
- サイドバーの開閉: **ctrl B**

![VScodeの領域の名称](/images/vscode-area-name.png)

ターミナルは表示位置を下部分にしたり，エディタ部分にターミナルを表示することもできます．

サイドバーでは，例えば以下のようなことができます．
- ディレクトリとファイルを閲覧，作成/削除/名称変更，エディタへ開く
- GUIでGit操作
- ファイル検索
- デバッグ
- Extensionのインストールや管理


## VScodeの最低限のExtension
TODO: Extensionから書く．ちなみに，VScode bashのハンズオンでは動画はいらない．ターミナル・シェル，エディタの説明だけ先に俺がやって，その他は俺の説明なしで各自やってくださいにする．
### 共通
1. Error Lens
2. GitHut Copilot / Copilot Chat
3. Rainbow Indent
4. CSV Rainbow

### 言語ごと
1. 公式Extension
2. フォーマッタ



# コードを書く前の準備
## 開発ディレクトリを決めよう
ターミナルやエディタ以前のこととして，コードを書くディレクトリ(開発ディレクトリ)は決めておきましょう．

例えば，HOMEディレクトリ直下に`formycode`のようなディレクトリを作って，その中にプロジェクトごとにディレクトリを作りましょう．（HOMEディレクトリとは，あなたがターミナルを開いた時に最初にいるディレクトリで，`echo $HOME`で表示されるパスのことです．大体は`/User/{username}`です．）

:::message alert 
開発ディレクトリのNGな場所

OneDriveやiCloudの管理下にあるディレクトリに開発ディレクトリを置くのは避けましょう．なぜなら，下記のようなデメリットがあるからです．
1. クラウドとの通信で処理が遅くなることがある．
2. クラウドへ編集内容が反映されなかったり，`main.py 2`, `main.py 3`, ...のようなファイルが作られたりする．（著者は`main.py 2`で痛い目を見ました）
:::

イメージとしては下記のようになります．
```bash
.  # HOMEディレクトリ
├── Desktop
├── Documents
├── Downloads
├── Library
├── Movies
├── formycode  # ここが著者の開発ディレクトリ
      ├── college
      │   ├── class_kansei
      │   ├── class_software
      │   ├── info_security
      │   └── machine-learning
      ├── dsa
      │   ├── README.md
      │   ├── atcoder
      │   ├── go.mod
      │   ├── go.sum
      │   ├── main.py
      │   └── util
      ├── isobe-lab
          ├── ecmc-nec
          ├── edmd-event-calendar
          ├── github-apps
          ├── handson-contents
          ├── hp
          ├── isobe-org
          ├── purego
          └── zero-python
...
```

もし過去に書いたコードがある場合，ファイルエクスプローラー(Windowsの黄色いフォルダのアイコンのやつ🗂️)などでファイルを開発ディレクトリに移動させましょう．

## 実際にVScodeでコードを書いてみよう
