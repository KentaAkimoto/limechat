# LimeChat 独自拡張版

* LimeChat(https://github.com/psychs/limechat) に独自の機能拡張したもの
* ver 2.39 がベース

## 主な追加機能
* ニコニコ大百科/ネットスラング検索機能
* スナップショット機能(powered by Gyazo:https://github.com/gyazo/)
* スピーチ機能
* アバター表示機能(ローカル画像ファイル)
* アバター収集機能(収集スクリプトの入力となるwhois結果のテキストファイルを出力する)

## 追加機能の使い方
* ニコニコ大百科/ネットスラング検索機能
    * -> 検索したいキーワードを選択状態で右クリック.メニューからSearch...を選択
* スナップショット機能(powered by Gyazo:https://github.com/gyazo/)
    * -> Preference>Advanced>Snapshotにてデバイスを選択する
    * -> 画面中央で右クリック(メインメニュー) > Turn on Snapshot
    * -> メッセージを入力
    * -> スクリーンキャプチャにしたい場合はメッセージの末尾に">>"を付ける
    * -> マウスカーソルが+マークに変わるので、撮りたい範囲を指定する
    * -> アップした画像をサーバから削除したい場合は、一旦Gyazoアプリで一度アップすれば以降できるようになる
    * -> GyazoはCGIも公開しているので、任意のサーバに移植するのも簡単にできそう
 
* スピーチ機能
    * -> macの設定>音声入力と読み上げ>システムの声>カスタマイズ から事前にスピーチさせたいvoiceをダウンロードしておく
    * -> 日本語の場合は、KyokoかOtoyaのみ
    * -> Preference>Advanced>voiceから選択
    * -> 画面中央で右クリック(メインメニュー) > Turn on Speech
    * -> メッセージを入力
    * -> 日本語以外のvoiceを選択した場合でも、内部的にローマ字変換して渡しているので、それっぽく発言してくれるはず…
 
* アバター表示機能(ローカル画像ファイル)
    * -> Server Properties>CTCP UserInfo に showAvatar と入力
    * -> /Users/Shared/limeChat フォルダ配下に、nick=realname.png の形式のファイルがある場合、nickが前方一致したものを表示する
* アバター収集機能(任意のスクリプトを実行)
    * -> limechatにて、対象のチャンネルにjoinする
    * -> 画面中央で右クリック(メインメニュー) > Output Whois
    * -> 収集スクリプト用の入力となるwhois結果のテキストファイルを /Users/Shared/limeChat の配下に出力する
    * -> 既にアバター画像が/Users/Shared/limeChatに存在している場合は、テキストファイルに出力されないので注意
    * -> 収集スクリプトは、独自に作ってください…

LimeChat is an IRC client for Mac OS X.

* One window for multiple servers.
* Rich keyboard shortcuts for your comfortable operations.
* Fast and stable.

## Author

* Kenta Akimoto

## Thanks To

* Allan Odgaard  (WebViewAutoScroll and TextMate logo)
* Atsuhisa Shimazawa  (Badge images)
* Dustin Voss  (AsyncSocket)
* Eloy Duran  (RubyCocoa, crash reporter, Growl notifier, preferences patches)
* Evan Phoenix  (Inline images support)
* Fujimoto Hisa  (RubyCocoa)
* Josh Goebel  (CocoaSheet, many improvements on code and UIs)
* Jun Morimoto  (Bug fixes)
* Keiji Yoshimi  (Growl notifier patches, hot key patches)
* Kevin Ballard  (Theme support patches)
* Laurent Sansonetti  (RubyCocoa, many requests and suggestions)
* Peter Haza  (Channel name context menu patch)
* Python Software Foundation  (Python logo)
* Rails team  (Ruby on Rails logo)
* Shingo Morita  (Badge images)
* Stanley Rost  (Limelight theme)
* Stefan Rusterholz  (Many suggestions and patches)
* Takashi Tsugo  (Deep Ocean theme)
* The Growl Project  (Growl framework and logo)
* why the lucky stiff  (Syck)
* William Thimbleby  (Syck Cocoa)
* Yohei Endo  (Application icons)
* Yukihiro Matsumoto  (Ruby logo)

## License

LimeChat is copyrighted free software by Satoshi Nakagawa (psychs AT limechat DOT net).
You can redistribute it and/or modify it under the terms of [the GPL version 2](https://github.com/psychs/limechat/blob/master/GPL.txt).
