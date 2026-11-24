# AdotaPet

**Um novo lar. Uma nova história.**

Aplicativo didático Flutter + Firebase Spark. Um usuário comum pode doar e adotar; o administrador modera anúncios, acompanha pedidos e bloqueia perfis. Não utiliza Storage, Cloud Functions ou faturamento.

## Início rápido

1. Instale Flutter estável, Android Studio, Node.js e os CLIs.
2. Execute `powershell -ExecutionPolicy Bypass -File .\preparar_android.ps1` na pasta projeto.
3. Crie Firebase Spark, habilite Authentication e Firestore.
4. Execute `firebase use --add`, `flutterfire configure` e `firebase deploy --only firestore:rules,firestore:indexes`.
5. Execute `flutter pub get`, `flutter analyze`, `flutter run`.

O código nativo Android e firebase_options.dart são gerados localmente. Não há APK compilado no pacote.

## Arquitetura

`lib/models`: dados; `lib/services`: operações Firebase e compressão; `lib/screens`: telas; `lib/widgets`: componentes; `lib/theme`: identidade visual. A versão consolidada agrupa telas relacionadas para reduzir duplicação.

## Banco de dados

| Coleção | Identificador | Campos principais |
|---|---|---|
| usuarios | UID | nome, email, telefone, cidade, tipo, ativo, criadoEm |
| animais | automático | nome, especie, raca, idadeMeses, porte, sexo, descricao, vacinado, castrado, fotoBase64, doadorId, status, criadoEm, atualizadoEm |
| solicitacoes | animalId_UID | animalId, animalNome, adotanteId, adotanteNome, doadorId, mensagem, status, datas |
| solicitacoes/{id}/mensagens | automático | remetenteId, texto, criadoEm |

Ao aceitar um pedido, o animal recebe adotanteId e solicitacaoAceitaId. Ao desfazer, ambos são removidos.

## Fluxo

Animal: pendente → disponivel → em_adocao → adotado. Reprovação: reprovado. Edição volta a pendente. Pedido: pendente → aceita → concluida ou cancelada; pedido pendente pode ser recusado ou cancelado.

## Instalação detalhada e operação

### 01 | Preparação do ambiente

Instale Git, Flutter SDK estável, VS Code com extensões Flutter e Dart, Android Studio com SDK e emulador, Node.js LTS e Java compatível com o Emulator Suite. Utilize instalações gratuitas. Adicione flutter/bin ao PATH do Windows e reinicie o terminal.

Verifique o ambiente e aceite as licenças Android. Crie um dispositivo virtual no Android Studio > Device Manager.

```text
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```

Instale os CLIs. Se flutterfire não for reconhecido, adicione %LOCALAPPDATA%\Pub\Cache\bin ao PATH. Se npm não for reconhecido, reinstale Node.js e reabra o terminal.

```text
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire --version
```


### 02 | Preparar o projeto

Extraia o ZIP em uma pasta local, abra a pasta projeto no VS Code e execute o script abaixo no PowerShell. Ele gera os arquivos Android com o Flutter instalado e preserva lib e pubspec.yaml. Não há APK pronto nem configuração Firebase compartilhada.

```text
powershell -ExecutionPolicy Bypass -File .\preparar_android.ps1
```

Se preferir gerar manualmente, crie um projeto Flutter novo com o mesmo nome, copie a pasta lib, pubspec.yaml, firestore.rules, firebase.json e firestore.indexes.json do pacote para ele. Remova o teste padrão do contador.

```text
flutter create --platforms=android adotapet
flutter pub get
```

Confirme no AndroidManifest.xml principal que existe a permissão INTERNET antes de application. O script já faz essa alteração.

```text
<uses-permission android:name="android.permission.INTERNET" />
```


### 03 | Configurar Firebase gratuito

Em https://console.firebase.google.com crie um projeto próprio, mantendo Spark e sem vincular faturamento. Analytics é opcional. Em Authentication > Sign-in method habilite E-mail/senha. Em Firestore Database crie o banco padrão em modo produção e selecione uma região disponível.

No terminal da pasta projeto, associe o projeto e gere lib/firebase_options.dart. Selecione Android e confira se o package name coincide com o applicationId do Gradle.

```text
firebase use --add
flutterfire configure
flutter pub get
```

Publique regras e isenção de índice de fotoBase64. Alternativamente cole firestore.rules no console e configure a isenção do campo na seção Índices > Campo único.

```text
firebase deploy --only firestore:rules,firestore:indexes
```

Verifique que o Firebase Storage não foi habilitado. O armazenamento de fotos usa Base64 no Firestore, até 100 KiB de JPEG por animal; não há dependência firebase_storage.


### 04 | Autenticação e perfis

Execute o aplicativo em um emulador. Crie quatro contas fictícias: administrador, doador, adotante A e adotante B. Use e-mails de teste sob seu controle e senhas individuais.

```text
flutter analyze
flutter run
```

