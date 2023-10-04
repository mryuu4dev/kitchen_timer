# 無料のキッチンタイマー

シンプルでわかりやすい無料のキッチンタイマーです. バイブレーションと音でお知らせします.

## リリース
1. `jks`ファイルを作成する
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. `android/key.properties`を下記のように作成する

```
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=<location of the key store file, such as C:/Users/b1018/upload-keystore.jks>
```

3. appbundleファイルのビルドを実行する
```bash
flutter build appbundle
```
