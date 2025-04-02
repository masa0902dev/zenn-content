---
title: "研究室のためのGit, Githubの始め方【Windows】"
emoji: "🧪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["研究", "git", "github", "入門"]
published: true # trueにすると投稿・更新される
---
# 1. はじめに
## 本記事の対象読者
- **研究のコードをメンバーや外部の方と共有したい人**
- **共同研究プロジェクトを開始, 効率化したい人**
- **研究のドキュメントを整理したい人**
- **研究室にGit, Githubを導入したい大学教員, 学生**
- Git, Githubをほぼ知らない人（そもそもターミナルとかよく分からない人も）
## 本記事で得られるもの / 得られないもの
✅ 得られるもの
- `Windows OS`でのGit, Githubの導入方法
- Gitの初期設定
- SSH接続によってセキュアにGithubと通信する方法
- VScodeでGitを使う方法

❌ 得られないもの
- 実際に作業上でどうGit, Githubを使うか (次の記事で扱います)
- Github Organizationの導入方法と使い方 (次の記事で扱います)

## 本記事のモチベーション
自分が所属している研究室は元々、OneDriveでメンバー間のコード共有、一部メンバーのGithubで外部の方との共同研究を行っていました。

この状況で、以下のニーズがありました。
- 研究に関するドキュメントを整理したい。
- メンバー間・外部の方とのコード共有をより円滑にしたい。
- 変更履歴などをトラックして、コードを安全に管理したい。
- 共同研究のプロジェクトを効率的に管理したい。
- OneDriveの使用料が高い...

これらニーズを解決するため、研究室への Git, Github および Github Organization の導入を提案しました。研究室教員の方は新しい方法や技術に対して寛容で、ご協力いただけたため、導入が実現しました。

⬇️ 本研究室のGithub Organization (まだまだ整備中！)

https://github.com/isobe-lab

<!-- TODO: isobe-labのHPを載せたい。isobeTに聞いてみる -->


## 知っておいてほしい用語
- ローカル: 自分のPC内。作業をするところ。
- リモート: ローカルの反対。ローカルの内容をアップロードするところ、ローカルへ反映する最新状態があるところ。

# 2. Git, Githubを研究室に導入するメリット
非情報系では、コードは書くがGitやGithubを導入していない研究室も多いようです。

しかし、GitやGithubの導入によって、様々なペインの解消・プロセスの効率化が期待できます。
また、Githubは既に多くの研究で活用され、実績を挙げています。
(非情報系でも！)

このセクションでは、下記3点についてアピールします。
Git, Github導入のメリットをメンバーに伝えるためにご使用されると良いかと思います。

- 研究領域におけるGit, Githubの活用実績
- 開発体験(DX)の向上
- プロジェクト管理の効率化

## 研究領域におけるGit, Githubの活用実績
**下記は研究領域でのGit, Githubの活用事例となります。**

1. HOOMD-blue等で有名なGlotzer氏らの事例 (本研究室が共同研究していました)

https://github.com/glotzerlab

2. ECMC等で有名なKrauth氏らの事例

https://github.com/jellyfysh

3. Githubで研究室サイトをホスティングしている玉田氏らの事例

https://tamadalab.github.io/

<br />

**また、下記は研究領域でのGithubの有効性が読み取れる事例です。**

1. 「研究においてGithubなどのソフトウェア開発ワークフローを導入することで、再現性の向上、共同作業の効率化が見込める」ことを提唱している事例

https://arxiv.org/abs/2408.09344

2. エボラ出血熱の流行時に疫学データをGithubで共有し、データ解析に貢献した事例

https://www.nature.com/articles/538127a

3. 複数の大学病院が連携し、GitHub上で医療データ統合のための共通データモデル(CDM)を共同開発した事例

https://www.nature.com/articles/s41597-025-04558-z

<br />

**また、下記は講義プラットフォームとしてのGithubの活用事例です。**

