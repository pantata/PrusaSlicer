#!/usr/bin/env bash
set -euo pipefail

# === upravitelné proměnné ===
EXEC="build/src/PrusaSlicer"
APPNAME="PrusaSlicer"            # výsledný bundle bude PrusaSlicer.app
ICON="resources/icons/PrusaSlicer.icns"  # volitelně
RES_DIR="resources"   # zdrojová resources (icons, splash, translations...)
OUT_DIR="$(pwd)"                 # výstupní adresář pro .app

# === příprava bundle ===
rm -rf "${OUT_DIR}/${APPNAME}.app"
mkdir -p "${OUT_DIR}/${APPNAME}.app/Contents/"{MacOS,Resources,Frameworks}

if [ ! -f "$EXEC" ]; then
  echo "Executable not found: $EXEC"
  exit 1
fi

cp "$EXEC" "${OUT_DIR}/${APPNAME}.app/Contents/MacOS/PrusaSlicer"
chmod +x "${OUT_DIR}/${APPNAME}.app/Contents/MacOS/PrusaSlicer"

ID_LOWER=$(echo "${APPNAME}" | tr '[:upper:]' '[:lower:]')

# Vytvoření Info.plist
cat > "${OUT_DIR}/${APPNAME}.app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>        <string>PrusaSlicer</string>
  <key>CFBundleDisplayName</key> <string>PrusaSlicer</string>
  <key>CFBundleExecutable</key>  <string>PrusaSlicer</string>
  <key>CFBundleIdentifier</key>  <string>com.local.prusaslicer</string>
  <key>CFBundleVersion</key>     <string>0.1</string>
  <key>CFBundleShortVersionString</key><string>0.1</string>
  <key>CFBundleIconFile</key>    <string>PrusaSlicer.icns</string>
  <key>LSMinimumSystemVersion</key><string>10.14</string>

  <!-- Registrace URL schématu pro přihlášení z webu / Printables. -->
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>
      <string>PrusaSlicer URL</string>
      <key>CFBundleTypeRole</key>
      <string>Viewer</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>prusaslicer</string>
      </array>
    </dict>
  </array>

  <!-- Registrace podporovaných souborů. -->
  <key>CFBundleDocumentTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeName</key>
      <string>3MF Document</string>
      <key>CFBundleTypeExtensions</key>
      <array>
        <string>3mf</string>
      </array>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>LSHandlerRank</key>
      <string>Owner</string>
    </dict>
    <dict>
      <key>CFBundleTypeName</key>
      <string>STL Document</string>
      <key>CFBundleTypeExtensions</key>
      <array>
        <string>stl</string>
        <string>STL</string>
      </array>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>LSHandlerRank</key>
      <string>Alternate</string>
    </dict>
    <dict>
      <key>CFBundleTypeName</key>
      <string>OBJ Document</string>
      <key>CFBundleTypeExtensions</key>
      <array>
        <string>obj</string>
        <string>OBJ</string>
      </array>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>LSHandlerRank</key>
      <string>Alternate</string>
    </dict>
    <dict>
      <key>CFBundleTypeName</key>
      <string>STEP Document</string>
      <key>CFBundleTypeExtensions</key>
      <array>
        <string>stp</string>
        <string>step</string>
      </array>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>LSHandlerRank</key>
      <string>Alternate</string>
    </dict>
  </array>
</dict>
</plist>
PLIST

# zkopíruj ikonku (pokud existuje)
if [ -f "$ICON" ]; then
  cp "$ICON" "${OUT_DIR}/${APPNAME}.app/Contents/Resources/"
fi

# zkopíruj celou resources složku (ikony, splash, translations, atd.)
if [ -d "$RES_DIR" ]; then
  echo "Copying resources from $RES_DIR into app bundle..."
  cp -a "$RES_DIR/." "${OUT_DIR}/${APPNAME}.app/Contents/Resources/" || true
fi

# přidej rpath (bez externích .dylib to nevadí)
install_name_tool -add_rpath @executable_path/../Frameworks "${OUT_DIR}/${APPNAME}.app/Contents/MacOS/PrusaSlicer" 2>/dev/null || true

echo "Dependencies (otool -L):"
otool -L "${OUT_DIR}/${APPNAME}.app/Contents/MacOS/PrusaSlicer" || true

echo "Done: ${OUT_DIR}/${APPNAME}.app"
