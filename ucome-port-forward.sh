#!/bin/sh
# druby://localhost:9007 を druby://vm2016.melt.kyutech.ac.jp:9007
# druby は ip を一致させないと通信できない（本当？）

if [  $# -eq 0 ]; then
    # 本番環境をポートフォワードするなら
    ssh -f -N -L 9007:150.69.90.81:9007 vm2016.melt.kyutech.ac.jp
else
    # ホスト $1 の 127.0.0.1 で待つ ucome をポートフォワードするなら、
    ssh -f -N -L 9007:127.0.0.1:9007 $1
fi


