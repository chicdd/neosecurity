배포할 때 Firebase 앱 푸시가 오기 위해서는 ios/Runner 폴더 내에 console.firebase.google.com 에서 만든 GoogleService-Info.plist 가 있어야 하지만 
개발환경이 현재 com.neo.hansesecurity, com.neo.Takra.. 등 여러개이므로 설정이 달라짐.


GoogleService-Info.plist를 ios 폴더 내 Firebase 폴더를 만들고 각 개발환경 이름의 폴더를 추가로 만들었다.
그 안에 각 개발환경에 맞는 GoogleService-Info.plist 를 넣고

xcode에서 ios/Runner.xcworkspace 를 열어
Runner => BuildPhases 설정에 들어가 Setup Firebase Config 라는 Phase를 만들었다.

각 개발환경에 맞는 config를 선언하고 해당 개발환경일 때의 조건을 if문으로 추가하면 문제없이 푸시가 들어온다. 푸시 테스트 완료.

아래는 readme.md를 작성할 때 상태의 전문
# ======================================================================================
# 환경별 GoogleService-Info.plist 경로 설정
HANSESECURITY_CONFIG="${PROJECT_DIR}/Firebase/Hansesecurity/GoogleService-Info.plist"
TAKRA_CONFIG="${PROJECT_DIR}/Firebase/Takra/GoogleService-Info.plist"

# 현재 빌드되는 Bundle Identifier 확인
BUNDLE_ID=$PRODUCT_BUNDLE_IDENTIFIER

# 목적지 경로 (Runner의 루트)
DESTINATION="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ "$BUNDLE_ID" == "com.neo.hansesecurity" ]; then
echo "Using Hansesecurity Firebase Config"
cp "${HANSESECURITY_CONFIG}" "${DESTINATION}"
elif [ "$BUNDLE_ID" == "com.neo.Takra" ]; then
echo "Using Takra Firebase Config"
cp "${TAKRA_CONFIG}" "${DESTINATION}"
else
echo "No matching Firebase config for Bundle ID: $BUNDLE_ID"
fi
# ======================================================================================