1. [東京大学] Pythonプログラミング入門

https://github.com/UTokyo-IPP/utokyo-ipp.github.io

2. [Harvard University] Data Science for Social Sciences

https://gov50-f23.github.io/

3. [慶應大学など] 機械学習システム(旧:データシステムの知能化とデザイン)など

https://github.com/keioNishi/lec-mlsys



## 開発体験(DX)の向上
Git, Githubを使えば、研究で書いたコードの変更履歴を細かく管理できるようになります。つまり、「どのファイルが、いつ、なぜ、どう変更されたのか？」を明確に残せるようになります。

特に以下のようなメリットがあります:

**1. 実験結果の再現性が高まる**
ある時点のコードとドキュメントを再現できるため、「あの時の条件での実験結果を再現したい」といったニーズに対応しやすくなる。

**2. トライアンドエラーがやりやすくなる**
思い切ってコードをいじっても、いつでも過去の状態に戻せるので安心して実験できる。

**3. エディタとの連携による効率化**
VScodeなどのエディタはGitとの統合機能を持っており、変更点の可視化・コミット・プッシュなどのUI操作によって、初心者でも直感的かつ簡単に扱える。

**4. 「差分を見る」ことの習慣化**
チームのメンバーが何をどう変更したのかをコミット単位で確認できるため、「なぜバグが起きたのか」「どの変更が影響しているのか」のトラブルシューティングも楽になる。

研究領域でのコード開発の文脈において、コードを「成長していく研究成果」として扱う文化をGitは後押ししてくれるはずです。



## プロジェクト管理の効率化
Githubを使えば、チームでの開発や研究プロジェクトを効率的に管理できます。また、Githubは All in One であることも魅力です。

特に以下のようなメリットがあります:

**1. 変更の可視化と責任の明確化**
誰がいつどんな変更を行ったのかが全てログに残るため、トラブル時の原因調査が容易。また、メンバー間の責任範囲が明確になる。

**2. タスク管理や課題管理ができる (Issues, Projectsなど)**
Githubの機能を使うことで、研究のTODOやバグ管理、ディスカッションが1か所にまとまる。メンバー間のやりとりも履歴として残るため、後から参照できる資産になる。

**3. Pull Requestによるコードレビュー文化**
コードの品質を保つために、誰かが作業したブランチをPull Requestで提出 → レビュー後にマージ、という流れが自然に構築できる。レビュー文化の導入により、特に『知識の共有』を促進できる。

**4. Github Organizationを使えば研究室単位で管理可能**
プロジェクトを個人アカウントではなく「研究室単位」で管理することで、メンバーの入れ替えや外部研究者の参加にも柔軟に対応できる。

これらの仕組みは、単に「コードを置く場所」ではなく、研究プロジェクト全体の情報共有・運営基盤としてGithubを活用できることを意味します。特に、複数人で動く研究において、Githubはコード以上の価値をもたらすはずです。


# 3. Gitの始め方
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

5. `Adjusting the name of the initial branch...`:
`Let Git decide`を選択。
mainブランチをデフォルトブランチに設定する。

6. `Adjusting your PATH enviroment`: 
`Git from the command line...`を選択。
サードパーティソフトウェアがGitを使えるようにする。

7. `Choosing the SSH executable`: 
`Use bundled OpenSSH`を選択。
外部のSSHクライアントではなく、GitにバンドルされているSSHクライアントを使用。

8. `Choosing HTTPS transport backend`: (注意)
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

14. Nextをクリックでインストール開始！
インストール後、デスクトップにGit Bashが追加されていればOK。
また、`Git Bash`を開いて`git -v`を実行した際に`git version 2.49.0.windows.1`のように表示されていればOK。

