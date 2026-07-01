# slugがユニークでないと下記エラーが出るが, エラー原因(ユニークでないこと)が分かりにくいので注意
# error: slugの値（helloworld）が不正です。小文字の半角英数字（a-z0-9）、ハイフン（-）、アンダースコア（_）の12〜50字の組み合わせにしてください
slug=$1

npx zenn new:article --slug $1 \
&& mkdir ./.claude/$1/ && code ./.claude/$1/PLAN.md \
&& echo -e "Created new:article and directory for CLC\n: $1"
