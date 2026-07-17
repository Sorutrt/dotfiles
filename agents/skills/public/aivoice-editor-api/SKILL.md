---
name: aivoice-editor-api
description: A.I.VOICE Editor API (AI.Talk.Editor.Api.dll / TtsControl) を扱うスキル。Node.js/TypeScript での連携、起動時の Initialize/Connect/StartHost、ボイス/ボイスプリセット一覧取得や切り替え、接続維持や再接続が必要なときに使う。
---

# A.I.VOICE Editor API

## 目的
A.I.VOICE Editor API を安全に使うための実装手順を示す。

## 参照
- `references/api.md` を最初に読む。

## 起動時の接続フロー
1. `GetAvailableHostNames()` で `serviceName` 候補を取得する。
2. `Initialize(serviceName)` を 1 回だけ呼ぶ。
3. 必要に応じて `StartHost()` でホストを起動する。
4. `Connect()` で接続する。
5. 一定時間操作がないと切断されるため、必要に応じて再接続する。

## キャラクター/ボイス切り替え
- `VoicePresetNames` を列挙して候補を確認する。
- `CurrentVoicePresetName` を設定して切り替える。
- プリセットがない場合は `VoiceNames` を利用してボイス名の候補を提示する。

## Node.js/TypeScript 連携の指針
- .NET クラスライブラリのため、直接呼び出せない場合は C# の薄いラッパーを用意してプロセス間通信で操作する。
- 接続や再接続は失敗前提で扱い、明確なエラーメッセージと再試行の導線を用意する。