Windowsの標準ターミナルは`PowerShell`か`コマンドプロンプト`ですが、Unix系に慣れている場合 (Linux, bash/zsh/fish などに見覚えがある人) はターミナルとして普段から`Git Bash`を使うのも良いと思います。

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
(公式ドキュメントを参照: [8.1 Git のカスタマイズ - Git の設定](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%81%AE%E8%A8%AD%E5%AE%9A))

4. ファイル名の大文字/小文字の変更を検知する
```bash
git config --global core.ignorecase false
```
ローカルではボリュームフォーマット(大文字/小文字を区別しないフォーマット)になっていることもあるらしい。非常に恐ろしいので必ず設定しよう。

5. push時のデフォルトブランチを現在のブランチに設定
```bash
git config --global push.default current
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

実際にVScodeのターミナルを開き、`git -v`でGitのバージョンが表示されることを確認してみましょう。


## 参考
- [8.1 Git のカスタマイズ - Git の設定](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%81%AE%E8%A8%AD%E5%AE%9A)
- [WindowsでGitとSSHキーを使ってGitHubを安全に使う方法](https://zenn.dev/aoikoala/articles/388eb861249780)
- [Git 初期設定](https://qiita.com/ucan-lab/items/aadbedcacbc2ac86a2b3)
- [Gitのインストール方法(Windows版)](https://qiita.com/takeru-hirai/items/4fbe6593d42f9a844b1c)




# 4. Githubの始め方
## アカウントの作成
1. こちらから`Sign In`でアカウント作成: https://github.com

    - Username, Emailは先ほどGitで設定したものと同じにするのが良いでしょう。
    - パスワードは必ずセキュアなものを使いましょう。
        - 推測しやすい値(氏名、誕生日など)を入れない。
        - 16文字以上にする。
        - 大文字と小文字、数字、記号を組み合わせる。

2. 登録したらEmailに認証メールが来るので、確認しましょう。
認証が済んだらアカウント作成完了です！

:::message alert
Githubは規約により、所属組織用のアカウントは1人に1つまでです。

(ただし、OSSコントリビュート用の個人アカウント・所属組織用のアカウント、のような複数アカウントの使い方は許容されているようです。)
[複数のアカウントの管理](https://docs.github.com/ja/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-your-personal-account/managing-multiple-accounts)
:::

## SSH設定
Githubとのセキュアな通信のためにSSHを使用します。
`Git Bash`を使用します。

3. SSHキーを保存するディレクトリを作成
```
mkdir ~/.ssh
```

4. SSHキーを作成して保存
```
ssh-keygen -t ed25519 -C "GitHubに登録したメールアドレス"

Enter file in which to save the key (/c/Users/your-name/.ssh/id_ed25519):
-> EnterでOK
Enter passphrase (empty for no passphrase):
-> EnterでOK
```
`id_ed25519.pub`が公開鍵（Githubなどに登録するキー）、`id_ed25519`が秘密鍵（自分のローカルのみに置いておくキー）。

:::details 暗号鍵生成アルゴリズムについて: ed25519とrsa
ed25519は、現在(2025年4月)Github公式ドキュメントで推奨されている暗号鍵生成方法です。

昔はrsaがドキュメントにも書かれていた(と記憶している)のですが、現在では、rsaのコマンド単体で鍵生成は行わないようにしましょう。rsaを使う時は`-t rsa -b 4096`のように指定して、4096bitの鍵長で生成しましょう。

デフォルトではrsaは2048bitで生成されます。これは、計算機性能の向上とクラッカーの努力(?)により、暗号突破が現実的な範囲となることが危惧されています。特に理由がない限り、暗号鍵生成には`ed25519`を使用しましょう。

https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

https://learn.microsoft.com/en-us/windows/whats-new/deprecated-features

https://www.cryptrec.go.jp/list.html

:::

5. 公開鍵をコピー
下記コマンドで表示される文字列を全てコピー。
```
cat ~/.ssh/id_ed25519.pub
```

6. SSHキー（公開鍵）をGithubに登録
  a. Githubにて、画面右上のプロフィール画像をクリック
  b. `Settings`をクリック
  c. 左サイドバーの`SSH and GPG keys`をクリック
  d. ページの`New SSH key`をクリック
  e. Titleは`masa-lab windows laptop1`などマシンを識別しやすい名前を入力すると良い
  f. KeyTypeは`Authentication Key`を選択
  g. Keyに公開鍵をペースト
  h. `Add SSH key`をクリック
  i. `Authentication keys`にキーが追加されていればOK。

7. SSH接続をテスト(Git Bash)
```
ssh -T git@github.com

