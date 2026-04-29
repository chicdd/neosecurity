고객용 원격 경계 앱

Android
\android\app\build.gradle.kts 에서 개발환경(flavor)를 설정함.

IOS
\ios\Flutter\Configs 폴더 내 Debug, Release xcconfig 파일안에 빌드 설정을 함.

개발환경에 따라 개통코드를 다르게 빌드하여 협력사가 다르더라도 한 애플리케이션으로 동일버전으로 관리되도록 설계함.

Firebase 사용.
인증번호 인증 후 메인화면에 진입할 때 토큰값을 받음.