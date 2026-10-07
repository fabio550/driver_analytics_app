# Configurar a Cloud Vision API (OCR em nuvem com fallback pro ML Kit)

A importação de corridas por print usa o Google Cloud Vision como motor
de OCR principal (mais preciso que o ML Kit on-device, mas exige
internet) e cai automaticamente pro ML Kit (offline) se a Cloud Vision
falhar por qualquer motivo — sem conexão, timeout, erro de servidor.

**Isso é opcional.** Sem a chave configurada, o app funciona exatamente
como antes, só com o ML Kit. Esse passo a passo só é necessário se você
quiser habilitar a Cloud Vision.

A chave de API fica **restrita** pra só funcionar a partir deste app
Android especificamente (nome do pacote + assinatura/SHA-1) — ela nunca
é commitada no repositório nem embutida direto no código-fonte.

## 1. Criar o projeto no Google Cloud

1. Acesse [console.cloud.google.com](https://console.cloud.google.com/)
   e crie um projeto novo (ou use um que já tenha).
2. **Habilite o faturamento** do projeto (Billing) — a Cloud Vision API
   exige uma conta de faturamento vinculada mesmo pra usar só a cota
   gratuita. Você não será cobrado enquanto ficar dentro da cota
   gratuita (**1000 unidades por mês**, ~1000 imagens).
3. No menu "APIs e serviços" → "Biblioteca", procure **Cloud Vision
   API** e clique em **Ativar**.

## 2. Pegar o SHA-1 de assinatura do app

A chave vai ser restrita por esse SHA-1 — sem ele, nenhum app consegue
usá-la, nem o seu.

**Debug** (pra rodar em desenvolvimento, `flutter run`):

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

Procure a linha `SHA1:` na saída.

**Release** (pra gerar o `.apk`/`.aab` de verdade, assinado com sua
keystore de produção): rode o mesmo comando apontando pra sua keystore
de release (a mesma usada em `android/app/build.gradle` pra assinar o
build). Se ainda não tem uma keystore de release, veja a [documentação
oficial do Flutter sobre assinar o app pra
Android](https://docs.flutter.dev/deployment/android#signing-the-app)
antes de seguir.

Você vai precisar dos **dois** SHA-1 (debug e release) se quiser usar a
Cloud Vision tanto em desenvolvimento quanto no app publicado.

## 3. Criar e restringir a API key

1. No Console, vá em "APIs e serviços" → "Credenciais" → "Criar
   credenciais" → "Chave de API".
2. Clique na chave recém-criada pra editar as restrições:
   - **Restrições de aplicativo**: escolha "Apps Android" e adicione uma
     entrada pra cada SHA-1 (debug e release), com o nome do pacote:
     `com.example.driver_analytics_app` (confira em
     `android/app/build.gradle`, campo `applicationId` — vale considerar
     trocar esse ID padrão do template antes de publicar o app de
     verdade, mas pra desenvolvimento funciona do jeito que está).
   - **Restrições de API**: escolha "Restringir chave" e selecione
     apenas **Cloud Vision API** — assim, mesmo que a chave vaze, ela
     não serve pra nenhuma outra API do Google.
3. Salve e copie a chave gerada.

## 4. Rodar/buildar o app com a chave

A chave **nunca** vai pro código-fonte nem pro `pubspec.yaml` — ela é
passada só no momento de build/execução via `--dart-define`:

```bash
# Rodar em desenvolvimento
flutter run --dart-define=GCV_API_KEY=SUA_CHAVE_AQUI

# Gerar um APK/AAB de release
flutter build apk --dart-define=GCV_API_KEY=SUA_CHAVE_AQUI
flutter build appbundle --dart-define=GCV_API_KEY=SUA_CHAVE_AQUI
```

Pra não digitar isso toda vez, dá pra guardar num arquivo local (ex.:
`dart_defines.json`, **adicionado ao `.gitignore`** — nunca commitado)
e usar `--dart-define-from-file=dart_defines.json`, ou configurar como
argumento de execução fixo no seu editor (VS Code: `.vscode/launch.json`
com `"args": ["--dart-define=GCV_API_KEY=..."]`, também fora do
controle de versão).

## Verificando que funcionou

Com a chave configurada, importe um print normalmente. Se a Cloud
Vision estiver respondendo, o texto reconhecido deve vir mais limpo
(menos troca de caractere tipo "1"/"l", "g"/"q") que o ML Kit sozinho.
Se desligar o Wi-Fi/dados do celular e tentar de novo, a importação
deve continuar funcionando — só que usando o ML Kit por baixo,
silenciosamente.
