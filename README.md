# 人工知能ボットAPI
下記リンクのUserLocalさんの人工知能ボットAPIを使用したrailsの簡易Webチャットアプリになります。
http://ai.userlocal.jp/

### APIキー
人工知能ボットAPIの呼び出しにはAPIキーが必要になります。
APIキーはconfig/initializers/constants.rbのBOT_API_KEYに設定するようになっています。

APIキーの初期値にはsamplaが設定されています。
sampleは試用キーで１時間に10回だけAPIコールが可能なキーになります。
制限なしに使用したい場合はUserLocalさんに冒頭のリンクからAPIの使用申請を行ってください。

### rails
railsのバージョンは4.2.1で、rspec、scss、jquery、bootswatch、factorygirl、databasecleanerなどを使用しています。
vender以下は含まれていませんので、実行前にはbundle installを実施ください。

### ライセンス
ライセンスはMITです。
