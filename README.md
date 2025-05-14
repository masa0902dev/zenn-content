# masa's Zenn Article & Books
[HOME](https://zenn.dev/masa0902dev)

```bash
npx zenn new:article --slug 記事のスラッグ
```
- slugは記事・本ごとにユニークに。他ユーザーの記事で使用済みのslugも使用できない！
- slugを変えると別の投稿として作成される！


# Markdown & Latex
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
