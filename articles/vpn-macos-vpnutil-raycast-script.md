---
title: "vpnutil × Raycast × iPhone Shortcutsで, VPN接続の手間を減らす"
emoji: "📶"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vpn", "macos", "raycast", "vpnutil", "iphone"]
published: false
---

# モチベーション

**VPN接続のためのGUI操作 (マウスを動かす + クリック) がめんどくさい!!!**

![効率化前のVPN接続の方法](/images/vpn-macos-vpnutil-raycast-script/ordinary-way-of-connecting-vpn-composed-fast3.gif)

著者は, 自宅から研究室の計算機サーバに接続するためにVPN接続を毎日行います. 計算機は頻繁に使うため, 接続のたびに発生するGUI操作が地味に面倒でした. (GUI操作中に, やろうとしてたことを忘れたり, 集中が途切れたり…)

今回は, この面倒なVPN接続を効率化します. 具体的には以下を実現します.

- `vpnutil` によって, macOS上でのVPN接続操作をCLI化する
- Raycast の Script Command によって, キーボードだけでVPN接続を実行できるようにする
- iPhoneのShortcutsアプリによって, 2段階認証アプリへ即アクセスできるようにする

## Before/After

|          | 手順                                                                                                                                                                                                    |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 今まで   | 1. Raycastで"VPN"と打ち込み, System SettingsのVPN画面を開く<br>2. 対象VPNの接続ボタンをクリック<br>3. iPhoneを開く<br>4. iPhoneの2段階認証アプリを開く<br>5. 2段階認証アプリのポップアップでYesをタップ |
| 効率化後 | 1. Raycastで `cmd+5`<br>2. iPhoneのロック画面で認証用ショートカットをタップ<br>3. 2段階認証アプリのポップアップでYesをタップ                                                                            |

GUI操作だった1, 2がキーボードショートカット1つにまとまり, iPhoneを開いてアプリを探す手間もなくなりました.

![効率化後のVPN接続の方法](/images/vpn-macos-vpnutil-raycast-script/raycast_execute_favorite_command_vpnnit-composed-fast3.gif)


# 前提

**macOS側**:
- VPN接続の設定自体(System SettingsでのVPNプロファイル作成)は完了していること
- Raycast をインストール済みであること
 
まだの方は下記を参考に.

https://qiita.com/mtaku29/items/31ec3b0ac48ab35d8a80#raycast%E3%81%AF%E4%BD%95%E3%81%8C%E4%BB%96%E3%82%88%E3%82%8A%E3%82%82%E3%81%84%E3%81%84

**iPhone側**:
- iPhone側で"2段階認証アプリ"を設定済みであること (Microsoft Authenticatorなど)

ちなみに, 今回利用するRaycastは, Finderをめちゃくちゃ便利かつ多機能にしたもの, というイメージです (いずれ記事で著者のユースケースを紹介したいですね)



## 動作確認環境

