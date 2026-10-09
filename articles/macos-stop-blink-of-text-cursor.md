---
title: "【macOS・VSCode】テキストカーソルの点滅を止めて思考に集中しよう"
emoji: "✍️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["macos", "vscode", "生産性", "editor", "writing"]
published: false
---

考えながらタイプする場面は毎日のようにあります. コードを書くとき・ドキュメントを書くとき・申請書を書くとき…など. そんなとき, 視界の中でテキストカーソルがチカチカと点滅していて, 気が散ったことはないでしょうか.

私は視界に動くものがあると気になってしまい, カーソルの点滅(ブリンク)のせいで思考が霧散することが度々ありました. 集中して考えたいときは, いちいち目を閉じて画面を見ないようにしていたほどです. あまりに無駄な手間….

**解決策はシンプルで, macOSの設定を1つオンにするだけです.** 実際に, ブリンクあり・なしでNotionにタイプしたときの様子を比べてみます↓

**ブリンクあり**
![Notionでブリンクありの状態でタイプする様子](/images/macos-stop-blink-of-text-cursor/type-notion-blink.gif)
**ブリンクなし**
![Notionでブリンクなしの状態でタイプする様子](/images/macos-stop-blink-of-text-cursor/type-notion-noblink.gif)

ブリンク無しなら, カーソルはただそこに「ある」だけになり, 視線を引っ張られなくなります.



# macOSでブリンクを止める
macOS Tahoe 26 にて確認:

1. 「システム設定」を開く

2. サイドバーの「アクセシビリティ」を開く

3. 「視差効果」を開く

4. 「点滅しないカーソルを優先」をオンにする

英語表示の場合は System Settings > Accessibility > Motion > Prefer non-blinking cursor.

![システム設定のMotion画面でPrefer non-blinking cursorをオンにした様子](/images/macos-stop-blink-of-text-cursor/settings-screen.jpg)

これで, この設定に従うアプリではブリンクが止まります. 上で示したNotionの例も, この設定だけでブリンクが止まっています.

:::message
macOS Sequoia 15では, 同じ項目が「アクセシビリティ」>「ディスプレイ」に「点滅しないカーソル優先」という名前で置かれています. (詳しくは後述の「ブリンク設定の歴史」を参照してください.)
:::

Apple公式のガイドは下記です.

https://support.apple.com/ja-jp/guide/mac-help/mchla3c4f1da/mac



# VSCodeでもブリンクを止める

VSCodeのエディタ部分は, macOSの設定をオンにしてもブリンクが止まりません. エディタのカーソルをVSCodeが独自に描画しており, その点滅の仕方をVSCode自身の設定が決めているためです. VSCode側でも設定しましょう.

1. コマンドパレットを開く (shift cmd P)

2. "open user settings" とタイプし, "(JSON)" と付いていない方の "Preferences: Open User Settings" を開く

3. 検索窓に "blink" と入力

4. "Editor: Cursor Blinking" を "solid" にする

`settings.json` を直接編集する場合は, 下記を追記します.

```json
{
  "editor.cursorBlinking": "solid"
}
```

`editor.cursorBlinking` には `blink` (既定値), `smooth`, `phase`, `expand`, `solid` の5種類があり, 点滅しないのは `solid` だけです. 他の4つは点滅のアニメーションの違いです.

macOSの設定がオフでVSCodeもblink設定のままの場合・両方を設定した場合を比べると, 次のとおりです.

**ブリンクあり**
![VSCodeでブリンクありの状態でタイプする様子](/images/macos-stop-blink-of-text-cursor/type-vscode-blink.gif)
**ブリンクなし**
![VSCodeでブリンクなしの状態でタイプする様子](/images/macos-stop-blink-of-text-cursor/type-vscode-noblink.gif)

VSCodeの統合ターミナルのカーソルは, 別の設定 `terminal.integrated.cursorBlinking` で制御されます. こちらは既定値が `false` (点滅しない) なので, 自分で変更していなければ設定は不要です.

他にも, 独自にカーソルを描画するアプリ(エディタやターミナルなど)では, macOSの設定が効かないことがあります. その場合は, アプリ側に同様の設定がないか探してみてください.



# ブリンク設定の歴史

「点滅しないカーソルを優先」は昔からある設定ではなく, 私がmacOSを使い始めたタイミングにはありませんでした. 調べてみると, 下記のような経緯があったようです.

- macOS Sonoma 14より前: システム設定に項目はなかった. ただし, ターミナルで下記の `defaults` コマンドを実行すると, Apple標準のテキスト部品を使うアプリのブリンクを実質的に止められた. (例えばmacOS Monterey 12.6.5で動作報告がある.)

  ```bash
  defaults write -g NSTextInsertionPointBlinkPeriodOn -float 3600000
  defaults write -g NSTextInsertionPointBlinkPeriodOff -float 0
  ```

- macOS Sonoma 14: 上記のコマンドが効かなくなったという報告がある.

- macOS Sequoia 15: 「アクセシビリティ」>「ディスプレイ」に「点滅しないカーソル優先」が追加され, 標準の設定で止められるようになった.

- macOS Tahoe 26: 同じ項目が「アクセシビリティ」>「視差効果」に置かれている.

※ 上記の `defaults` コマンドは現在のmacOSでは効果がないので, 実行する必要はありません. 設定画面からオンにしてください.

コマンドの動作報告・Sonomaで効かなくなった報告は, 下記のフォーラムにあります.

https://forum.literatureandlatte.com/t/blinking-insertion-point-with-recent-update/134175

## なぜアクセシビリティ設定にあるのか

この設定が「アクセシビリティ」にあるのは, ブリンクが一部の人にとって大きな負担になるからです. 例えば, 小さな反復的な動きを見ると強い不快感を覚えるミソキネジア(misokinesia)の人や, ADHDの人にとって, 点滅するカーソルは集中を妨げる要因になると指摘されています.

こうした声を受けて, アプリ側の対応も進んでいます. 例えばMicrosoftは, 2025年にmacOS版のEdgeとTeamsをこの設定に従うようにしました.

https://misophoniainternational.com/?p=33472

私のように「なんとなく気になる」程度の人でも, オンにして損をする設定ではありません.



# まとめ

- macOSでは「システム設定」>「アクセシビリティ」>「視差効果」>「点滅しないカーソルを優先」をオンにすると, ブリンクが止まる.

- VSCodeのエディタは別途 `editor.cursorBlinking` を `solid` にする必要がある.

- この標準設定はmacOS Sequoia 15から使える.

私はこれのおかげで, 研究により集中できるようになりました.

考えることが多い人ほど, 効果を実感しやすいはずです. 設定は数秒で終わり, 気に入らなければ戻すのも一瞬なので, ぜひ一度試してみてください.

# 宣伝📣 国際シンポジウムを2026年11月24日に開催します

いわゆる国際会議です. NOREMIA Projectという国際共同研究のシンポジウムを, 名工大 (名古屋,鶴舞) にて行います.

ご興味ある方は, ラボHPでの続報をお待ちください↓ もうそろそろ公式ページを公開予定です.

https://csp.web.nitech.ac.jp/

