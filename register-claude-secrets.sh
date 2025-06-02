#!/bin/bash

# Claude OAuthクレデンシャルをGitHub Secretsに登録するスクリプト

# 使用方法を表示
usage() {
    echo "Usage: $0 -r <repository> [-f <credentials-file>]"
    echo "  -r: GitHub repository (format: owner/repo)"
    echo "  -f: Path to credentials.json file (default: ~/.claude/.credentials.json)"
    echo ""
    echo "Example: $0 -r myuser/myrepo"
    echo ""
    echo "Note: You must run 'claude' command and complete OAuth login before using this script"
    exit 1
}

# デフォルト値
CREDS_FILE="$HOME/.claude/.credentials.json"

# オプション解析
while getopts "r:f:h" opt; do
    case $opt in
        r) REPO="$OPTARG";;
        f) CREDS_FILE="$OPTARG";;
        h) usage;;
        *) usage;;
    esac
done

# 必須パラメータチェック
if [ -z "$REPO" ]; then
    echo "Error: Repository is required"
    usage
fi

# ghコマンドの存在確認
if ! command -v gh &> /dev/null; then
    echo "Error: gh command not found. Please install GitHub CLI first."
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# GitHub CLIの認証確認
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

# credentials.jsonファイルの確認
if [ ! -f "$CREDS_FILE" ]; then
    echo "Error: Credentials file not found: $CREDS_FILE"
    echo ""
    echo "Please run 'claude' command first to complete OAuth authentication."
    echo "This will create the credentials file automatically."
    exit 1
fi

# jqコマンドの確認
if ! command -v jq &> /dev/null; then
    echo "Error: jq command not found. Please install jq first."
    echo "  - Ubuntu/Debian: sudo apt-get install jq"
    echo "  - macOS: brew install jq"
    exit 1
fi

echo "Reading credentials from: $CREDS_FILE"

# credentials.jsonから値を読み取る
ACCESS_TOKEN=$(jq -r '.access_token' "$CREDS_FILE" 2>/dev/null)
REFRESH_TOKEN=$(jq -r '.refresh_token' "$CREDS_FILE" 2>/dev/null)
EXPIRES_AT=$(jq -r '.expires_at' "$CREDS_FILE" 2>/dev/null)

# 値の検証
if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" = "null" ]; then
    echo "Error: Could not read access_token from credentials file"
    exit 1
fi

if [ -z "$REFRESH_TOKEN" ] || [ "$REFRESH_TOKEN" = "null" ]; then
    echo "Error: Could not read refresh_token from credentials file"
    exit 1
fi

if [ -z "$EXPIRES_AT" ] || [ "$EXPIRES_AT" = "null" ]; then
    echo "Error: Could not read expires_at from credentials file"
    exit 1
fi

echo ""
echo "Registering Claude OAuth credentials for repository: $REPO"
echo ""

# Access TokenをGitHub Secretとして登録
echo -n "Setting CLAUDE_ACCESS_TOKEN... "
if echo "$ACCESS_TOKEN" | gh secret set CLAUDE_ACCESS_TOKEN --repo "$REPO" -; then
    echo "✓ Success"
else
    echo "✗ Failed"
    exit 1
fi

# Refresh TokenをGitHub Secretとして登録
echo -n "Setting CLAUDE_REFRESH_TOKEN... "
if echo "$REFRESH_TOKEN" | gh secret set CLAUDE_REFRESH_TOKEN --repo "$REPO" -; then
    echo "✓ Success"
else
    echo "✗ Failed"
    exit 1
fi

# Expires AtをGitHub Secretとして登録
echo -n "Setting CLAUDE_EXPIRES_AT... "
if echo "$EXPIRES_AT" | gh secret set CLAUDE_EXPIRES_AT --repo "$REPO" -; then
    echo "✓ Success"
else
    echo "✗ Failed"
    exit 1
fi

echo ""
echo "✅ Claude OAuth credentials have been successfully registered!"
echo ""
echo "You can now use these secrets in your GitHub Actions:"
echo "  - \${{ secrets.CLAUDE_ACCESS_TOKEN }}"
echo "  - \${{ secrets.CLAUDE_REFRESH_TOKEN }}"
echo "  - \${{ secrets.CLAUDE_EXPIRES_AT }}"
echo ""
echo "To verify secrets, run: gh secret list --repo $REPO"
echo ""
echo "Note: These credentials will need to be updated when they expire."
echo "Run this script again after refreshing your Claude authentication."