- macOS Tahoe 26.5.1
- [vpnutil](https://github.com/Timac/VPNStatus) 3.1
- Raycast 1.104.20




# 全体像

今回のセットアップは, macOS側・iPhone側の2つに分かれます.

- macOS側
  1. VPNの名称をシンプルなものに変更 (日本語は避ける)
  2. homebrewで`vpnutil`をインストールし, VPNの起動/停止ができることを確認
  3. Raycast Script Commandとして, VPNの起動/停止コマンドを作成
  4. 作成したコマンドをRaycastのFavoriteに登録し, ショートカットキーを割り当てる
- iPhone側
  1. Shortcutsアプリで「2段階認証アプリを開くだけ」のショートカットを作成
  2. そのショートカットをロック画面に配置



# セットアップ手順

## macOS側
### 1. VPNの名称を変更

System Settingsの"VPN"から, 対象VPNの名前をシンプルなものに変更しておきます.
以降, このVPN名を `MyVPN` として説明します.

### 2. vpnutilをインストール

[vpnutil](https://github.com/Timac/VPNStatus) は, ターミナルからVPNの起動/停止/状態確認ができるCLIツールです. Homebrewでインストールできます.

```sh
brew tap timac/vpnstatus
brew install timac/vpnstatus/vpnutil
```

インストールできたら, 動作確認をします.

```sh
# 登録されているVPNの一覧と状態を確認
vpnutil list

# 出力:
{
  "VPNs" : [
    {
      "name" : "MyVPN",
      "status" : "Disconnected"
    }
  ]
}
```

```sh
# VPNに接続
vpnutil start MyVPN
# 出力:
2026-07-02 00:14:16.410 vpnutil[70006:597858] vpn_nit has been started

# VPNを切断
vpnutil stop MyVPN
# 出力: (ステータスがconnectiongの場合はstopできないが,時間が立てば勝手に切断される)
2026-07-02 00:16:51.448 vpnutil[71958:604337] vpn_nit was not stopped because it was in the state 'Connecting'
```

### 3. Raycast Script Commandを作る

Raycastでは, 任意ファイルの実行をコマンドとして登録できます. これを使って, `vpnutil` の起動/停止をRaycastのコマンドにします.

1. まず, スクリプトファイルを配置するディレクトリを作成.
   ```bash
   mkdir -p ~/.raycast/commands
   ```

2. Raycastを開いて"Create Script Command"と検索して実行.
3. 言語は `bash`, テンプレートは `compact` を選択し, titleに好きなコマンド名(例: `vpnstart`)を入力. (titleがそのままコマンド名になる). 残りの項目は空欄のままでOK.
4. `cmd+Enter` を押すとスクリプトの保存先を聞かれるので, 先ほど作成した `~/.raycast/commands/` を指定する.

![raycast-script-command作成時のUI](/images/vpn-macos-vpnutil-raycast-script/raycast_create_script_command.png)

生成されたスクリプトの中身はこれだけです.

```bash:vpnstart.sh (~/.raycast/commands/vpnstart.sh)
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title vpnstart
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🛜

# Documentation:
# @raycast.description connet VPN of MyVPN with vpnutil start
# @raycast.author YourName
# @raycast.authorURL https://raycast.com/YourName

vpnutil start MyVPN
```

```bash:vpnstop.sh (~/.raycast/commands/vpnstop.sh)
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title vpnstop
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🛜

# Documentation:
# @raycast.description disconnect VPN of MyVPN with vpnutil stop
# @raycast.author YourName
# @raycast.authorURL https://raycast.com/YourName

vpnutil stop MyVPN
```

Raycastで作成したコマンド名(`vpnstart`, `vpnstop`)を検索して実行し, VPNの起動/停止ができれば成功です.

### 4. RaycastのコマンドをFavorite登録

作成したコマンドをRaycastで検索し, Action Panel(`cmd+K`)から"Add to Favorites"を選択します. お気に入りに登録したコマンドは, Raycastの起動画面の上部に並び, 上から順に `cmd+1`, `cmd+2` ... のショートカットキーで即座に呼び出せるようになります.
Favoriteの順番は, Action Panelの"Move Up/Down in Favorites"で変更できます.

これで, キーボードだけでVPNの起動/停止ができるようになりました.
(Raycastを開く:cmd+space → コマンド実行:cmd+1)

![効率化後のVPN接続の方法](/images/vpn-macos-vpnutil-raycast-script/raycast_execute_favorite_command_vpnnit-composed-fast3.gif)

## iPhone側
### 5. 2段階認証アプリを開くショートカットを作る

![iPhoneのShortcutsアプリ](/images/vpn-macos-vpnutil-raycast-script/iphone-spp-shortcuts.jpeg =100x)

Shortcutsアプリで, 2段階認証アプリを開くだけのショートカットを作成します.

1. Shortcutsアプリで新規ショートカットを作成し, アクションとして"Open App"を選び, 対象を2段階認証アプリに設定する
2. 作成したショートカットを, Shortcutsアプリ内で最前(一番上)に配置する

### 6. ロック画面にShortcutsアプリを配置する

2段階認証アプリ自体はロック画面に直接配置できないため, Shortcutsアプリ経由で代用します.

1. Settingsアプリの"Wallpaper"からロック画面を編集する
2. ロック画面のウィジェットとしてShortcutsアプリを配置する(手順5で最前に置いたショートカットが呼び出されます)

これで, ロック画面からワンタップで2段階認証アプリを開けるようになりました.

![iPhoneのAuthenticatorをロック画面から開く](/images/vpn-macos-vpnutil-raycast-script/iphone-authenticator.gif =300x)



# 結果

実際に手順ごとの所要時間を計測したところ, 12.25秒かかっていた作業が6.40秒になりました.

…たったの6秒短縮かい! もし, 従業員100人が1日3回VPN接続を行うとすると短縮時間は30m/1D, 15h/1M. うーん大きな会社でも微妙ですね.

しかし, GUI操作がなくなったことで集中の途切れは減りました. めでたしめでたし.



# 参考記事など

https://zenn.dev/mozumasu/articles/mozumasu-vpnstatus

https://github.com/Timac/VPNStatus

https://manual.raycast.com/script-commands

https://zenn.dev/hamuziro/articles/ebc594a4e99247#%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%97%E3%83%88
