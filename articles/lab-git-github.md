---
title: "研究室のためのGit, Githubの始め方【Windows】"
emoji: "🧪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["研究", "git", "github", "入門"]
published: false # trueにすると投稿・更新される
---
# はじめに
## 本機序の対象読者
## 本記事で得られるもの / 得られないもの
## 本記事のモチベーション
礒部研のHP載せる

# Git, Githubを研究室に導入するメリット
WIP🚧
特に非情報系では、コードを書くけどGitを導入していない研究室も多いようです。
このセクションでは、下記のメリット２点をアピールします。
- 開発体験の向上
- プロジェクト管理

# Gitの始め方
下記の環境で動作確認を行いました。
- Git 2.49.0
- OS: Microsoft Windows 11 Pro (10.0.22621)
- CPU: x86_64, 13th Gen Intel(R) Core(TM) i5-1335U

## ダウンローダーのダウンロード

1. [Git公式サイト](https://gitforwindows.org/)で「Download」をクリックし、Gitダウンローダーをダウンロード

2. ダウンローダーをクリックして実行

## ダウンローダーでの設定
設定の意味がよくわからない場合は、以下の設定に従えば安心です。
基本的に後からの設定変更も可能です。

3. `Select Components`:
デフォルト状態から`Additional icons`を追加する。
デスクトップにGitのアイコンを追加する。

4. `Choosing the default editor used by Git`:
`Use Visual Studio Code as Git's default editor`を選択。
エディタとしてVScodeをデフォルトで使用する。自分の使うエディタを選択すればOK。

5. `Adfusting the name of the initial branch...`:
`Let Git decide`を選択。
mainブランチをデフォルトブランチに設定する。

6. `Adjusting your PATH enviroment`: 
`Git from the command line...`を選択。
サードパーティソフトウェアがGitを使えるようにする。

7. `Choosing the SSH executable`: 
`Use bundled OpenSSH`を選択。
外部のSSHクライアントではなく、GitにバンドルされているSSHクライアントを使用。

8. `Chhosing HTTPS transport backend`: (注意)
`Use the OpenSSL Library`を選択。
HTTPS接続に、Windows標準のライブラリではなくOpenSSHライブラリを使用。

9. `Configuring the line ending conversions`:
`Checkout Windows-style, commit Unix-style line endings`を選択。
Windowsは改行コードがCRLFになっており、これをコミット時にUnix標準のLFに合わせてくれる。また、LFファイルをローカルに持ってくるときにはCRLFに変換して表示してくれる。

10. `Configuring the terminal emulator to use with Git Bash`:
`Use MinTTY ...`を選択。
もう片方のWindow's defaultでは、ASCII以外の文字を表示するのに設定が必要..などの不便さがあるので、こちらを選択。

11. `Choose the default behavior of git pull`:
`Fast-forward or merge`を選択。
pull実行時(リモートの状態をローカルに取得する時)に、ローカルの状態の上にリモートの状態を載せる。(個人的には、Rebaseはローカルブランチ間のみでの実行を推奨します。)

12. `Choose a credential helper`:
`Git Credential Manager`を選択。

13. `Configuring extra options`:
2つともチェックを入れる。
`Enable file system caching`によって、キャッシュが有効化されてパフォーマンス向上。
`Enable symbolic links`によって、シンボリックリンクであるファイルをリンクとして解釈できるようになる。これを有効化しない場合、シンボリックリンクはリンク先のファイルの中身を含んだ普通のファイルとして解釈される。

14. Nextでインストール開始！
インストール後、デスクトップにGit Bashが追加されていればOK。
また、`Git Bash`を開いて`git -v`を実行した際に`git version 2.49.0.windows.1`のように表示されていればOK。

Windowsの標準ターミナルは`Power Shell`か`コマンドプロンプト`ですが、Unix系に慣れている場合 (Linux, bash/zsh/fish などに聞き覚えがある人) はターミナルとして普段から`Git Bash`を使うのも良いと思います。

## Gitの初期設定
必要最低限の設定を登録するため、ターミナルを開きましょう。
以降はGit Bashで実施します。

設定の優先度は local < global < system となっており、localはそのディレクトリ内でのみ有効な設定です。全体に適用したい場合は、基本的にglobalに登録すればOKです。

localの場合、そのディレクトリ内の`.gitignore`ファイルに設定が書かれます。
globalの場合、`~/.gitignore`ファイルに設定が書かれます。(パスの`~`は環境変数 $HOME のパスを表し、ターミナル起動時のパスになります。環境変数の値は`echo $HOME`で表示できます。)

1. ユーザ名、メールアドレス
```bash
git config --global user.name "your-name"
git config --global user.email "your-email@example.com"
```

2. 日本語ファイル名がエスケープされないようにする
```bash
git config --global core.quotepath false
```

3. ターミナル表示のGitの色付け
```bash
git config --global color.ui auto
```
基本はautoで十分。
個別に色を設定したい場合は、`color.status`, `color.add`のように指定する。

4. ファイル名の大文字/小文字の変更を検知する
```bash
git config --global core.ignorecase false
```
ローカルではボリュームフォーマット(大文字/小文字を区別しないフォーマット)になっていることもあるらしい。恐ろしいので必ず設定しよう。

5. push時のデフォルトブランチを現在のブランチに設定
```bash
git config --global push.dafault current
```

6. マージコンフリクト時の表示を見やすくする
```bash
git config --global merge.conflictStyle zdiff3
```
デフォルトでは`merge`という設定になっている。これは個人の好みかも。

## ここまでの設定一覧
ここまでの「ダウンローダーでの設定」「初期設定」によってGit設定は以下のようになっている。
```bash
$ git config -l
diff.astextplain.textconv=astextplain
filter.lfs.clean=git-lfs clean -- %f
filter.lfs.smudge=git-lfs smudge -- %f
filter.lfs.process=git-lfs filter-process
filter.lfs.required=true
http.sslbackend=openssl
http.sslcainfo=C:/Program Files/Git/mingw64/etc/ssl/certs/ca-bundle.crt
core.autocrlf=true
core.fscache=true
core.symlinks=true
pull.rebase=false
credential.helper=manager
credential.https://dev.azure.com.usehttppath=true
init.defaultbranch=master
core.editor="C:\Users\CSP2024-note1\AppData\Local\Programs\Microsoft VS Code\bin\code" --wait
core.quotepath=false
core.ignorecase=false
user.name=masa0902dev
user.email=masa0902dev@gmail.com
color.ui=auto
push.default=current
merge.conflictstyle=zdiff3
```
ちなみにcore.autocrlfは、Windowsはtrueが良いが、MacやLinuxはinputが良い(trueにしない)。

## VScodeでのデフォルトターミナルをGit Bashにする
1. VScode開く
2. `shift cmd P`でコマンドパレットを開く
3. `default: select default terminal`と入力して選択
4. Git Bash を選択



## 参考
- [8.1 Git のカスタマイズ - Git の設定](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%81%AE%E8%A8%AD%E5%AE%9A)
- [WindowsでGitとSSHキーを使ってGitHubを安全に使う方法](https://zenn.dev/aoikoala/articles/388eb861249780)
- [Git 初期設定](https://qiita.com/ucan-lab/items/aadbedcacbc2ac86a2b3)
- [Gitのインストール方法(Windows版)](https://qiita.com/takeru-hirai/items/4fbe6593d42f9a844b1c)




# Githubの始め方


# おわりに
次は「研究室のためのGit入門」でお会いしましょう。
