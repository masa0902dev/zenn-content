---
title: "研究室のためのターミナル, エディタの開発環境: bash, VScode"
emoji: "✏️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["研究", "terminal", "bash", "editor", "VScode"]
published: true
---

# 0. はじめに
## 扱う内容
✅扱う内容
- コマンドを打つターミナル・コード(プログラム)を編集するエディタの環境を作る
  - ターミナルにはGit Bash, シェルにはbashを使用する
  - エディタにはVScodeを使用する
- そもそもターミナルやシェルとは何か？エディタは何ができるのか？
- VScodeとbashを用いた開発ハンズオン

❌扱わない内容
- [Gitのインストールと初期設定](https://zenn.dev/masa0902dev/articles/lab-git-github)
- シェルスクリプトの詳細な解説



## 対象読者
- 非情報系の研究室で, 開発環境を手軽に構築したい人
- bash, VScodeで業界標準の開発環境を作りたい人
- 研究室配属時に開発環境の構築をミスっちゃった人
- ターミナルやエディタと聞いても「なにそれ？」な人

基本的にWindowsOS向けですが, MacOSでもほぼ同様に適用できます. 

:::details 目次
- [0. はじめに](#0-はじめに)
  - [扱う内容](#扱う内容)
  - [対象読者](#対象読者)
- [1. ターミナル: Git Bash](#1-ターミナル-git-bash)
  - [そもそもターミナルとは？](#そもそもターミナルとは)
    - [ターミナルとシェル](#ターミナルとシェル)
  - [インストール](#インストール)
- [2. エディタ: VScode](#2-エディタ-vscode)
  - [そもそもエディタとは？](#そもそもエディタとは)
    - [VScodeについて](#vscodeについて)
    - [Github Copilot について](#github-copilot-について)
  - [インストール](#インストール-1)
  - [インストーラーのセットアップ](#インストーラーのセットアップ)
  - [動作確認](#動作確認)
  - [最低限の設定](#最低限の設定)
    - [自動保存](#自動保存)
    - [デフォルトのシェル](#デフォルトのシェル)
    - [各言語のインデント](#各言語のインデント)
    - [gitのエディタをVScodeにする](#gitのエディタをvscodeにする)
    - [テーマ設定](#テーマ設定)
      - [BONUS: フォント設定](#bonus-フォント設定)
  - [最低限のショートカットキー](#最低限のショートカットキー)
  - [最低限のExtension](#最低限のextension)
    - [共通](#共通)
      - [Error Lens](#error-lens)
      - [Github Copilot / Copilot Chat](#github-copilot--copilot-chat)
      - [indent-rainbow](#indent-rainbow)
      - [Rainbow CSV](#rainbow-csv)
    - [言語ごと](#言語ごと)
      - [Language Support](#language-support)
      - [フォーマッタ](#フォーマッタ)
- [3. 実際に開発してみよう](#3-実際に開発してみよう)
  - [その前に開発ディレクトリを決めよう](#その前に開発ディレクトリを決めよう)
  - [VScodeで開発してみよう](#vscodeで開発してみよう)
  - [BONUS: 良いコードについて](#bonus-良いコードについて)
- [4. おわりに](#4-おわりに)

:::

# 1. ターミナル: Git Bash
## そもそもターミナルとは？
ターミナルとは, コンピュータに「文字だけ」で命令を伝えるための画面やアプリケーションです. 一方で, ボタンをクリックしたりファイルを見た目で表示したりと, 直感的な操作が可能になっているアプリケーションもあります. これらは対比して CLI (Command Line Interface), GUI (Graphical User Interface)と呼ばれます. 
ターミナルはコマンドプロンプト, コンソールなどと呼ばれることもあります. WindowsOSにはデフォルトで「Windowsターミナル」アプリが, MacOSにはデフォルトで「ターミナル」アプリが搭載されています. 

ターミナルでは例えば, ファイルやディレクトリ(フォルダ)の作成や移動, プログラムの実行などを, コマンドを入力して操作します. はじめは難しく感じるかもしれませんが, 慣れると作業がとても効率的になります. ターミナル経由でしか行えない処理がたくさんあるため, ターミナルは開発に必須のツールといえます.

下記はコマンドの例です. いま覚える必要は全くありません. 
ターミナルで色々便利なことができるんだな, と実感してもらえればOKです. 
```bash
# Pythonファイルを実行し, 出力をコピーする
python main.py | pbcopy

# ファイル内でbashという単語が使われている文とその周辺のテキストを表示（大文字小文字を問わない）
cat articles/editor-terminal.md | grep -i -C 2 "bash"

# GithubのPRをオプション付きで作成する
gh pr create --base main --head fix/api-xxx \
--title "fix: pr title yyy" --fill-verbose --reviewer awesomedev
```

### ターミナルとシェル
ここで, 少し紛らわしい概念であるシェル(Shell)について説明します.
シェルとは, ターミナルの命令を受け取って解釈し, OSへ伝える役割を持つCLIです. つまり, 人間が打ったコマンドは ターミナル -> シェル -> OS というように流れていきます. 

ターミナルはユーザが目にするインターフェースに過ぎず, 実際の処理はシェルが担っています.
そのため, どのシェルを使うかが重要になります. なぜなら, シェルが異なるとOSに渡される命令が変わるため, 同じコマンドを入力しても動作しない, あるいは挙動が異なる場合があるからです（ターミナルは表面に過ぎないので, 種類が変わっても影響は基本的にありません）．
シェルは有名どころだけでも, sh, csh ksh, bash, zsh, fish, PowerShell (windows) … など多くの種類があります. では, どのシェルを使えば良いのでしょうか？

**基本的には, シェルには`bash`を使えばOKです**. なぜなら, 多くの場合, 研究室で使う計算機サーバやスパコンのシェルはbashだからです（企業システムも大体はそうです）. 
MacOSではデフォルトシェルがzshになっていますが, 無理にbashに変える必要はありません. なぜなら, zshはbashと互換性の高いコマンドを多くサポートしており, bash互換モードで動作確認することも可能だからです.

本記事では, ターミナルにGit Bashを, シェルにbashを使用します. 
シェルの選定理由は上記の通りで, ターミナルの選定理由は, お手軽に使えるからです. Git BashはGitをインストールする際に一緒についてくるため, 特にWindowsOSでお手軽にbashを使うのに適しています. 



## インストール
こちらの「3. Gitの始め方」セクションを参照してください. 
https://zenn.dev/masa0902dev/articles/lab-git-github#3.-git%E3%81%AE%E5%A7%8B%E3%82%81%E6%96%B9






# 2. エディタ: VScode
## そもそもエディタとは？
エディタとは, コード(プログラム)を書くためのツールです. 

じゃあWordやメモ帳でいいんじゃないの？と思うかもしれませんが, 勿論そんな事はありません. 現在のエディタは, サジェスト機能・言語ハイライト機能・コードジャンプ・AI補助など多くの機能が備わっており, ただのメモ帳でコードを書くよりも圧倒的に開発しやすくなっています. 下記の画像の通り, 見やすさだけでもかなり違うことがわかると思います. 

| メモ帳で書いたコードの例 | VScodeで書いたコードの例 |
| --- | --- |
| ![メモ帳で書いたコードの例](/images/code-note.png =200x) | ![VScodeで書いたコードの例](/images/code-vscode.png =225x) |

エディタにも種類はたくさんあり, emacs, vi, VScode, Atom, IntelliJ, Pycharm … などがあります. 
しかし現在では, 実は「純粋な」エディタで有名なものは emacs, vi くらいです. 多くのエディタはコードを書くだけでなく, 例えばターミナルやデバッガ, ファイルエクスプローラ等の機能を統合しており, IDE (Integrated Development Environment) と呼ばれることが多いです.

VScodeもIDEと呼ばれるエディタの1つで, (少なくとも)ソフトウェアエンジニアリング領域では業界標準の1つとなっています.

### VScodeについて
![VScodeの見た目](/images/vscode-img.png)

本記事でVScodeを使用する理由は, インストールが簡単・軽量・無料・操作がわかりやすい・多くの人が使っている, からです. 
多くの人が使っていれば, 問題発生時にウェブ上で記事を見つけて解決できる場合が多いですし, 周りに使っている人が多いので直接聞くこともできます. 著者もVScodeを使っています（少し前まではCursorでしたがVScodeに戻ってきました）. 

また, VScodeではExtensionという機能があります. 
Extensionは簡単にインストールでき, VScodeをより便利にすることができます. 例えば, コードジャンプを有効にしたり, エラーをエディタ内に表示したり, コードフォーマッタをお手軽に使ったり…など色々な機能があります. 

さらに, VScodeはGUIでのgit/github操作をデフォルトで提供しています. 
これからgit/githubを使おうという方は, CLIではなくGUIを使った方がハードルが低くて良いかと思います. 下記記事がVScodeのGUIでのgit/github操作について分かりやすく網羅的です. 
https://zenn.dev/praha/articles/db1c4bcc4ef48c

### Github Copilot について
**学生・教員であれば, 無料でGithub Copilot Proを使用できます！**
Copilotはいわゆる生成AIです. エディタ内でコードを提示してくれたり, VScode内でファイルを認識させた上でAIとチャットしたりすることができます. 
学生・教員ならGithub ProというGithubのプランを無料利用でき, その内容としてCopilot Proを無料で使えます. やり方は下記記事がわかりやすいです. 学生・教員の方はぜひ登録してください. （大学によっては生成AIの利用を規制しているかもしれません. 念のため確認しましょう. ）
https://zenn.dev/iput_app/articles/77809fa7dd59be



## インストール
公式サイトからインストールしましょう. 
https://code.visualstudio.com/

**インストール時のアドバイス:**
あなたが「32bit, 64bit, ARMとか, どれを入れればいいのか分からない！」という場合は, Windowsなら大体は64bitを選べばOKです. 

Windowsは, 「設定」から「システム > バージョン情報」の「デバイスの仕様」に書いてあるものをインストールしましょう. 著者のWindowsPCだと「システムの種類」が`64 ビット オペレーティング システム, x64 ベース プロセッサ`とあるので64bitです. 



## インストーラーのセットアップ
セットアップで重要なのは, `code`コマンド設定と`PATH`への追加です. 

こちらの記事に従うとイイ感じになります. 
https://www.kikagaku.co.jp/kikagaku-blog/visual-studio-code-windows/#i-0

codeコマンドは指定パスをvscodeで開くコマンドです. 毎日使うことになります. 

PATHが何か分からない場合は下記記事が分かりやすいです（分からずとも本記事では問題なし）. 
https://wa3.i-3-i.info/word18470.html
https://qiita.com/ryouya3948/items/8edbd5d744c83dd41141



## 動作確認
ダウンロードされたVScodeを開いてみましょう. 
Windowsなら, ホーム画面下の検索窓で検索すればアプリが見つかるはずです. 

無事にVScodeを開けたら, PCを再起動します. 
再起動の目的は, 上述したcodeコマンドを有効化するためです. 

再起動後, VScodeを開いて…
1. ctrl J を押す（VScode内のターミナルを開く）
2. `code -v`と入力してEnterを押す (codeコマンドが有効になっているか確認)
3. ターミナルに下記のように表示されればOK！
```bash
1.100.3  # ← codeコマンドのバージョンが表示される
258e40f...{長い文字列}...
x64
```


## 最低限の設定
VScodeは設定が大量にあります. 毎日使うものなので, 色々設定できるのはありがたい. 
しかし, よく分からないうちは下記5つだけを設定すれば十分です！

### 自動保存
コードが自動保存されるようにします. 
デフォルト設定では, ctrl Sを押さないとコードが保存されません. 

1. ctrl shift P を押す（コマンドパレットを開く）
2. open user settings と入力してEnter（ユーザ設定をGUIで設定する）
3. 検索窓に auto save と入力し, 出てきた設定項目を"off"から"onFocusChange"に変更

### デフォルトのシェル
VScode内で開かれるターミナル（integrated terminal）のシェルをGit Bashに設定します. 

1. ctrl shift P
2. select default profile と入力してEnter
3. Git Bashを選択

### 各言語のインデント
インデント(Indent)はコードを字下げするものです. インデント設定は言語ごとにスタンダードがあるため, あなたが使う言語でのインデントを設定しておきましょう(例: Pythonはスペース4つ). ただし, チームでコーディングルールを決めている場合はそちらに従いましょう. 
各言語でのスタンダードは, `python indent coding rule`, `python indent style guide`のようにググれば出てきます. 

1. ctrl shift P
2. open user settings json と入力してEnter
3. jsonファイル(settings.json)に下記を追記 (例: pythonのインデントをスペース4つにする)
   ```json
   {
      // 既存の設定…

      // これを追記
      "[python]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
      }
   }
   ```
5. もし一部ファイルで設定が適用されない場合, VScode下部の`Spaces: 2`または`Tabs Size: 2`のように表示されている部分をクリックして設定しましょう. 
  ![VScodeの言語ごとのインデント設定](/images/vscode-settings-indent.png)

### gitのエディタをVScodeにする
デフォルト設定だと`git commit`等をした際に「謎の黒い空間」に飛ばされます. おそらく身動きが取れなくなって困るので, `git commit`等をした際に使うエディタをVScodeに変更しましょう. 

ターミナルにて, 下記を入力してEnter. 
```bash
git config --global core.editor 'code --wait'
```
:::details 「謎の黒い空間」は何？
大体の場合, nanoというエディタです（マシンによってはemacsやvimかも）. 

編集・保存するために色々とコマンドを知っておく必要があり, 知識がないとそこから脱出することさえできません. 著者も初心者の頃に怖い思いをしました. 
:::

### テーマ設定
VScode全体のテーマ(Theme)を設定することで, 見た目を簡単に変えられます. 
作業効率は見た目だけで変わるものです. コードのハイライトや目の疲れなどを考慮して, 自分に合うものを選びましょう. 気分転換にヘンなテーマを使うのも良いですね. 

1. ctrl shift P
2. preferences color theme と入力してEnter
3. お好きなテーマをEnterで選択

デフォルトでは15個ほどしかありませんが, "Browse Additional Color Themes"から大量のテーマを見ることができます. ちなみに, 著者はAyu Mirageというテーマを少しカスタムして使っています. 

| dark | light |
| --- | --- |
| ![VScodeのダークテーマ](/images/vscode-theme-dark.png) | ![VScodeのライトテーマ](/images/vscode-theme-light.png) |

| fairyfloss | Ayu Mirage (customized) |
| --- | --- |
| ![VScodeのfairyflossテーマ](/images/vscode-theme-fairyfloss.png) | ![VScodeのAyuテーマ](/images/vscode-theme-ayu-customised.png) |

#### BONUS: フォント設定
エディタとターミナルで表示するフォント(font family)を見やすいものに設定します. 
(少し面倒です. 飛ばしても問題ありません.)

著者おすすめの FiraCode Nerd Font Mono を設定します. 

1. [こちらのNerdFontsサイト](https://www.nerdfonts.com/font-downloads)から`FiraCode Nerd Font`をダウンロード
2. Windowsの場合, [こちらを参考にして](https://support.microsoft.com/ja-jp/office/%E3%83%95%E3%82%A9%E3%83%B3%E3%83%88%E3%82%92%E8%BF%BD%E5%8A%A0%E3%81%99%E3%82%8B-b7c5f17c-4426-4b53-967f-455339c564c1), ダウンロードしたフォントを使用可能にする. 
3. VScodeでctrl shift P
4. open user settings と入力してEnter
5. 検索欄にfontと入力し, EditorのFont Familyを'FiraCode Nerd Font Mono'に設定. 
6. 検索欄にterminal fontと入力し, Terminal InteragedのFont Familyを'FiraCode Nerd Font Mono'に設定. 

フォントが適用されていればOK！

Macの場合は, homebrew caskでNerdFontをインストールするのが良いでしょう. 



## 最低限のショートカットキー
ショートカットキーは最低限これを覚えれば, あとは自分で調べて使っていけます. (著者が頻繁に使うのはせいぜい30個です)
- ターミナルの開閉: **ctrl J**
- サイドバーの開閉: **ctrl B**

![VScodeの領域の名称](/images/vscode-area-name.png)

ターミナルは表示位置を下部にしたり, エディタ部分にターミナルを表示することもできます. 

サイドバーでは, 例えば以下のようなことができます. 
- ディレクトリとファイルの閲覧/作成/削除/名称変更, ファイルをエディタへ開く
- GUIでGit操作
- ファイル検索
- デバッグ
- Extensionのインストールや管理



## 最低限のExtension
最低限のExtensionを入れて, 開発効率を上げましょう. 
Extensionはサイドバーの「四角形４つ」的なボタンからインストールできます. 

### 共通
#### Error Lens
デフォルトでは, エラーは該当部分ホバー or ターミナルのProblemsでしか表示されません. 一方, Error Lensを使えばエディタ内にエラーを直接表示できます. 
![Error Lensの表示イメージ](/images/vscode-extension-errorlens.png)

#### Github Copilot / Copilot Chat
Github Copilotを使うなら入れておきましょう. Github Copilot Proを無料で利用するには, [Github Copilot について](#github-copilot-について)のセクションを参照して下さい. 

#### indent-rainbow
インデントを見やすくしてくれます. 
例えばPythonはインデントがシンタックスに組み込まれており, 初心者はインデントのミスでエラーになることも多いため, 重宝するかと思います（ちなみに著者はどの言語でもindent-rainbowを使っています）. 背景の色・透明度は自由に設定可能です. 

| indent-rainbowあり | なし |
| -- | -- |
| ![indent-rainbowありの見た目](/images/vscode-extension-indentrainbow.png) | ![indent-rainbowなしの見た目](/images/vscode-extension-non-indentrainbow.png) |

#### Rainbow CSV
csvファイルを見やすくしてくれます. 
生のcsvファイルを見る事はそう多くないですが, コードの動作確認で見ることはよくあるため, 見やすくしておきましょう. 

:::details そもそもcsvとは？
CSV: Comma-Separated Values の略. ファイルの拡張子. ExcelやGoogle SpreadSheet等のアプリケーションはCSVをもとにしたデータを操作しています. 

コンマ(,)で区切られた値を持つテキストファイル形式で, データ出力先としてよく使います. `dat`ファイルをデータ出力先として使う人もいますが, 著者はCSVファイルを推奨します. なぜなら, datファイルはデータの区切り形式がシステムや人によって異なり, 形式を合わせる手間が生じるからです（そもそも多くのdatファイルは他ソフトウェアとのデータ共有・変換を意図していない）. 一方, CSVファイルはデータの区切り形式が決まっているため扱いやすいです. 

ちなみに, CSVの最後の行にはコンマを付けないようにしましょう. (参考: [RFC4180](https://datatracker.ietf.org/doc/html/rfc4180))

:::

| Rainbow CSVあり | なし |
|----|----|
| ![Rainbow CSVありの見た目](/images/vscode-extension-csv.png) | ![Rainbow CSVなしの見た目](/images/vscode-extension-non-csv.png) |

### 言語ごと
#### Language Support
言語ごとに, 基本的なLanguage Supportは入れておきましょう. 関数ジャンプや適切なコードハイライトなどなどの機能が追加されます. 必要に応じて色々入れましょう（個人提供のものはインストール前に安全性を確認して下さい）. 

| lang | extension | provider |
| ---- | ---- | ---- |
| Python | Python | Microsoft |
| C++ | C/C++ | Microsoft |
| Golang | Go | Go Team at Google |

など…

#### フォーマッタ
フォーマッタ(Formatter)とは, コードを見やすく整形してくれるツールです. いちいち手動でインデントを揃えたり, スペースを揃えたりするのは面倒ですから, フォーマットはすべてフォーマッタに任せましょう. 
色々と設定できるのですが, 最初のうちはデフォルト設定でよいと思います. ただし, チームでコーディングルールを決めている場合はそちらに従いましょう. 

| lang | extension | provider |
| ---- | ---- | ---- |
| Python | Black Formatter | Microsoft |
| C++ | C/C++ | Microsoft |
| Golang | (なし) | (言語自体にフォーマッタgofmtが付いている) |

など…

言語ごとにフォーマッタを設定するには下記: 
1. ctrl shift P
2. open user settings json と入力しEnter (settings.jsonを開く)
3. settings.jsonに下記を追加
(例: pythonのフォーマッタをblackにし, インデントをスペース4つにする)
   ```json
   {
      // 既存の設定…

      // これを追記
      "[python]": {
         "editor.tabSize": 4,
         "editor.insertSpaces": true,
         "editor.defaultFormatter": "ms-python.black-formatter"
      }
   }
   ```






# 3. 実際に開発してみよう
## その前に開発ディレクトリを決めよう
ターミナルやエディタ以前のこととして, コードを書くディレクトリ(開発ディレクトリ)は決めておきましょう. 

例えば, HOMEディレクトリ直下に`formycode`のようなディレクトリを作って, その中にプロジェクトごとにディレクトリを作りましょう. （HOMEディレクトリとは, あなたがターミナルを開いた時に最初にいるディレクトリで, `echo $HOME`で表示されるパスのことです. 大体は`/User/{username}`です. ）

:::message alert 
開発ディレクトリのNGな場所

OneDriveやiCloudの管理下にあるディレクトリに開発ディレクトリを置くのは避けましょう. なぜなら, 下記のようなデメリットがあるからです. 
1. クラウドとの通信で処理が遅くなることがある. 
2. クラウドへ編集内容が反映されなかったり, `main.py 2`, `main.py 3`, ...のようなファイルが作られたりする. （著者は`main.py 2`で痛い目を見ました）

HOMEディレクトリならクラウド管理されていないはずなので, そこが確実です. 
:::

イメージとしては下記のようになります. 
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
...
```

過去に書いたコードがある場合, ファイルエクスプローラ(Windowsの黄色いフォルダのアイコンのやつ🗂️)などを使って, ファイル/ディレクトリを開発ディレクトリに移動させましょう. 



## VScodeで開発してみよう
プロジェクトディレクトリを作り, VScodeでPythonファイルを実行してみましょう. 

※ターミナルで`python -V`を実行してバージョンが表示されなければ, おそらくマシンにpythonが入っていません. その場合, [こちらの記事を参考にして](https://sukkiri.jp/technologies/processors/python/python%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E6%96%B9%E6%B3%95windows%E7%B7%A8.html)Pythonをダウンロードして下さい. ダウンロードするバージョンは, Stable Releasesの最新バージョンでOKです. 


1. VScodeを開き, ctrl O で開発ディレクトリを開く
2. `vscode-handson`ディレクトリを作る:
  サイドバーにあるエクスプローラのNew Folderボタンをクリック
  ![UIからディレクトリ作成](/images/vscode-handson-new-dir.png)
3. `vscode-handson`ディレクトリを開く:
  ターミナルで`code ./vscode-handson`を実行すると, 新しいウィンドウで開かれる
4. `main.py`ファイルを作る:
  サイドバーにあるエクスプローラのNew Fileボタンをクリック
5. ファイルを開いて編集:
  `main.py`をクリックしてエディタに開き, 適当なコードを書く (下記コピペでOK). 
   ```py:main.py
   def greeting(name):
       print(f"Hello, {name}!")

   def main():
       name = "masa"
       greeting(name)

       a = 20
       for i in range(5):
           num = a * i
           if num > 50:
               print(f"{num} is greater than 50")
           else:
               print(f"{num} is not greater than 50")

   if __name__ == "__main__":
       main()
   ```
6. ファイルを実行:
  ターミナルで`python main.py`を実行すると, 下記のような実行結果が出力される
   ```bash
   Hello, masa!
   0 is not greater than 50
   20 is not greater than 50
   40 is not greater than 50
   60 is greater than 50
   80 is greater than 50
   ```

<br>
最後に, コードを適切に分割するコーディングを見てみましょう. 

下記Githubリポジトリに, 簡単な例を置きました. 
コードを見てみると, main.pyにシミュレーションのシナリオがあり, main.pyからutilディレクトリ・drawディレクトリ内のコードを呼び出して使用しているのがわかると思います. 
https://github.com/masa0902dev/handson-bash-vscode

伝えたい事は下記のとおりです.
- main.pyに全てのコードを書いて1万行とかのファイルを作らないでね
- 処理を細分化して関数にし, その関数たちを使って処理フローを作ってね

なぜなら, これに従わないと, とんでもなく読みにくい・とんでもなく変更しずらいソフトウェアが出来上がってしまうからです. 先輩からもらったコードがとんでもなく読みにくかった経験はありませんか？ソフトウェアを適切に構造化する事で, そのような被害をなくしていきましょう. 

## BONUS: 良いコードについて
ほんの少しだけ, 良いコードを書くにはどうすれば良いか?について触れます. ここでは, 良いコードとは, 読みやすいコード・変更しやすいコードを指すとします. 

上述した「コードの分割」以外にも, 良いコードを書くための手段や考え方はたくさんあります. では, それらをどう知れば良いかというと, ソフトウェアエンジニアリング(SWE)領域から学べばOKです. このような問題については研究独自のものではないため, SWE領域からそっくりそのまま流用できます. 
こういった知識は, 現代なら本・記事・動画などの媒体から簡単に得られます. 本なら, 初心者エンジニアのほぼ全員が読む「リーダブルコード」や, よりモダンな「Good Code, Bad Code」など. 記事なら, エンジニアの方が書いたZennやQiita, 個人ブログなど. 動画ならYoutubeなど. 
<!-- また, ある程度の知識と経験を積めば, 対象を良いコードに落とし込む方法を自分で考えられるようになります.  -->

良いコードは, 将来の自分やチームの生産性を上げるだけでなく, たった今の生産性を上げることにも直結します. なぜなら, 良いコードは認知負荷を軽減するからです. 

最初の一歩として, 研究で実際にコードを書きつつ, [リーダブルコード](https://amzn.asia/d/7RXDTTf)から始めてみてはどうでしょうか. それだけでも, あなたの開発体験(DX)は大きく向上するはずです！




# 4. おわりに
本記事では, ターミナルやシェル, エディタについて説明しつつ, Git BashとVScodeによる開発環境を構築しました. 
研究室で「学部生が新しく配属された」「開発環境を手軽に良くしたい」などのシチュエーションでご活用頂ければと思います. 

著者の所属研究室でも, 本記事のように開発環境を再構築しました. 
次回はGit/Githubのハンズオンを予定しています. 
