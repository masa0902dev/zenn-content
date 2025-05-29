---
title: "形式がよく変わるPDFから動的にデータ抽出する【Python】"
emoji: "📈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["pdf", "python", "pypdf"]
published: true
---

# はじめに
## 何がわかる？
- ✅ わかること
  - PDFからのテキストデータの抽出方法．
  - PDFの形式がよく変わる場合に，どのように対象ページを動的に決定するか．

- ❌ わからないこと
  - 対象ページ自体の形式が変わる場合の対応（例: 表の形式が大幅に変わるなど）
  - PDFからの画像の読み取り方法

## 要約
- PDF全ページを走査して，キーワードのinclude/excludeをチェックすることで対象ページを決定する．
- PyPDF2ではなくpypdfを使おう．(PyPDF2はもうメンテナンスされていないから．また，pypdfの方が読み取りが優れているから．)

## 本記事のモチベーション
https://heatstroke.jp/

著者は[熱中症搬送者数予測サイト](https://heatstroke.jp)を技術補佐員として開発しており，5月28日に2025年版プレスリリースが公開されました．その1週間ほど前，外部データを取得しているGithub ActionsのFailed通知が突如Discordに！

原因は，[総務省消防庁のサイト](https://www.fdma.go.jp/disaster/heatstroke/post3.html)から取得している週報PDF（搬送者数の速報実測値）の形式が変わったことでした．PDFの対象ページの内容自体はあまり変わっていなかったため，今後の形式変更への対策として，対象ページを動的に検出する方法を実装しました．

:::details 熱中症搬送者数予測サイトについて
予測値は05/21から生成されています！熱中症対策の目安としてご利用ください．
2024年は10都道府県のみでしたが，2025年からは47都道府県に対応しています．
<br>

2025年時点での関連主要論文は下記のとおりです．
詳細は，[こちらの2025年版プレスリリース](https://www.nitech.ac.jp/news/press/2025/12908.html)をご参照ください．
1. 47都道府県における推定および地方における推定誤差
T. Matsuura, S. Kodera, and A. Hirata, “Predicting Heat-related Morbidity in Japan through Integrated Meteorological and Behavioral Factors,” Environmental Challenges, vol. 18, article no. 101106, 2025.
2. 8都道府県における推定
A Takada, S Kodera, K Suzuki, M Nemoto, A Hirata, "Estimation of the number of heat illness patients in eight metropolitan prefectures of Japan: Correlation with ambient temperature and computed thermophysiological responses," Frontiers in Public Health 11, 1061135, 2023.
3. 名古屋市における推定
T. Nishimura, E. A. Rashed, S Kodera, H. Shirakami, R. Kawaguchi, K Watanabe, M. Nemoto, A. Hirata, “Social implementation and intervention with estimated morbidity of heat-related illnesses from weather data: a case study from Nagoya City, Japan,” Sustainable Cities and Society 74, 103203, 2021
4. 高齢者搬送者数の推定
S Kodera, T Nishimura, EA Rashed, K Hasegawa, I Takeuchi, R Egawa, A. Hirata, “Estimation of heat-related morbidity from weather data: A computational study in three prefectures of Japan over 2013-2018,” Environment international 130, 104907, 2019
<br>

「熱中症搬送者数予測サイト」に関するメディアや文章画像利用などのお問い合わせは，以下ページの「お問い合わせフォーム」からお願いいたします．
https://heatstroke.jp/disclaimer.html

出典:
名古屋工業大学　平田・小寺研究室
[https://heatstroke.jp](https://heatstroke.jp) (2025/05/29に利用)
:::



# 使用した言語・ライブラリ
- lang: Python v3.12.7
- library: pypdf v5.4.0

https://github.com/py-pdf/pypdf



# コード例と説明
0. [コード全体](https://zenn.dev/masa0902dev/articles/pdf-dynamic-detection#0.-%E3%82%B3%E3%83%BC%E3%83%89%E5%85%A8%E4%BD%93)
1. [PDFファイルを読み込む](https://zenn.dev/masa0902dev/articles/pdf-dynamic-detection#1.-pdf%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%82%92%E8%AA%AD%E3%81%BF%E8%BE%BC%E3%82%80)
2. [PDFの対象ページを取得する](https://zenn.dev/masa0902dev/articles/pdf-dynamic-detection#2.-pdf%E3%81%AE%E5%AF%BE%E8%B1%A1%E3%83%9A%E3%83%BC%E3%82%B8%E3%82%92%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B)
3. [【ココ本題】キーワード検出で対象ページを決定](https://zenn.dev/masa0902dev/articles/pdf-dynamic-detection#3.-%E3%82%AD%E3%83%BC%E3%83%AF%E3%83%BC%E3%83%89%E6%A4%9C%E5%87%BA%E3%81%A7%E5%AF%BE%E8%B1%A1%E3%83%9A%E3%83%BC%E3%82%B8%E3%82%92%E6%B1%BA%E5%AE%9A)
4. [正規表現などでデータを抽出](https://zenn.dev/masa0902dev/articles/pdf-dynamic-detection#4.-%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%8F%BE%E3%81%AA%E3%81%A9%E3%81%A7%E3%83%87%E3%83%BC%E3%82%BF%E3%82%92%E6%8A%BD%E5%87%BA)

## 0. コード全体
要旨のコードの全体像です．

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
- exists()でPDFファイル存在確認，getsize()でデータが取れてなくて0byteの場合を検知．
<br />
- pdfはバイナリデータなので'r'ではなく'rb'で開く．
- PdfReaderオブジェクトのreaderを作成し，対象ページを取得する関数get_target_page_text()に渡す．

## 2. PDFの対象ページを取得する
```py
from pypdf import PdfReader

def get_target_page_text(reader: PdfReader) -> str:
    for page in reader.pages:
        text = page.extract_text()
        if is_target_page(text):
            return text
    return None
```
- 引数の型PdfReaderをpypdfからインポートして指定している．

- reader.pagesでPDFの各ページをループする．
  - page.extract_text()でそのページのテキストを取得．
  - is_target_page()にテキストを投げて，対象ページかを判定

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
- 対象ページのキーワードをinclude/excludeで検出している．
対象ページに含まれる文字列が変わった時のために，キーワードは別ファイルに切り出した方がいいかも．（未来のシステム管理者のため）

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
Pythonでの正規表現の扱い方(reモジュール)は，こちらの記事がわかりやすいと思います．
https://note.nkmk.me/python-re-match-search-findall-etc/

そもそも正規表現(Regex)って何だ？という方は，こちらの記事がわかりやすいと思います．
https://zenn.dev/seiya0/articles/tech-regular-expression

# PDFの人為的ミスへの対策
形式変更に対策したらコレでOK！…とはなりません．
例えばこの総務省消防庁のPDFは，機械生成ではなく手動編集されていると思われるミスが過去にありました．

- 人為的ミスの例:
  - テキストの前にスペースがあったりなかったりする
  - 全角記号と半角記号の混在
  半角カッコ() vs 全角カッコ（）
  半角スペース vs 全角スペース...

記事要旨から外れるため紹介に留めますが，上記のようなものは正規表現を用いて，スペース個数を統一したり半角全角に両対応したりするのが良いでしょう．

# おわりに
Pythonとpypdfを用いた，PDFの表式変更への対策を紹介しました．

そもそも，データの置き方・データ形式が利用しやすいものであれば考えなくて済むことなのですが…そうではないモノも中にはあるので，致し方ないですね…．

:::details もし非エンジニアの方が読まれていたら: どんなデータ形式がいいのか？

**機械的にそのデータを利用する・特に数値的なデータの場合**，私はこう思います．

| 評価 | データ形式 |
| ---- | ---------- |
| ✅ウレシイ | CSV, Json |
| 🔼マシ | Excel |
| ❌ヤメテ | Word, PDF, PowerPoint, データの画像埋め込み...etc |

Excelはクリック操作のみでCSVへ変換することができます．Excelを公開する場合は，CSV出力までやって頂けるとウレシイです．

<!-- また，Web上にデータ公開する場合，サイトページにファイルを置くよりもAPIで公開して頂けるとトテモウレシイです．もし社内にエンジニアがいない場合は，ノーコード/ローコードでAPIを作成できるサービスもあります．自動化アプリとして有名なZappierでAPI公開できたり，Excelに似たGoogle Spread Sheetをデータ元としてほんのちょっとのコード(GAS)を書くだけでAPIでデータ公開できたりします（今なら，AIに聞けば簡単なコードはしっかりと書いてくれますし，ITツールの使い方もわかりやすく教えてくれます）． -->
:::

