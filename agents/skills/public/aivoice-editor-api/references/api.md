# A.I.VOICE Editor API リファレンス（要点）

## 概要
- 名前空間: `AI.Talk.Editor.Api`
- アセンブリ: `AI.Talk.Editor.Api.dll`
- 主な操作クラス: `TtsControl`
- 目的: A.I.VOICE Editor を外部プログラムから操作する。

## TtsControl の基本
- インスタンス作成後に `Initialize(serviceName)` を呼び出して API を初期化する。
- `GetAvailableHostNames()` で接続可能なサービス名の一覧を取得する。
- `StartHost()` でホストプログラムを起動できる。
- `Connect()` でホストに接続する。
  - 接続後、10分間 API 操作がないと自動的に接続解除される。

## キャラクター/ボイス系プロパティ
- `VoicePresetNames: string[]`
  - 登録されているボイスプリセット名を取得する。標準プリセットとユーザープリセットが含まれる。
- `CurrentVoicePresetName: string`
  - 現在のボイスプリセット名を取得/設定する。
- `VoiceNames: string[]`
  - 利用可能なボイス名を取得する。

## 接続関連
- `Initialize(serviceName: string)`
  - API を初期化する。最初に必ず呼ぶ。
  - 接続可能な `serviceName` は `GetAvailableHostNames()` で取得する。
- `GetAvailableHostNames(): string[]`
  - 利用可能なホスト名の一覧を返す。
- `StartHost()`
  - ホストプログラムを起動する。
- `Connect()`
  - ホストプログラムと接続する。
  - 10 分間 API 操作がないと自動切断される。
- `Disconnect()`
  - ホストとの接続を解除する。

## 辞書関連
- `ReloadWordDictionary()`
  - 単語辞書を再読込みする。