# 以下のようなメッセージが出ればSSH接続成功！
Hi {your-name}! You've successfully authenticated, but GitHub does not provide shell access.
```

## 2要素認証を設定する
2要素認証によってセキュアにログインすることができます。
2要素認証を必須にしている組織(Organization)も多いです。

8. スマホなどに認証用アプリをダウンロード。
`Microsoft Authenticator`などが推奨。

9. Githubの画面右上のプロフィール画像をクリック。
10. `Settings`をクリック。
11. 左サイドバーの`Password and authentication`をクリック。
12. ページ真ん中あたりのセクション`Two-factor authentication`にて...
Preferred 2FA method: `Authentiator app`を選択。
Two-factor methods: `Authenticator app`の`Edit`をクリックして説明に従う。(アプリでQRコードを撮影...)
13. `Recovery Code`をダウンロードして、ローカルに保存しておく。
リカバリーコードはアカウントに入れなくなった際に使用する。

設定が完了したら、セクション`Two-factor authentication`の右側に緑色`Enabled`が表示されているはず！

## 参考
- [2 要素認証を設定する](https://docs.github.com/ja/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication)
- [新しい SSH キーを生成して ssh-agent に追加する](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [GitHub アカウントへの新しい SSH キーの追加](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- [Git GitHub の始め方（超入門）](https://qiita.com/mt-blue-sou/items/e28ae0b27a7911c302d5#github%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9)
- [WindowsでGitとSSHキーを使ってGitHubを安全に使う方法](https://zenn.dev/aoikoala/articles/388eb861249780)


# 5. おわりに
## Next Step!
これで設定が完了し、Git, GithubをWindows OSで使えるようになりました！

設定が完了したら、ハンズオン記事の「研究室のためのGit入門ハンズオン」「研究室のためのGithub入門ハンズオン」で実践し、コード開発やプロジェクト運営の品質向上・効率化を実現していきましょう！

- 執筆中🚧「研究室のためのGit入門ハンズオン」
- 執筆中🚧「研究室のためのGithub入門ハンズオン」

Github Organization (組織) の導入はこちら↓

- 執筆中🚧「研究室のためのGithub Organizationの始め方」

## BONUS!
:::details もしGit, Githubの導入にメンバーや教員が難色を示している場合...
[セクション「研究領域におけるGit, Githubの活用実績」](http://localhost:8000/articles/lab-git-github#%E7%A0%94%E7%A9%B6%E9%A0%98%E5%9F%9F%E3%81%AB%E3%81%8A%E3%81%91%E3%82%8Bgit%2C-github%E3%81%AE%E6%B4%BB%E7%94%A8%E5%AE%9F%E7%B8%BE)を見せたり他の導入実績を提示したりして、「研究領域でもこんなに活用されている！」「これが業界標準になっている！」などと説得するのが良いかと思います。実際に使っているところを見せることで、その便利さを実感してもらうのも良いかもしれません。

また、Git, Github, Github Organizationなどの導入について疑問や不安がある場合、自分にご連絡いただくことも可能です。特に非情報系の研究室で、コード開発やプロジェクト運営の品質向上・効率化が (ソフトウェア業界で使用されているツールの有効活用などによって) 実現されることを自分は望んでいます。

Email: `masa0902dev@gmail.com`

もちろんZennのコメントでも！
:::
