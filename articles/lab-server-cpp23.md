---
title: "研究室の計算機サーバでC++23を使う: 既存環境に影響を与えない方法"
emoji: "🗳️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["研究", "サーバ", "cpp", "cpp23"]
published: false
---



# 本記事のモチベーション
著者(いち学生)の所属研究室の計算機サーバは, デフォルトではg++コンパイラが`GCC8.5`, C++が`C++17`しか使えませんでした. 私としては, 関数型プログラミング的な表現が便利なのでC++23を使いたいです.

サーバ上でC++23を使うこと自体は簡単でした. `/opt/rh/gcc-toolset-13`があったので, その中にあるC++23を使えばよいです.
しかし, gcc-toolset-13では標準ライブラリが不足しており, 例えば`std::ranges::to`などが使えませんでした.

そこで, 計算機サーバにGCC14を入れることにしました.
**グローバルに設定すると他ユーザが困る可能性があるので, サーバの個人ディレクトリのみでGCC14を使い, C++23を使えるようにします.**
他ユーザもC++23を使いたい場合は, そのユーザの個人ディレクトリで同様の作業を行えばOKです. **一人あたり約1.7GBの追加容量で利用可能です.**

:::details 目次
- [本記事のモチベーション](#本記事のモチベーション)
- [前提条件](#前提条件)
  - [著者の環境](#著者の環境)
    - [マシン関係](#マシン関係)
    - [C++関係](#c関係)
- [GCC14のインストール](#gcc14のインストール)
  - [GCCソースの取得](#gccソースの取得)
  - [ビルド設定](#ビルド設定)
  - [ビルドとインストール](#ビルドとインストール)
  - [パスを通す](#パスを通す)
- [おわりに](#おわりに)

:::

# 前提条件
読者に求めること:
- SSHでサーバに入れる
- Linux系の基本的な知識があり, 基本的な操作ができる

## 著者の環境
重要と思われる情報のみ記載します.

### マシン関係
```cpp
// cat /etc/os-release
NAME="Rocky Linux"
VERSION="8.10 (Green Obsidian)"
ID_LIKE="rhel centos fedora"

// cat /etc/redhat-release
Rocky Linux release 8.10 (Green Obsidian)

// uname -a
Linux aurora 4.18.0-553.22.1.el8_10.x86_64
#1 SMP Wed Sep 25 09:20:43 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```
Rocky Linuxは, "RHELと100%バグ互換性がある"オープンソースです. ここでは, RHELとほぼ同じと考えて差し支えありません.

### C++関係
```cpp
// which g++
/usr/bin/g++

// g++ --version
g++ (GCC) 8.5.0 20210514 (Red Hat 8.5.0-26)
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```



# GCC14のインストール
作業はすべて個人ディレクトリで行います. **基本的にroot権限は不要です.**

ここでは, 次のサイトから`GCC14.3.0`をwgetでソース取得します. あなたが実際に取得するバージョンを選びましょう.

https://ftp.gnu.org/gnu/gcc/gcc-14.3.0/

ディレクトリ構成は下記のようにしています. 将来的にGCC15などを追加するために, バージョンごとにlocal内でディレクトリを分けています.
```bash
/home/{yourname}/
├── src/  # ビルド用作業ディレクトリ
│   └── gcc
│       ├── build-gcc-14.3.0  # GCC14.3.0のビルド先
│       ├── gcc-14.3.0        # GCC14.3.0ソース(展開後)
│       ├── gcc-14.3.0.tar.xz # GCC14.3.0ソース(展開前)
│       ├── build-gcc-15.1.0  # 将来の追加バージョン
│       ├── gcc-15.1.0
│       ├── gcc-15.1.0.tar.xz
│       └── …
└── local/  # ビルド済みインストール先ディレクトリ
    └── gcc/
        ├── 14.3.0/  # GCC14.3.0のビルド済みインストール先
        ├── 15.1.0/  # 将来の追加バージョン
        └── …
```


## GCCソースの取得
1. `src`ディレクトリの作成, ソース取得
   ```bash
   mkdir -p $HOME/src/gcc && cd $HOME/src/gcc
   wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
   ```
2. ソース展開, ビルドに必要なものをインストールする
   ```bash
   tar -xf gcc-14.3.0.tar.xz
   cd gcc-14.3.0
   ./contrib/download_prerequisites
   ```

## ビルド設定
下記コマンド実行前は, `$HOME/src/gcc/gcc-14.3.0`にいるはず.

1. ビルド専用ディレクトリの作成
   ```bash
   mkdir ../build-gcc-14.3.0 && cd ../build-gcc-14.3.0
   ```
2. ビルド設定: `$HOME/local/gcc/14.3.0`に格納されるように設定している.
   ```bash
   ../gcc-14.3.0/configure --prefix=$HOME/local/gcc/14.3.0 \
      --enable-languages=c,c++ \
      --disable-multilib \
      --disable-nls \
      --enable-checking=release \
      --enable-lto \
      --enable-libstdcxx-backtrace \
      --with-system-zlib
   ```

ビルド設定オプションの説明:

| オプション | 説明 |
| --- | --- |
| enable-languages=c,c++ | C,C++のコンパイラだけをビルドする.<br>Fortranなどの多言語を無視してビルド時間とディスク容量を削減する. |
| disable-multilib | 32bitライブラリのビルドを無効化(64bitのみビルド).<br>64bit環境なら32bitライブラリは不要. |
| disable-nls | NSL(各言語対応)を無効化する.<br>エラーメッセージ等が常に英語で出力されるのでデバッグしやすい. |
| enable-checking=release | ビルド時の内部チェックを無効にする.<br>開発はローカルで行うのでパフォーマンスを優先. |
| enable-lto | LTO(リンク時最適化)を有効化.<br>パフォーマンス向上が可能. |
| enable-libstdcxx-backtrace | backtrace情報サポートを有効化.<br>例外発生時にスタックトレースを得られる. ローカルでは上手くいったがサーバで上手くいかないとき用. |
| with-system-zlib | システムにすでにあるzlib(圧縮/展開)を使用する.<br>ビルドが軽くなる. |

## ビルドとインストール
下記コマンド実行前は, `$HOME/src/gcc/build-gcc-14.3.0`にいるはず.

:::message alert
⚠️ビルドには時間がかかる(著者の場合は約50分). よって…
- 特にVPNで計算機サーバに接続している場合, 途中で接続が切れてもビルドのプロセスが停止されないように`nohup`コマンドを使う.
- ターミナルがビルドのプロセスで長時間拘束されるのは嫌なので, バックグラウンド実行`&`を使う. また, ビルドログを後から見れるように出力ログをファイル保存する.

:::details 出力ログのファイル保存について
`nohup make -j$(nproc) > build.log 2>&1 &`

ビルド時のコマンドを上記にしていますが, 出力ログのファイル保存に関係するのは`> build.log 2>&1`の部分です.

- `some-command > build.log`で, some-commandによる出力ログ(標準出力, stdout)をファイルbuild.logに出力します.
- `2>&1`は不思議な感じがしますが, 2がエラーログ(標準エラー出力, stderr), &1がstdoutを表します. `>`はリダイレクト(出力方向を向け直す)です. よって`2>&1`は, stderrをstdoutと同じ場所にリダイレクトせよ, という意味です.

stdoutが1, stderrが2です. 0はstdin(標準入力)です.
ちなみに標準~~というのは, ターミナルからの入出力と捉えればOKです.

:::

:::


1. ビルド: 時間がかかるのでjオプションで並列化
   ```bash
   nohup make -j$(nproc) > build.log 2>&1 &
   ```
2. インストール
   ```bash
   make install
   ```
3. 中身の確認: `$HOME/local/gcc/14.3.0`ディレクトリがあり, そこに`bin`,`include`等のディレクトリがあればOK.

## パスを通す
1. シェルがbashの場合, `$HOME/.bashrc`に下記を追記.
   ```bash
   export GCC_VER=14.3.0  # 切り替え可能
   export PATH=$HOME/local/gcc/$GCC_VER/bin:$PATH
   export LD_LIBRARY_PATH=$HOME/local/gcc/$GCC_VER/lib64:$LD_LIBRARY_PATH
   ```
2. .bashrcを読み込んで設定を有効化
   ```bash
   source $HOME/.bashrc
   ```


動作確認: C++23の機能を含んだ下記コードをコンパイル・実行できれば完了✅️
```cpp
#include <ranges>
#include <vector>
#include <iostream>

// 偶数を抽出して2倍し, vector<int>とするだけのコード.
// std::ranges:toはC++23の機能.
int main() {
    std::vector<int> data = {1, 2, 3, 4, 5, 6};

    auto result = data
        | std::views::filter([](int x) { return x % 2 == 0; })
        | std::views::transform([](int x) { return x * 2; })
        | std::ranges::to<std::vector<int>>();

    for (int x : result) std::cout << x << " ";  // 出力: 4 8 12
}
```



# おわりに
これにて, RHEL8計算機サーバで, 他ユーザへの影響なしでGCC14のC++23を使えます.
一人あたり約1.7GBの追加容量で利用可能なので, 複数人でも余裕です.

ちなみにHPCのC++23対応状況ですが, 例えば日本の「富岳」や2025年6月のTOP500で1位だった「El Capitan」はC++17までしかサポートしていないようです. ソースはこちら → [富岳](https://www.fujitsu.com/jp/about/businesspolicy/tech/fugaku/specifications/)(しかもC++17サブセット), [El Capitan](https://cpe.ext.hpe.com/docs/24.07/guides/CCE/HPE_Cray_Compiling_Environment_Release_Overview_18.0.0_S-5212.html?utm_source=chatgpt.com)(使用するCray Compilerがgcc-toolset-13をサポート).
しかし, 2027年には富岳に変わる[「Monaka」](https://www.fujitsu.com/jp/about/research/technology/fujitsu-monaka/)もリリース予定とのことですし, 私(学部4年)がスパコンを頻繁に使用する頃には対応しているだろう, と楽観視してC++23を使うことにします.

**本記事で誤りや疑問等ありましたら, コメント頂けると幸いです!**
