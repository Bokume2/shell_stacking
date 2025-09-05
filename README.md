# shell stacking
C3 Summer Creatathon 2025の作品です。「シェルスクリプトで言語処理系を書く」というコンセプトの下に制作しました。  
  
スタックベースの言語で、各命令が1文字のよくある難解プログラミング言語です。

## Requirements
このスクリプトはBashでの動作を想定しています。  

動作確認済みのバージョン:
  - GNU bash 5.2.21(1)-release (x86_64-pc-linux-gnu)

## Installation
[スクリプト本体](./shell_stacking.sh)を任意の場所に配置して下さい。  
例えば、curlがインストール済みの環境であれば、以下のコマンドでスクリプトのダウンロードを行うことが可能です。
```bash
curl -fsSO https://raw.githubusercontent.com/Bokume2/shell_stacking/main/shell_stacking.sh
```
サンプルコードまでまとめて入手したい場合は、`git clone`等でリポジトリ全体をダウンロードして下さい。
```bash
git clone https://github.com/Bokume2/shell_stacking.git
```

## Usage
ソースコードをファイルに記述した場合、以下のようにソースファイルのパスを渡してスクリプトを実行します。
```bash
./shell_stacking.sh <source file>
```
`-e`オプションにより、ソースコードをコマンドライン引数にそのまま渡すこともできます(この場合、追加でファイルパスを渡しても無視されます)。
```bash
./shell_stacking.sh -e <code>
```

## Syntax
ドキュメントの整備予定は未定です。処理系から読み解くか、作者に直接聞いたりドキュメントの整備を急かしたりして下さい。

## Samples
- [hello.shstack](samples/hello.shstack)  
  いわゆるHello Worldです。実行すると`Hello, shell script world!`が改行付きで出力されます。
- [fizzbuzz.shstack](samples/fizzbuzz.shstack)  
  最初に入力した数までのFizzBuzzを出力します。0以下を入力すると何も出力しません。

## Licence
このソフトウェアは[Unlicenseライセンス](https://unlicense.org)の下に配布されています。  
営利・非営利問わず、特段の許諾や表示なしに使用や複製、再配布を行って構いません。  
詳しくは[ライセンス表示](./UNLICENSE)または[https://unlicense.org](https://unlicense.org)を参照して下さい。

## Contact
バグ報告や言語機能の提案などは[Twitter(現X)](https://x.com/boku_renraku)等でお声掛け下さい。
