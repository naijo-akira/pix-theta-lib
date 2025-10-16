#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PUBSPEC="${PKG_DIR}/pubspec.yaml"

# --- 必要ファイル/フォルダ（存在するものだけ含める） ---
INCLUDE_FILES=( "pubspec.yaml" "README.md" "CHANGELOG.md" "LICENSE" )
INCLUDE_DIRS=( "lib" )

# --- 前提チェック ---
if [[ ! -f "${PUBSPEC}" ]]; then
    echo "❌ pubspec.yaml が見つかりません: ${PUBSPEC}"
    exit 1
fi

# --- パッケージ名を pubspec.yaml から取得 ---
PACKAGE_NAME="$(
  awk -F': *' '/^name:[[:space:]]*/ { print $2; exit }' "${PUBSPEC}" | tr -d '\r'
)"
if [[ -z "${PACKAGE_NAME}" ]]; then
    echo "❌ pubspec.yaml からパッケージ名(name)を取得できませんでした"
    exit 1
fi

# --- 一時作業フォルダ用意（中のトップフォルダ名はパッケージ名）---
TMP_DIR="$(mktemp -d)"
STAGE_DIR="${TMP_DIR}/${PACKAGE_NAME}"
mkdir -p "${STAGE_DIR}"

echo "📦 一時ステージング: ${STAGE_DIR}"

# --- ファイル類をコピー（存在チェック付き）---
for f in "${INCLUDE_FILES[@]}"; do
    if [[ -f "${PKG_DIR}/${f}" ]]; then
        cp "${PKG_DIR}/${f}" "${STAGE_DIR}/"
    fi
done

# --- ディレクトリ類をコピー（存在チェック付き）---
for d in "${INCLUDE_DIRS[@]}"; do
    if [[ -d "${PKG_DIR}/${d}" ]]; then
        mkdir -p "${STAGE_DIR}/${d}"
        # lib が空でもエラーにならないように
        cp -R "${PKG_DIR}/${d}/"* "${STAGE_DIR}/${d}/" 2>/dev/null || true
    fi
done

# --- ZIP作成（出力先はパッケージ直下、ファイル名はパッケージ名.zip）---
ZIP_PATH="${PKG_DIR}/dist/${PACKAGE_NAME}.zip"
(
    cd "${TMP_DIR}"
    zip -r "${ZIP_PATH}" . >/dev/null
)

echo "✅ 作成完了: ${ZIP_PATH}"

# --- 後始末 ---
rm -rf "${TMP_DIR}"
