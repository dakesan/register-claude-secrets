# register-claude-secrets

Claude CodeのOAuth認証情報をGitHub Secretsに自動登録するツール

## 概要

このツールは、Claude Codeの認証情報（`~/.claude/.credentials.json`）を読み取り、GitHub ActionsでClaude Codeを使用するために必要なシークレットを自動的に登録します。

参考記事: [Claude Codeによるbotで無限の時間を手に入れる](https://qiita.com/akira_funakoshi/items/e101a4e3ac9844e7b313)

## 必要な環境

- `gh` (GitHub CLI) - [インストール方法](https://cli.github.com/)
- `jq` - JSONパーサー
  - Ubuntu/Debian: `sudo apt-get install jq`
  - macOS: `brew install jq`
- Claude Code - 事前にOAuth認証を完了していること

## インストール

### 方法1: インストールスクリプトを使用（推奨）

```bash
git clone git@github.com:dakesan/register-claude-secrets.git
cd register-claude-secrets
./install.sh
```

インストールスクリプトは自動的に `~/.local/bin` にコマンドをインストールします。

### 方法2: 手動インストール

```bash
git clone git@github.com:dakesan/register-claude-secrets.git
cd register-claude-secrets
chmod +x register-claude-secrets.sh
cp register-claude-secrets.sh ~/.local/bin/register-claude-secrets
```

## 使用方法

### 事前準備

1. Claude Codeをインストールし、`claude` コマンドでOAuth認証を完了する
2. GitHub CLIで認証を完了する: `gh auth login`

### 実行

```bash
register-claude-secrets -r owner/repository
```

例:
```bash
register-claude-secrets -r myusername/myproject
```

カスタムのcredentials.jsonファイルを指定する場合:
```bash
register-claude-secrets -r owner/repository -f /path/to/credentials.json
```

## 登録されるシークレット

以下の3つのシークレットがGitHubリポジトリに登録されます：

- `CLAUDE_ACCESS_TOKEN` - アクセストークン
- `CLAUDE_REFRESH_TOKEN` - リフレッシュトークン
- `CLAUDE_EXPIRES_AT` - トークンの有効期限

## GitHub Actionsでの使用例

```yaml
name: Claude Code Bot

on:
  issues:
    types: [opened, edited]
  issue_comment:
    types: [created]

jobs:
  claude-code:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Claude Code
        env:
          CLAUDE_ACCESS_TOKEN: ${{ secrets.CLAUDE_ACCESS_TOKEN }}
          CLAUDE_REFRESH_TOKEN: ${{ secrets.CLAUDE_REFRESH_TOKEN }}
          CLAUDE_EXPIRES_AT: ${{ secrets.CLAUDE_EXPIRES_AT }}
        run: |
          # Claude Codeを使用した処理
```

## 注意事項

- トークンには有効期限があります。期限切れの場合は、`claude` コマンドで再認証後、このツールを再実行してください
- シークレットの確認: `gh secret list --repo owner/repository`

## ライセンス

MIT License