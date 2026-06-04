# Social Auth Setup

Ce projet est maintenant prepare cote code pour `Google Sign-In` et `Sign in with Apple`.

Les etapes ci-dessous restent obligatoires hors du code pour que les deux providers fonctionnent reellement.

## Google Sign-In

### Firebase Console

1. Ouvrir `Firebase Console > Authentication > Sign-in method`.
2. Activer `Google`.

### Android

1. Ouvrir `Firebase Console > Project settings > Your apps > Android app`.
2. Ajouter la `SHA-1` puis idealement la `SHA-256` de la machine qui build l'application.
3. Regenerer `google-services.json`.
4. Remplacer `android/app/google-services.json` par la nouvelle version.

Sans cette etape, `google_sign_in` peut echouer meme si le code est bon.

### iOS

1. Ajouter une application iOS dans Firebase avec le bundle id utilise par Xcode :
   `com.example.codeRouteFlutter`
2. Telecharger `GoogleService-Info.plist`.
3. Ajouter ce fichier dans `ios/Runner/`.
4. Dans ce fichier, recuperer la valeur `REVERSED_CLIENT_ID`.
5. Ajouter cette valeur dans `Info.plist` sous `CFBundleURLTypes`.

Le projet contient deja un `GoogleService-Info.plist` genere a partir de la configuration Firebase existante. Si l'app Firebase iOS est modifiee, il faut retélécharger ce fichier depuis Firebase Console et remplacer `ios/Runner/GoogleService-Info.plist`.

## Sign in with Apple

### Firebase Console

1. Ouvrir `Firebase Console > Authentication > Sign-in method`.
2. Activer `Apple`.
3. Fournir les informations Apple demandees :
   - `Service ID`
   - `Apple Team ID`
   - `Key ID`
   - la cle privee `.p8`

### Apple Developer

1. Activer le capability `Sign in with Apple` pour l'application iOS.
2. Creer/configurer le `Service ID` utilise par Firebase.
3. Creer une `Sign in with Apple key`.

## Ce qui est deja fait dans le projet

- dependances Flutter ajoutees :
  - `google_sign_in`
  - `sign_in_with_apple`
- boutons Google / Apple branches dans l'ecran de connexion
- persistance locale et creation de profil Firestore gerees apres auth sociale
- entitlement iOS Apple Sign-In ajoute :
  - `ios/Runner/Runner.entitlements`
- configuration Google Sign-In web ajoutee dans `web/index.html`
- configuration Google Sign-In iOS ajoutee dans `ios/Runner/Info.plist`
- `GoogleService-Info.plist` iOS ajoute et inclus dans la cible Xcode Runner

## Test conseille

1. `flutter pub get`
2. relancer Android pour tester Google
3. tester sur web avec une origine autorisee dans Google Cloud/Firebase
4. tester sur iPhone pour Google + Apple
