# மொபைல் மட்டும் கொண்டு APK உருவாக்குவது

இந்த project-இல் `.github/workflows/build-apk.yml` சேர்க்கப்பட்டுள்ளது. இது GitHub Actions மூலம் cloud-ல் APK உருவாக்க உதவும். கணினி தேவையில்லை; ஆனால் GitHub account-இல் சில படிகளை நீங்கள் மொபைல் browser-ல் செய்ய வேண்டும்.

## எளிய வழி
1. GitHub-ல் sign in செய்யவும்: https://github.com
2. `+` → `New repository` அழுத்தவும்.
3. Repository name: `uravu-maram` எனக் கொடுத்து `Public` அல்லது `Private` தேர்ந்தெடுத்து `Create repository` அழுத்தவும்.
4. மொபைல் browser-ல் ZIP-ஐத் திறந்து project files-ஐ extract செய்யக்கூடிய file manager app பயன்படுத்தவும். `lib`, `pubspec.yaml`, `test`, `.github` ஆகியவற்றை repository-க்கு upload செய்ய வேண்டும். `.github/workflows/build-apk.yml` என்ற path அப்படியே இருக்க வேண்டும்.
5. GitHub repository-இல் `Actions` tab-ஐத் திறந்து `Build Uravu Maram APK` workflow தேர்வு செய்து `Run workflow` அழுத்தவும். `Actions` tab தானாக workflow-ஐக் காட்டவில்லை என்றால், முதலில் `main` branch-க்கு files upload செய்யப்பட்டுள்ளதா எனச் சரிபார்க்கவும்.
6. Build முடிந்து பச்சை check mark வந்ததும் அந்த run-ஐத் திறக்கவும். கீழே `Artifacts` பகுதியில் `uravu-maram-apk` அழுத்தி APK ZIP-ஐப் பதிவிறக்கவும்.
7. பதிவிறங்கிய ZIP-ஐ extract செய்து `app-release.apk` திறந்து install செய்யவும். Android கேட்டால் அந்த browser/file manager-க்கு “Install unknown apps” அனுமதி கொடுக்கவும்.

## முக்கியம்
- இந்த build சோதனைக்கான APK; Google Play Store-ல் வெளியிடுவதற்கான signed release அமைப்பு இன்னும் செய்யப்படவில்லை.
- இப்போதைய app குடும்பத் தகவல்களை இந்த மொபைலில் மட்டும் சேமிக்கும். Firebase/cloud sync இல்லை.
- GitHub Actions build தோல்வியடைந்தால், Actions run-இல் உள்ள சிவப்பு error விவரத்தை screenshot எடுத்து உதவிக்கு அனுப்பவும்.