No console Authentication > Users, copie o UID da conta administrativa. Em Firestore > usuarios > UID, altere o campo tipo de usuario para admin. O campo ativo deve ser true. Nunca ofereça promoção para admin na tela de cadastro.

AuthService cria credenciais no Authentication e perfil no Firestore. AuthGate monitora sessão e perfil. Usuário comum pode doar e adotar com a mesma conta; administrador modera e consulta. Teste recuperação de senha, saída e nova entrada.


### 05 | CRUD, fotos e filtros

Entre como doador e cadastre um animal com nome, espécie, raça, idade em meses, porte, sexo, descrição, vacinação e castração. Selecione foto na galeria ou câmera. O serviço redimensiona e comprime a imagem, salva Base64 no documento.

Entre como admin, abra Gerenciar e aprovar animais e aprove o anúncio. Entre como adotante e confira o catálogo. Teste busca sem acento, porte, espécie, sexo, idade, vacinação e castração. A edição do dono retorna o anúncio para pendente.

As faixas didáticas são filhote 0–11, jovem 12–35, adulto 36–83 e idoso a partir de 84 meses. Não são classificações veterinárias universais. Exclua um anúncio editável de teste e confira a remoção da foto junto ao documento.


### 06 | Solicitações e chat

Adotantes A e B solicitam o mesmo animal com uma mensagem de interesse. A mesma conta não consegue criar dois pedidos para o mesmo animal. O próprio dono não pode solicitar seu animal.

Como doador, abra Solicitações recebidas e aceite A. O pedido muda para aceita e o animal para em_adocao, em uma transação. Tentar aceitar B deve falhar. Desfaça o aceite de A, aceite B e abra o chat em ambas as contas.

Envie mensagens de até 500 caracteres. Conclua a adoção somente após a entrega fictícia. Animal passa para adotado e pedido para concluida; chat fica em leitura. Outros pedidos pendentes podem ser recusados ou cancelados, mas não aceitos.


### 07 | Administração e segurança

Abra o dashboard para contar perfis, animais, espécies e pedidos. Atualize pelo botão de recarregar. Os contadores são consultas independentes e podem variar durante alterações simultâneas.

Bloqueie um usuário comum e confirme que o campo ativo fica false. O usuário ainda pode autenticar, mas as operações protegidas são negadas. Retire manualmente anúncios disponíveis de contas bloqueadas. Adoções em andamento exigem revisão individual.

As regras verificam proprietário, participante, perfil ativo, status e campos alterados. getAfter valida a mudança simultânea do animal e pedido. O administrador do aplicativo não lê o chat; proprietários do projeto Firebase com acesso ao console podem acessar dados. Não é criptografia ponta a ponta.


### 08 | Testes locais e diagnóstico

O Emulator Suite é opcional, gratuito e independente da nuvem. Instale Java compatível, execute os emuladores na pasta projeto e abra http://localhost:4000. Cadastre as contas e configure admin novamente nesse ambiente.

```text
firebase emulators:start --only auth,firestore
flutter run --dart-define=USAR_EMULADORES=true
```

No emulador Android padrão, 10.0.2.2 aponta para o computador. Para outro ambiente use --dart-define=EMULADOR_HOST=ENDERECO. Não exponha os emuladores à internet. Para a nuvem execute flutter run sem a flag.

permission-denied: revise regras, perfil, status e UID. No Firebase App: confira inicialização. MissingPluginException: pare e execute novamente. Target of URI: gere firebase_options.dart. Se Gradle falhar, consulte flutter doctor -v e as mensagens do SDK. Se houver resource-exhausted, aguarde a renovação das cotas; não migre para Blaze.


### 09 | APK, GitHub e entrega

Verifique análise e testes manuais antes de gerar o APK. O APK debug é suficiente para a aula. O arquivo ficará em build/app/outputs/flutter-apk/app-debug.apk. Transfira para o celular e autorize temporariamente instalação pela fonte utilizada.

```text
flutter analyze
flutter build apk --debug
flutter install
```

Crie um repositório vazio no GitHub. Revise .gitignore e não publique senhas, chaves de serviço, arquivos de assinatura ou informações pessoais. Cada grupo gera sua configuração Firebase.

```text
git init
git add .
git commit -m "Projeto AdotaPet"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/adotapet.git
git push -u origin main
```

Entregue código, README, APK, capturas de tela, evidências dos testes e relatório com dificuldades e decisões. O pacote foi revisado estruturalmente, mas não compilado neste ambiente; execute flutter analyze e valide as regras em um projeto de testes antes da apresentação.

## Referências oficiais

- https://docs.flutter.dev/get-started/install
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/firestore/security/get-started
- https://firebase.google.com/docs/firestore/manage-data/transactions
- https://firebase.google.com/docs/emulator-suite
- https://firebase.google.com/pricing

## Limitações

Protótipo acadêmico; fotos em Base64 aumentam tráfego e tamanho; chat carrega apenas 50 mensagens; pedidos pendentes não são encerrados automaticamente; bloqueio não desativa Authentication. Não use dados reais antes de revisão de privacidade, moderação e testes.
