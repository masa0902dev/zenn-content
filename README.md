# masa's Zenn Article & Books
[HOME](https://zenn.dev/masa0902dev)

- 勉強ノートは、ノートしてからGPTにまとめてもらうと良い。

```bash
npx zenn new:article --slug 記事のスラッグ
```
- slugは記事・本ごとにユニークに。他ユーザーの記事で使用済みのslugも使用できない！
- slugを変えると別の投稿として作成される！

画像
- 画像は/imagesに置く必要がある．
- 画像パスは`![altテキスト](/image/img-filename.png)`のように絶対パス必須．

**ディレクトリ分け**
TODO: シンボリックリンクを使えば上手く構造化できるのでは？


# Markdown & Latex
## Markdown Syntax
見出しリンク（Markdown標準）: `[表示テキスト](#見出しの-名前)`のように，半角スペースはハイフンにする．
リンクはURLなので，小文字で書く．ただし，日本語はURLエンコードせずともいける．

## 目次を生成する
コマンドパレットで`table of content` (Markdown All in One)．
ファイル保存すると自動更新される！
目次をzennの details に入れるには，中身に最後１空行を入れること．じゃないと勝手に削除されてしまう．

## snippets
`$$`, `$$\n$$`内は、言語がLatexとして認識される。
よって、数式のSnippet登録はLatexにする必要がある。

settings.jsonで`"[markdown,latex]"`の書き方をすると（おそらくエラーになって）設定が適用されないので注意。

## keybindings
cmd+M : $$
cmd+alt+M : $$\n$$

## zenn preview for github.dev
command pallet -> Show zenn Preview
VScode内でzennプレビューを閲覧できる。タブでサイドバー移動できる。

## PDF preview
- alt up/down : ページ移動
- alt shift G : ページ数へ移動

## user dict
ノート中に変換がうまくいかないものがあればNoteにメモって、あとで`my-mac-settings`ディレクトリでまとめて辞書追加する。

## latex
vectorは`\bold{v_i}`でいける: $\bold{v_i}$
