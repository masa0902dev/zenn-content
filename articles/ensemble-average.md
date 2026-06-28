---
title: "〈アンサンブル平均〉"
emoji: "🫶"
type: "tech"
topics: ["物理", "シミュレーション"]
published: true
---



> 「いいかい学生さん、グランドカノニカルアンサンブル平均をな、グランドカノニカルアンサンブル平均をいつでもとれるくらいになりなよ。それが、人間えら過ぎもしない貧乏過ぎもしない、ちょうどいいくらいってとこなんだ。」
> ーーーー 美味しんぼ「とんかつ慕情」より

ミクロカノニカルアンサンブルについて考えるためにグランドカノニカルアンサンブル平均を考えている記述に出会い, 混乱したのでメモ.


# アンサンブル平均とは
物理量$A$のアンサンブル平均は$\langle A \rangle$と表す.
ある物理量の, その系における期待値. 平均値ではなく期待値であることに注意.

期待値なので下記のように書ける.

$$
\langle A \rangle = \sum_{\alpha} A_{\alpha} P_{\alpha}
$$

ただし, 系は状態$\alpha$を確率$P_{\alpha}$で実現し, 状態$\alpha$において物理量$A$は$A_{\alpha}$をとるとする.



## ex1) micro-canonical-ensemble average
$$
\begin{align}
{\langle A \rangle}_{\text{micro}} &= \sum_{\alpha} \frac{A_{\alpha}}{\Omega} \nonumber \\
&= \frac{1}{\Omega} \sum_{\alpha} A_{\alpha}
\end{align}
$$

$\Omega \coloneqq \Omega(N,V,E)$は状態数.

## ex2) canonical-ensemble average
$$
\begin{align}
{\langle A \rangle}_{\text{canon}} &= \sum_{\alpha} A_{\alpha} \frac{e^{-\beta E_{\alpha}}}{Z} \nonumber \\
&= \frac{1}{Z} \sum_{\alpha} A_{\alpha} e^{-\beta E_{\alpha}}
\end{align}
$$

$Z \coloneqq Z(N,V,T) = \sum_{\alpha} e^{-\beta E_{\alpha}}$は分配関数 (partition function).
$\beta = 1/k_B T$は逆温度.

## ex3) grand-canonical-ensemble average
$$
\begin{align}
{\langle A \rangle}_{\text{grand}} &= \sum_{\alpha,N} A_{\alpha} \frac{e^{-\beta (E_{\alpha}^{(N)} - \mu N)}}{\Xi} \nonumber \\
&= \frac{1}{\Xi} \sum_{\alpha,N} A_{\alpha} e^{-\beta (E_{\alpha}^{(N)} - \mu N)} \nonumber \\
&= \frac{1}{\Xi} \sum_{\alpha,N} A_{\alpha} z^N e^{-\beta E_{\alpha}^{(N)}}
\end{align}
$$

$\Xi \coloneqq \Xi(\mu,V,T) = \sum_{\alpha,N} e^{-\beta (E_{\alpha}^{(N)} - \mu N)}$は大分配関数 (grand partition function).
$z = e^{-\beta \mu}$はフガシティ (fugacity).
$\mu$は化学ポテンシャル. $\mu_{\text{chem}}$と書いてあげるとわかりやすい.


# 注意
何を目的に, どんな系を対象にして, アンサンブル平均を考えているのか明記しよう!
