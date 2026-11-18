# Como instalar e publicar o CicloLivre (Android)

## 1. Instalar o APK gerado

Arquivo: `app-debug.apk` (APK de debug, assinado com a chave de debug do Android — serve para testes
e uso pessoal, não para publicar na Play Store).

1. Copie `app-debug.apk` para o celular Android (cabo USB, Google Drive, WhatsApp para você mesmo…).
2. Abra o arquivo no celular.
3. O Android vai pedir para permitir "instalar apps desconhecidos" para o app usado (Arquivos,
   Chrome etc.). Autorize.
4. Toque em **Instalar** e abra o **CicloLivre**.

> Se aparecer "app não instalado" ao atualizar: desinstale a versão anterior e instale de novo
> (o APK de debug só atualiza se for assinado com a mesma chave).

## 2. Recompilar depois de mudanças

```powershell
npm run build
npx cap sync android
cd android
.\gradlew.bat assembleDebug
```

O APK fica em `android/app/build/outputs/apk/debug/app-debug.apk`.

## 3. Gerar APK/AAB de release (para publicar)

1. Criar a chave de assinatura (guarde o arquivo `.jks` e as senhas):

```powershell
keytool -genkey -v -keystore ciclolivre-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ciclolivre
```

2. Criar `android/keystore.properties` (não versione este arquivo):

```properties
storeFile=../ciclolivre-release.jks
storePassword=SUA_SENHA
keyAlias=ciclolivre
keyPassword=SUA_SENHA
```

3. Em `android/app/build.gradle`, antes de `android { ... }`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('keystore.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

E dentro do bloco `android`, antes de `buildTypes`:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
    }
}
```

E no `buildTypes.release`, adicione `signingConfig signingConfigs.release`.

4. Gerar os pacotes:

```powershell
cd android
.\gradlew.bat assembleRelease   # APK
.\gradlew.bat bundleRelease     # AAB (Play Store)
```

Saída: `android/app/build/outputs/apk/release/app-release.apk` e
`android/app/build/outputs/bundle/release/app-release.aab`.

## 4. Publicar na Google Play

1. Crie uma conta de desenvolvedor em <https://play.google.com/console> (taxa única).
2. **Criar app** → nome "CicloLivre", idioma padrão Português (Brasil), tipo "App", gratuita.
3. Preencha: descrição, ícone 512×512 px, imagem de destaque 1024×500 px, 2+ capturas de tela.
4. **Política de privacidade** (obrigatória): publique um texto informando que os dados ficam
   apenas no dispositivo e que não há coleta/envio de informações. Pode ser uma página simples no
   GitHub Pages.
5. **Classificação de conteúdo** e **Segurança dos dados**: informe que o app não coleta nem
   compartilha dados do usuário (marcar "Nenhum dado coletado").
6. Envie o `app-release.aab` em **Produção → Criar nova versão**.
7. Para apps de saúde, o formulário pede declarações extras; o CicloLivre não é dispositivo médico
   e não faz diagnóstico — declare isso na descrição.

## 5. Alternativa: distribuir sem a Play Store

- Envie o `app-release.apk` por link direto (Drive, site próprio). O usuário precisa autorizar
  "instalar de fontes desconhecidas".
- Para uso familiar, o APK de debug já resolve.

## 6. Checklist de privacidade

- Sem backend, sem login, sem analytics: todos os dados em `localStorage` do WebView.
- O app pede apenas a permissão `INTERNET` (exigida pelo WebView), não acessa contatos, localização,
  câmera ou arquivos.
- Desinstalar o app apaga todos os registros.
