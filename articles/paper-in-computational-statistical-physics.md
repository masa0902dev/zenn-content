---
title: "【計算統計物理】論文ノート、英単語や用語ノート"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["研究", "計算統計物理", "論文", "英語"]
published: true
---

# これは何？
- 主に計算統計物理分野の論文を読んだ際のノート、関連事項を調べたノート。
- 英単語や用語の意味と使われ方のメモ。
- 論文を読むたびに追記する。

:::message alert
CAUTION:
1. 他の分野や文脈においては、用語等の意味合いが違う場合もあります。
2. 私の知識不足により誤りを含む可能性があります。
:::

:::details 個人的なZennメモ

TODO: -> あとでチェックする部分

- Zennでの数式の参考 (Zennは$\KaTeX$が使える):
  - `npx zenn preview`で見れば良い。
  - ⭕️: $a=10$, ❌: $ a=10 $ (インラインは空白ダメ)
  - ブロックは普通に$*2で。ただし、上を1行空ける必要あり。
  - [Zennで数式を書く方法](https://zenn.dev/dmiyamo3/articles/34fb48a88aa813beffc0)
  - [Zennで数式を表示する](https://zenn.dev/ykyki/articles/math-formulae-in-zenn)

- Zennでの目次は、heading2まで表示される。
- [ZennのMarkdown記法一覧](https://zenn.dev/zenn/articles/markdown-guide)
:::



# Daigo Mugita 2024： Microscopic mechanisms of…
https://arxiv.org/abs/2410.05590

included:
- structural relaxation in highly dense system
- fluid phase and solid phase
- hard disk / sphere system
- Newtonian Event-Chain (NEC), Straight Event-Chain (SEC), Event-Chain Monte Carlo (ECMC)
- Efficiency analysis with respect to event-chain length (Lc), duration (Tc), system size, and relaxation performance

not included:
- coexistence phase or hexatic phase
- algorithmic details or derivation of the NEC method itself -> TODO: read paper about NEC algorithm itself

## 1. intro

- substantial 実質的な
- seminal: 大きな影響を与えた

平衡化と緩和は似ているが違う。平衡化は平衡状態に向かう全体的なプロセスで、緩和は局所的な乱れが静まる個別の道筋

- equilibration: 平衡化。非平衡状態から平衡状態に到達するまでの動的過程、プロセス。
- equilibrium: 平衡。時間的にマクロな観測量が変化しない状態、定常状態。
- relaxation: 緩和。緩和時間τ（相関の消失にかかる時間）に使う、自己相関関数 $C(t) \sim exp(-t/\tau)$。τが大きいほど相関が長く残るので、状態の記憶が長く、独立な状態が得にくくなる。

- methodology: 方法論。戦略的なアプローチ
- elucidate: 解明する
- incorporate: 取り入れる。新たな要素・理論・手法などを既存モデル・アルゴリズムに組み込む

ECMCは、MCMC（Markov Chain Monte Carlo）に factorization, liftingの概念を適用したサンプリング手法。

- factorization: 因数分解。特にMCMCでは、目的分布π(x)を条件付き分布の積として因数分解すること。高次元からのサンプリングを、部分空間でのサンプリングに分割できる。
- lifting: 遷移。特にMCMCでは、元のマルコフ連鎖の状態空間を拡張して、より効率的（高速）な遷移を可能にする手法。通常のMCMCでは時間的に可逆な遷移だが、リフティングによって非可逆（非対称）な遷移を導入して拡散を早める。

Metroppolis filterとは、試行遷移（trial move）を受け入れるか拒否するかを決めるフィルター処理。
このフィルターによって、望ましい平衡分布（例えばボルツマン分布）に従うサンプル列が得られる。つまり、メトロポリスアルゴリズムの需要確率の部分そのもの。
状態xに例えば方向や速度などの補助変数を加えて、変数を拡張する。これによって「進行方向に沿ったバイアスのある遷移」ができて、ランダム性を減らせる。

$$
受容確率A(x -> x') = min(1, \frac{\pi(x')}{\pi(x)}) \\
\pi(x)は目標とする平衡分布で、例えばボルツマン分布 \pi(x) = \exp(-\beta E(x))
$$

新しい状態がより低エネなら必ず受け入れる。高エネでも確率的に受け入れる（これは局所最適化に陥らないためである）。
このフィルターによって、詳細釣り合い条件（detailed balance）を満たした平衡分布を得る。

これに対し、ECMCは factorization, liftingによって高速なサンプリングを実現している。
ECMCは、MCMCと違って detailed balance は満たさない（満たすことを必須としない設計だ）が、global balance (全体釣り合い条件)を満たしている。

- consist of: ~から成り立つ。

ECMCはアクティブ粒子のほか粒子との衝突をイベントとする。

NEC（Newtonian Event-Chain）はECMCの一種。粒子位置の置き換えの際に、粒子の速度vを考慮する。これはEDMDのアナロジーである。
NECは特に、融解過程・核形成速度・拡散係数を計算する際に大きな優位をもつ。
NECはさらに、hard anistoropic particle (硬い（オーバーラップしない、重ならない）異方性（形状に対称性の破れがある、楕円や棒状など）粒子) への適用が「近似なしで」可能。これは、効率的な接触検出アルゴリズムを組み込んだことで実現した。

- analoguos: ~に類似して。アナロジーの形容詞。

- necleation rates: 核形成速度、Jで書かれることが多い？単位体積・単位時間あたりに新たな核が生じる確率。
核形成: 系の中に、小さな新しい相が自発的に生じる現象。
- diffusion coefficients: 拡散係数、Dで書かれることが多い。

- anisotropic: 異方性の。anisotropy（異方性）の形容詞

i.e. / e.g. どっちがどっち？

```text
e.g. → for example: ギリシャ語でexempli gratia。具体例をあげる。

Sophie loves picking fruit (e.g., strawberries, apples, blueberries and peaches).
ソフィーは果物狩りが好きです（たとえばイチゴ、リンゴ、ブルーベリー、桃など）


i.e. → that is / in other words (つまり)：ギリシャ語でid est。言い換えたり明確化する。specifically, namely。

Only one president, i.e., Richard Nixon, resigned from office.
辞任した大統領は1人、すなわちリチャード・ニクソンだけです
```

- exceptionally: 並外れて、非常に（程度が例外的に大きいってこと）

構造緩和（粒子位置の緩和）は、特に高密度系では、非常に困難。なぜなら、排除体積効果が支配的だから。
排除体積効果が支配的だと、粒子が1回のイベントで動ける程度（その状態から変化できる程度）が非常に小さい。なぜなら…
1. 粒子が互いにめり込めないので、自由に動けないから。（自由に動ける距離が小さいから）
2. （高密度系では、粒子が詰まっているから1イベントあたりに動ける距離が小さいから）

上記が原因となって構造緩和の進行が遅いことで、系の時間自己相関関数はなかなか減衰しない。

- excluded-volume effect: 排除体積効果。
排除体積は、ある粒子が存在するときにその周囲に他の粒子が侵入できない空間、のこと。これは、単なる幾何学的な粒子のサイズだけの話ではなく、粒子の形状や向きにも依存する。
- dominant excluded-volume effect: 系の性質（相転移、構造など）が、エネルギー的要因ではなく、ほとんど排除体積効果だけによって決まっている状態。つまり、粒子同士の引力や静電相互作用などはほとんど関与せず、粒子が互いに重ならないという条件だけが、系のマクロな挙動を支配している状態。
これは、高密度・ハード粒子系で典型的である。

構造緩和は、glassy physics (ガラス状態やガラス天威の統計力学的な性質などの分野) での「slow dynamics (遅い動力学, 系が時間に対して非常にゆっくりと進展する現象や対象)」おいて、最大の関心事だ。
ガラスなどの、高密度系での構造緩和を(定量的に)評価するにあたって、MSD, ISF, NGPは重要な指標となる。

そもそもガラスとは: 液体のように無秩序だが、個体のように動かない物質の状態のこと。構造的には液体（短距離秩序しかない）だが、力学的には固体（剪断応答する）というハイブリッド。

- metrics: 指標。

<br>

**MSD**, mean square displacement:
粒子の平均的な移動距離の2乗を時間経過とともに測った量

$$
MSD(t) = \langle |\vec{r(t)} - \vec{r(0)}|^2 \rangle
$$
<.>は、粒子と初期時刻についての平均。MSDが十分に大きな値に達すれば、それは粒子がもはや初期位置を覚えていないということ。よって、MSDが十分大きければ、構造緩和が完了したと言える。

**ISF**, intermediate scattering function:
ミクロな密度揺らぎの時間的相関を測る関数。

$$
F_s (q, t) = \langle \exp(i q \cdot |\vec{r(t)} - \vec{r(0)}| ) \rangle
$$
qは波数ベクトル、<.>はアンサンブル平均（または時間平均）。初期時刻で Fs(q,0) = 1 (完全相関)。時間が経つと、粒子が動いてFs(q,t)は0に減衰する。減衰の仕方から、特定スケールでの構造緩和の進行状況がわかる。
Fsが十分に0近くに減衰したら、粒子の配置が記憶を失ったということ。よって、ISFが十分大きければ、構造緩和が完了したと言える。
特に、緩和時間$\tau_\alpha$(α-緩和時間)を$F_s(q,\tau_\alpha) = \langle \exp(i q \cdot |\vec{r(\tau_\alpha)} - \vec{r(0)}| ) \rangle = e^{-1}$となる時間として定義することが多い。

**NGP**, non-gaussian parameter:
粒子の移動分布が単なるガウス分布（正規分布）からどれだけズレているかを定量化する指標。

$$
2次元系の典型 (3次元系なら分母にかけてる係数が3になる) \\
\def \DIFF #1 { |\vec{r(t)} - \vec{r(0)}|^{#1} }
\def \ANGLE #1 { \langle #1 \rangle }

\alpha_2 (t) = \frac{ \ANGLE{\DIFF{4}} }{2 \ANGLE{\DIFF{2}} ^2 } - 1
$$
G的挙動(理想的なG分布)、つまり普通のブラウン運動なら $\alpha_2(t)=0$。
$\alpha_2(t)>0$なら、G分布に比べて、遠くまで動く粒子が多く存在する(広がった移動分布（尾が太い）を持つ)。
構造緩和の過程で、NGPはピークを持つことが多い。このピーク時刻は、粒子軍における異常な動きの最大化時点と対応し、$\tau_\alpha$ (α-緩和時間) に近いことが多い。

<br>

ensemble average (アンサンブル平均):
ある時刻に存在しうる全ての状態を集めた「仮想的な集団（＝アンサンブル）」に対して、その物理量の平均をとること。
エルゴード仮説が成り立つ場合、アンサンブル平均と時間平均は一致するとされる(エルゴード仮説のもとで考えることが多い)。アンサンブル平均は、ある物理量の**その時刻における**状態の平均なので注意。

$$
物理量Aのアンサンブル平均 \\
\langle A \rangle = \int A(x)P(x) dx
$$
P(x)は状態xにある確率（平衡分布なら、ボルツマン分布）。確率的に重み付けして平均することで、ミクロな揺らぎを均して、再現性のあるマクロな物理量が得られる。
粒子位置、エネルギー、自己相関関数、MSD, ISFなどに用いられることが多い。


EDMD, EDMDの構造緩和・粒子拡散の数値的アプローチは大きく異なるため、その性能比較は困難だ。

- metastable state: 準安定状態。完全な安定状態（熱力学的平衡）ではないが、長い時間安定して存在できる状態。
最終的には、より低い自由エネの本当の平衡状態に移行する。しかし、そこへ行くためにエネルギー障壁があり、それをなかなか越えられないので、長い時間安定して存在できる状態。自由エネが局所的な最小値をとっている状態。
安定状態(global minimum)も準安定状態(local minimum)も、自由エネFについて$\frac{dF}{dx}=0, \frac{d^2F}{dx^2}>0$を満たす。極小値なので当然。

- attain: 達する。達成する
- optimal: 最適な
- physical properties: 物理的特性。propertyが加算で「特性」。科学的なニュアンスでは特性の意味が多い。
- elusive: 見つけたりするのが困難、達成するのが困難。形容詞

ここでは、構造緩和の効率を測定するために、イベント（衝突）回数・CPU時間を用いている。
（ただし、NECのチェイン長さには、CPU時間ではなく粒子の持つ速度vを用いて時間を計算する。チェイン長さはTc）

## 2. model and simulation methods

粒子のエネルギーは$1/\beta = 1/k_B T$としている。
質量m, 直径d = 2σ としているので、次元解析から、自然な時間単位τは下記の式になる。

- unit of time: 時間単位。系の時間的なスケールを測るための基準量。計算統計物理では、時間単位は「自然単位」で定義することが多い。
  次元解析によって定めるには、この場合、粒子直径d、質量m、エネルギー1/β (熱エネルギー)を用いる。
  自然な時間単位τは、粒子が自分のサイズ分動くのにかかる典型時間が基準となる。
  
  $$
  \tau = d \sqrt{\beta m}
  $$
  この自然単位τは、例えばNECの鎖長Tc（チェーン時間）を計算する際に現れるわけではない。しかし、シミュレーション結果の物理解釈において、構造緩和や拡散係数と結びつけて考えるにはτが必要。

- 次元解析
L, M, T（長さ、質量、時間）から考える。
上例では、L=2σ=d, M=m, E=1/β である。

$$
E = \frac{1}{2} m v^2 などから (エネルギーE)=M L^2 T^{-2} \\
\therefore T = L \sqrt{E^{-1} M}
$$

[相転移について既知の情報] **ハードディスクのシステムについて**、システムの充填率 $\nu = \pi \sigma^2 \cdot N / A$ (2D, A is area) に対しての相↓

| $\nu$ | state | description |
| ----- | ----- | ----------- |
| v < 0.700 | liquid | 粒子は完全にランダムに動ける。短距離秩序しかない。MSDがすぐリニアになり、緩和構造時間が短い |
| 0.700 < v < 0.716 | coexistence region (liquid and solid) | 巨視的には相分離が見られる（結晶ドメイン＋液体領域）。第一種相転移の兆候 (最近のEDMDやECMCの大規模計算によって検出された) |
| 0.716 < v < 0.720 | hexatic | 方向秩序はあるが、位置秩序はない中間的な相。イメージとしては、配向秩序変数が異なる固相が複数ある状態（グローバル配向秩序変数を考慮する必要はある） |
| 0.720 < v | crystal | 粒子が結晶格子状に配置。六方格子構造。並進秩序が準長距離的に存在している。動きは小さく、拡散係数が0に近づく |

ここでは、液相と固相のみシミュレートしている。

2次元系における固体化は、3次元系とは本質的に異なる。
3d: liquid -> solid の第一種相転移。2d: 段階的に変化する。中間層が現れる。

- threshold: 閾、閾値（しきいち）。

NECは、粒子の速度分布としてMaxwell-Boltzmann分布を与える（EDMDと似ている）。鎖長として、粒子の速度と移動距離から計算した経過時間を合計したTcを用いる。粒子の速度には、$v_{rms} = \sqrt{\langle v^2 \rangle}$を用いる（二乗のアンサンブル平均のルート, root mean square）。

- diffusion coefficients: 拡散係数D。coefficitent==係数。

ここでは拡散係数として、$D_{ev}$ (based on number of events $N^*_{ev}$), $D_{cpu}$ (based on CPU time $t_{cpu}$) を用いる（M. Klement 2019, H. Banno 2022 に対応）。DはMSDから計算。

$$
\gdef \MSD {\langle |\Delta \vec{r} - \langle \Delta \vec{r} \rangle |^2 \rangle}

\MSD = \frac{1}{N} \sum_{i=1}^{N} |\Delta \vec{r_i} - \langle \Delta \vec{r} \rangle |^2 \\
$$
$$
\def \MSD {\langle |\Delta \vec{r} - \langle \Delta \vec{r} \rangle |^2 \rangle}

D_{ev} = \lim_{N^*_{ev} \rightarrow \infty} \frac{\MSD}{4N^*_{ev}} \\
D_{cpu} = \lim_{t_{cpu} \rightarrow \infty} \frac{\MSD}{4t_{cpu}} \\
$$
$\Delta \vec{r_i}$は、N_ev回の衝突後の粒子iの変位ベクトル（初期位置からの変位）、N_ev回のイベント実行によってどれだけ動いたか。ラプラシアンではなく変位。
$\Delta \vec{r}$は、全粒子の平均変位ベクトル。系全体が、どの方向にどれくらい動いたかの平均。

$N^*_{ev}$は粒子一個あたりのイベント数。$N^*_{ev} = N_{ev} / N = (全体のイベント数) / (粒子数)$

系全体が移動すると、本来の「粒子の相対的な再配置」が見えにくくなるので、$\Delta \vec{r} - \langle \Delta \vec{r} \rangle$として全体のドリフト（流れ）成分を差し引き、構造緩和に本質的な内部変化のみを抽出している。

- flow component: 流れ成分。componentが構成要素、成分。系全体が動く並進運動。ここでは構造緩和を見たいので、除去する。
- シミュレーションに使用したコアについても論文に記載しておくようだ。何コア用いたか（普通はシングルコアで）も。
- grip-mapping手法は M. Isobe 1999 を用いている。
  TODO: 読む、pdfアリ。https://doi.org/10.1142/S0129183199001042 "剛体円盤分子動力学シミュレーションにおける大規模計算と高速化の手法" 1ループO(NlogN)。N. Murase 2024 (初期の処理が重い代わりに、その後の1ループO(1))も論文があれば読む。



## 3. results

### A. liquid phase
#### MSD
N=256^2, ν=0.450 でSEC-all:

$L^*_{c} = L_c / d$ (Lc is chain length)

- plateau: 横ばい、高台。一時的に値がほぼ一定になる区間。

$L^*_c$が大きい場合は、プラトーが中間時間スケールで観測された（1.8*10^8）。
この原因は、1つのチェーンにおいて粒子たちが一方向的に移動することである。これはドメインの流れ（部分的な集団運動）に似ている。
このドメインフロー的な運動により、隣接粒子との相対的な拡散は小さくなる（隣接粒子も同じような方向へ移動するから）。これにより、見かけの拡散が抑制された。
→→チェーン長が長すぎると、MSDなどで観測できる拡散効率は低下する。

SEC-allが、「正規拡散（normal diffusion）」の状態に至るまでに最多の移動（イベント）を要した（$N^*_{ev} \ge 10^6$で正規拡散の振る舞いが観測された。）。これは、チェーン長を長くしても、高密度領域（v <= 0.740）においても、改善されなかった。（通常は、行為都度や長いチェーン長では構造緩和は進みやすくなる）
→→SEC-allでは、正規拡散の領域に達するまでに、**粒子1つあたりに**100万回ほどのイベント（移動）が必要。SEC-allの拡散非効率性は、単なるパラメータ設定の問題ではなく、アルゴリズムの限界に起因すると考えられる。

- normal diffusion: 正規拡散。$MSD \propto t$となっている状態。

- deem: ~と考える。〜とみなす。
- validity: 有効性、正当性。

SEC-allの結果から、拡散の性質を調査するために$10^6 <= N^*_ev$を調査することにした。D_cupの計算にも、その$N^*_ev$に対応するt_cpuの範囲を用いた。


#### Lc,Tc or duration dependence of D
SECにおけるチェイン長Lc、NECにおけるチェイン時間Tcが、拡散係数にどう影響するか調べる。
EDMD（チェイン長はない）、SEC-xy, SEC-all, NECで調査した。

**NEC**: Tcを長くするとDev,Dcpuともに「D増大→Dのプラトー」となった。**Tcを無限大、つまりリサンプリング（現在のチェーンを切って、新しい粒子を選び直して新たなチェーンを形成する）しない場合でもプラトーだった**。また、EDMD,SECと比較してDcpuは最大だった。ただしDevはEDMD > NECだった。

一方で、SEC-xy,SEC-allは「D増大→Dのプラトー→D減少」となった。チェーン長を長くしすぎると拡散効率が下がる


#### system size dependency




### B. solid phase
#### MSD, D



#### microscopic mechanisms of diffusion




## 4. concluding remarks
