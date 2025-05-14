---
title: "形式がよく変わるPDFから動的にデータ抽出する【Python】"
emoji: "📈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["pdf", "python", "pypdf"]
published: false # 平田tに確認とってからtrueにすること！
---

# はじめに
## 何がわかる？
- ✅ わかること
  - PDFからのテキストデータの抽出方法。
  - PDFの形式がよく変わる場合に、どのように対象ページを動的に決定するか。

- ❌ わからないこと
  - 目的ページ自体の形式が変わる場合の対応（例: 表の形式が大幅に変わるなど）
  - PDFからの画像の読み取り方法

## 要約
- PyPDF2ではなくpypdfを使おう。
  - 理由: PyPDF2はもうメンテナンスされていないから。また、pypdfの方が表形式などに優れているから。
- PDF全ページを走査して、キーワードのinclude / excludeをチェックすることで対象ページを決定する。

## 記事のモチベーション
https://heatstroke.jp/

著者は[熱中症搬送者数予測サイト](https://heatstroke.jp)を技術補佐員として開発しており、こちらの2025年プレスリリースが迫ってきました。そんな時、外部データを取得しているGithub ActionsのFailed通知がDiscordに！

原因は、[総務省消防庁のサイト](https://www.fdma.go.jp/disaster/heatstroke/post3.html)から取得している週報PDF（搬送者数の速報実測値）の表示の形式が変わったことでした。目的のPDFページの内容自体はあまり変わっていなかったため、形式変更への対策として、対象ページを動的に決定する方法を実装しました。

:::details 熱中症搬送者数予測サイトについて
予測値は06/01から生成されます！
熱中症対策の目安としてご利用ください。2025年からは47都道府県に対応しています。

<br />

2024年時点での関連主要論文は下記のとおりです。
最新情報は、06/01頃に公開されるプレスリリースをご覧ください。
1. A Takada, S Kodera, K Suzuki, M Nemoto, A Hirata, "Estimation of the number of heat illness patients in eight metropolitan prefectures of Japan: Correlation with ambient temperature and computed thermophysiological responses," Frontiers in Public Health 11, 1061135, 2023.
2. S Kodera, T Nishimura, EA Rashed, K Hasegawa, I Takeuchi, R Egawa, A. Hirata, "Estimation of heat-related morbidity from weather data: A computational study in three prefectures of Japan over 2013-2018," Environment international 130, 104907, 2019.

<br />

「熱中症搬送者数予測サイト」に関するメディアや文章画像利用などのお問い合わせは、以下ページの「お問い合わせフォーム」からお願いいたします。
https://heatstroke.jp/disclaimer.html

出典:
名古屋工業大学　平田・小寺研究室
[https://heatstroke.jp](https://heatstroke.jp) (2025/05/15に利用)
:::

# 使用した言語・ライブラリ
- lang: Python v3.12.7
- library: pypdf v5.4.0

https://github.com/py-pdf/pypdf

※ 今回は表なので、pypdfよりもpdfplumberの方が良かったかも。
https://github.com/jsvine/pdfplumber

# コード例と説明
## 0. コード全体
要旨のコードの全体像です。

:::details 要旨の全体コード
```py
import pypdf
from pypdf import PdfReader
import re


def is_target_page(text: str) -> bool:
    if not text:
        return False

    must_include = [
        "救急搬送状況",
        "直近週",
        "都道府県",
        "年齢区分別",
    ]
    must_exclude = ["日付", "曜日", "累計"]

    for keyword in must_include:
        if keyword not in text:
            return False
    for keyword in must_exclude:
        if keyword in text:
            return False

    return True


def get_target_page_text(reader: PdfReader) -> str:
    for page in reader.pages:
        text = page.extract_text()
        if is_target_page(text):
            return text
    return None


# 異常なPDFを修正するための関数
def insert_space_before_prefecture(text):
    # 数字と都道府県名の間のみに半角スペースを挿入する正規表現
    pattern = r'(\d+)([^\d\s,]+)'
    # マッチ部分に半角スペース挿入
    result = re.sub(pattern, r'\1 \2', text)
    return result


def parse_data_from_text(text: str) -> list[list[str | int]]:
    lines = text.split('\n')
    data = []
    for line in lines:
        # 4桁かつコンマのついた文字列も読み取れる正規表現
        match = re.match(r'^(\d+)\s+([^\s]+)\s+.*?([\d,]+)\s*$', line)
        if match:
            id_, pref, num = match.groups()
            number = int(num.replace(',', ''))
            data.append([pref, number])
            if int(id_) == 47:
                break
    for i in range(len(data)):
        data[i].insert(0, prefectures_en[i])
    return data


def main():
    if not os.path.exists(pdf_file_path):
        print(f"PDF not found: {pdf_file_path}")
        return
    if os.path.getsize(pdf_file_path) == 0:
        raise Exception(f"PDF is empty: {pdf_file_path}")

    with open(pdf_file_path, 'rb') as file:
        reader = pypdf.PdfReader(file)
        try:
            text = get_target_page_text(reader)
            if text is None:
                raise Exception("Target page not found.")
            if text == "":
                raise Exception("Target page is empty.")
        except Exception as e:
            print("ERROR: reading pdf file:", e)
            return
    text = insert_space_before_prefecture(text)

    data = parse_data_from_text(text)

    # その後の書き込み処理など………


main()

```
:::

## 1. PDFファイルを読み込む
```py
import pypdf

if not os.path.exists(pdf_file_path):
    print(f"PDF not found: {pdf_file_path}")
    return
if os.path.getsize(pdf_file_path) == 0:
    raise Exception(f"PDF is empty: {pdf_file_path}")

with open(pdf_file_path, 'rb') as file:
    reader = pypdf.PdfReader(file)
    try:
        text = get_target_page_text(reader)
        if text is None:
            raise Exception("Target page not found.")
        if text == "":
            raise Exception("Target page is empty.")
    except Exception as e:
        print("ERROR: reading pdf file:", e)
        return
```
- PDFファイルの存在確認、データが取れてなくて0byteの場合のエラー処理。
<br />
- pdfはバイナリデータなので'r'ではなく'rb'で開く。
- PdfReaderオブジェクトのreaderを作成し、対象ページを取得する関数get_target_page_text()に渡す。

## 2. PDFの目的ページを取得する
```py
from pypdf import PdfReader

def get_target_page_text(reader: PdfReader) -> str:
    for page in reader.pages:
        text = page.extract_text()
        if is_target_page(text):
            return text
    return None
```
- 引数の型をpypdfからインポートして指定している。

- reader.pagesでPDFの各ページをループする。
  - page.extract_text()でそのページのテキストを取得。
  - is_target_page()にテキストを投げて、目的ページかを判定

## 3. キーワード検出で対象ページを決定
```py
def is_target_page(text: str) -> bool:
    if not text:
        return False

    must_include = [
        "救急搬送状況",
        "直近週",
        "都道府県",
        "年齢区分別",
    ]
    must_exclude = ["日付", "曜日", "累計"]

    for keyword in must_include:
        if keyword not in text:
            return False
    for keyword in must_exclude:
        if keyword in text:
            return False

    return True
```
- 目的ページのキーワードをinclude/excludeで検出している。
目的ページに含まれる文字列が変わった時のために、キーワードは別ファイルに切り出した方がいいかも。（未来のシステム管理者のため）

## 4. 正規表現などでデータを抽出
```py
def parse_data_from_text(text: str) -> list[list[str | int]]:
    lines = text.split('\n')
    data = []
    for line in lines:
        # 4桁かつコンマのついた文字列も読み取れる正規表現
        match = re.match(r'^(\d+)\s+([^\s]+)\s+.*?([\d,]+)\s*$', line)
        if match:
            id_, pref, num = match.groups()
            number = int(num.replace(',', ''))
            data.append([pref, number])
            if int(id_) == 47:
                break
    for i in range(len(data)):
        data[i].insert(0, prefectures_en[i])
    return data
```
Pythonでの正規表現の扱い方(reモジュール)は、こちらの記事がわかりやすいと思います。
https://note.nkmk.me/python-re-match-search-findall-etc/

そもそも正規表現(Regex)って何だ？という方は、こちらの記事がわかりやすいと思います。
https://zenn.dev/seiya0/articles/tech-regular-expression

# PDFの人為的ミスへの対策
形式変更に対策したらコレでOK！…とはなりません。
この総務省消防庁のPDFは、機械生成ではなく手動編集されていると思われるミスが過去にありました。

- 人為的ミスの例:
  - テキストの前にスペースがあったりなかったりする
  - 全角記号と半角記号の混在
  "() vs （）"
  " vs 　" (半角スペース vs 全角スペース)

記事要旨から外れるため紹介に留めますが、上記のようなものは正規表現を用いて、スペース個数を統一したり半角全角に両対応したりするのが良いでしょう。

# おわりに
Pythonとpypdfを用いた、PDFの表示形式の変更への対策を紹介しました。

そもそも、データの置き方・データ形式が利用しやすいものであれば考えなくて済むことなのですが…そうではないモノも中にはあるので、致し方ないですね…。

:::details もし非エンジニアの方が読まれていたら: どんなデータ形式がいいのか？

**機械的にそのデータを利用する・特に数値的なデータの場合**、私はこう思います。

| 評価 | データ形式 |
| ---- | ---------- |
| ✅ウレシイ | CSV, Json |
| 🔼マシ | Excel |
| ❌ヤメテ | Word, PDF, PowerPoint, データの画像埋め込み...etc |

Excelはクリック操作のみでCSVへ変換することができます。Excelを公開する場合は、CSV出力までやって頂けるとウレシイです。

<!-- また、Web上にデータ公開する場合、サイトページにファイルを置くよりもAPIで公開して頂けるとトテモウレシイです。もし社内にエンジニアがいない場合は、ノーコード/ローコードでAPIを作成できるサービスもあります。自動化アプリとして有名なZappierでAPI公開できたり、Excelに似たGoogle Spread Sheetをデータ元としてほんのちょっとのコード(GAS)を書くだけでAPIでデータ公開できたりします（今なら、AIに聞けば簡単なコードはしっかりと書いてくれますし、ITツールの使い方もわかりやすく教えてくれます）。 -->
:::

