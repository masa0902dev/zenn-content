---
title: "研究室のためのGit, Githubの始め方【Windows】"
emoji: "🧪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["研究", "git", "github", "入門"]
published: false # trueにすると投稿・更新される
---
# はじめに
## 本機序の対象読者
WIP🚧
## 本記事で得られるもの / 得られないもの
WIP🚧
## 本記事のモチベーション
WIP🚧

## ちょっとした用語
- ローカル: 自分のPC内。作業をするところ。
- リモート: ローカルの反対。ローカルの内容をアップロードするところ、最新状態をローカルに持ってくるところ。

# Git, Githubを研究室に導入するメリット
WIP🚧
特に非情報系では、コードは書くがGitを導入していない研究室も多いようです。
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
後からの設定変更も可能です。

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

Windowsの標準ターミナルは`PowerShell`か`コマンドプロンプト`ですが、Unix系に慣れている場合 (Linux, bash/zsh/fish などに聞き覚えがある人) はターミナルとして普段から`Git Bash`を使うのも良いと思います。

## Gitの初期設定
必要最低限の設定を登録するため、ターミナルを開きましょう。
以降は`Git Bash`を操作します。

git設定の優先度は local < global < system となっており、localはそのディレクトリ内でのみ有効な設定です。全体に適用したい場合は、基本的にglobalに登録すればOKです。

localの場合、そのディレクトリ内の`.gitignore`ファイルに設定が書かれます。
globalの場合、`~/.gitignore`ファイルに設定が書かれます。(パスの`~`は環境変数`$HOME`のパスを表し、ターミナル起動時のパスになります。環境変数の値は`echo $HOME`で表示できます。)

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
個別に色を設定したい場合は、`color.diff.meta "blue black"bold`のように指定する。

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
ちなみにcore.autocrlfは、Windowsはtrue推奨だが、MacやLinuxはinput推奨(trueにしない)。

## VScodeでのデフォルトターミナルをGit Bashにする
1. VScodeを開く
2. `shift cmd P`でコマンドパレットを開く
3. `default: select default terminal`と入力して選択
4. Git Bash を選択



## 参考
- [8.1 Git のカスタマイズ - Git の設定](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%81%AE%E8%A8%AD%E5%AE%9A)
- [WindowsでGitとSSHキーを使ってGitHubを安全に使う方法](https://zenn.dev/aoikoala/articles/388eb861249780)
- [Git 初期設定](https://qiita.com/ucan-lab/items/aadbedcacbc2ac86a2b3)
- [Gitのインストール方法(Windows版)](https://qiita.com/takeru-hirai/items/4fbe6593d42f9a844b1c)




# Githubの始め方
## アカウントの作成
1. こちらから: https://github.com

- Username, Emailは先ほどGitで設定したものと同じにするのが良いでしょう。
- パスワードはセキュアなものを使いましょう。
    - 推測しやすい値(氏名、誕生日など)を入れない
    - 16文字以上にする
    - 大文字と小文字、数字、記号を組み合わせる。


:::message alert
Githubは規約により、所属組織用のアカウントは1人に1つまでです。

(ただし、OSSコントリビュート用の個人アカウント・所属組織用のアカウント、のような複数アカウントの使い方は許容されているようです。)
[複数のアカウントの管理](https://docs.github.com/ja/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-your-personal-account/managing-multiple-accounts)
:::

2. 登録したら、Emailに認証メールが来るはずです。確認しましょう。
認証が済んだら、アカウント作成完了です！

## SSH設定
Githubとのセキュアな通信のためにSSHを使用します。

1. SSHキーを保存するディレクトリを作成

2. SSHキーを作成して保存

3. SSHキー（公開鍵）をGithubに登録
Key Type: `Authentication Key`を選択

4. SSH接続をテスト
```
ssh -T git@github.com
```
```
# 接続が成功した際のメッセージ
Hi {your-name}! You've successfully authenticated, but GitHub does not provide shell access.
```


## 参考
- [新しい SSH キーを生成して ssh-agent に追加する](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [GitHub アカウントへの新しい SSH キーの追加](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- [Git GitHub の始め方（超入門）](https://qiita.com/mt-blue-sou/items/e28ae0b27a7911c302d5#github%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9)
- [WindowsでGitとSSHキーを使ってGitHubを安全に使う方法](https://zenn.dev/aoikoala/articles/388eb861249780)


# おわりに
次は「研究室のためのGit入門」でお会いしましょう。
