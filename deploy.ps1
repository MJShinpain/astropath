# Flutter 웹 빌드
flutter build web --release --base-href "/astropath/"

# build/web의 내용을 docs로 복사
if (Test-Path docs) {
    Remove-Item -Recurse -Force docs
}
New-Item -ItemType Directory -Force -Path docs
Copy-Item -Path "build/web/*" -Destination "docs" -Recurse

# GitHub에 변경사항 푸시
git add docs
git commit -m "Update GitHub Pages"
git push origin main