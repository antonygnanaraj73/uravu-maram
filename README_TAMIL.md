# உறவு மரம் — Android app source code

இது Flutter அடிப்படையிலான தமிழ் குடும்ப உறுப்பினர் பதிவேடு. இந்த ஆரம்ப source code-ல்:
- குடும்ப உறுப்பினரைச் சேர்த்தல் / திருத்துதல் / நீக்குதல்
- பெயர் தேடல்
- பாலினம், பிறந்த தேதி, தொலைபேசி, குறிப்புகள்
- தந்தை, தாய், கணவன்/மனைவி இணைப்புகள்
- கிடைக்கும் இணைப்புகளின் அடிப்படையில் அடிப்படை உறவு காட்சி
- தகவல்களை அதே மொபைலில் சேமித்தல் (`shared_preferences`)

## முக்கிய வரம்பு
இந்த பதிப்பு Firebase/Cloud sync இல்லாத local prototype. குடும்பத் தகவல் இந்த Android சாதனத்தில் மட்டும் சேமிக்கப்படும். App data அழிக்கப்பட்டால் தகவல் இழக்கலாம். பல மொபைல்களில் ஒரே குடும்பத் தரவைப் பகிர Firebase Authentication + Cloud Firestore மற்றும் backup/export வசதி அடுத்த கட்டத்தில் சேர்க்க வேண்டும். உறவுமுறை கணக்கீடு தற்போது அடிப்படை மட்டுமே; பெரியப்பா/சித்தப்பா/மாமா/அத்தை போன்ற விரிவான தமிழ் உறவுமுறை விதிகள் இன்னும் முழுமையாகச் சேர்க்கப்படவில்லை.

## Android APK உருவாக்குவது
1. கணினியில் Flutter SDK மற்றும் Android Studio நிறுவவும்.
2. Terminal/Command Prompt திறந்து இந்த project folder-க்கு செல்லவும்.
3. `flutter pub get`
4. `flutter run` (USB debugging இயங்கும் Android phone-ஐ இணைத்திருந்தால்)
5. APK உருவாக்க: `flutter build apk --release`
6. APK பொதுவாக `build/app/outputs/flutter-apk/app-release.apk` இல் கிடைக்கும்.

## Flutter project உருவாக்கும் மாற்று வழி
Flutter platform scaffolding இல்லாத சூழலில்:
1. `flutter create uravu_maram`
2. உருவான project-இன் `pubspec.yaml`-ஐ இந்த ZIP-இல் உள்ள `pubspec.yaml` கொண்டு மாற்றவும்.
3. `lib/main.dart`-ஐ இந்த ZIP-இல் உள்ள `lib/main.dart` கொண்டு மாற்றவும்.
4. `flutter pub get` மற்றும் `flutter run` இயக்கவும்.

## தரவு மாதிரி
ஒவ்வொரு நபருக்கும் `id`, `name`, `gender`, `birthDate`, `fatherId`, `motherId`, `spouseId`, `phone`, `notes` fields உள்ளன.
