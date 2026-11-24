# Guia de desenvolvimento por etapas

Use a versão consolidada como referência. Para desenvolver em aula, crie um projeto vazio e avance pelos módulos abaixo; mantenha as regras fechadas para funcionalidades ainda não implementadas. A aplicação final agrupa algumas telas e serviços para reduzir repetição.

## 1. Configuração
Leia main.dart e pubspec.yaml. Gere firebase_options.dart com FlutterFire. Antes de iniciar o AuthGate, teste a inicialização com uma tela Scaffold simples. Evidência: emulador funcionando.

## 2. Autenticação
Leia auth_service.dart, auth_page.dart e auth_gate.dart. Explique Future, async/await, authStateChanges e o StreamBuilder do perfil. A conta do Auth e o documento do Firestore são operações distintas; CompletarPerfil recupera perfis ausentes. Evidência: duas contas fictícias, dois UIDs.

## 3. CRUD financeiro
Leia models/movimentacao.dart, services/financeiro_service.dart e screens/movimentacao_form.dart. toMap converte o objeto em campos; fromDoc reconstrói o objeto. add cria ID, update preserva criadoEm, delete remove o documento. Explique centavos usando utils/formatadores.dart: 1.250,90 vira 125090. Evidência: cadastrar, editar e excluir.

## 4. Categorias
Leia Categoria, inicializar(), salvarCategoria() e situacao(). Discuta transações, IDs fixos, nomes normalizados e exclusão lógica. Cadastre uma categoria Viagens e arquive-a após registrar uma despesa; o histórico deve permanecer.

## 5. Indicadores
Leia resumir() e porCategoria() em utils/calculos_financeiros.dart. Explique acumuladores, contadores, média, extremos e divisão por zero. Compare SUM, COUNT e GROUP BY do SQL. Evidência: confira o saldo da base de novembro.

## 6. Histórico
Leia intervalo(), pagina() e HistoricoPage. O intervalo começa inclusive e termina exclusivo. O cursor evita offset; os filtros operam localmente sobre as páginas carregadas. Compare pesquisa sem acentos, categoria, pagamento e valor. Evidência: 31 registros no mesmo mês, duas páginas e aviso parcial.

## 7. Gráficos
Leia RelatoriosPage e widgets/graficos.dart. PieChart mostra distribuição; BarChart compara receitas e despesas; LineChart mostra evolução do saldo. Compare os seis meses com o CSV. Evite comparar percentuais sem base anterior positiva.

## 8. Metas
Leia MetasPage em planejamento_page.dart. A proporção reservado/objetivo controla a barra; clamp limita o desenho de 0 a 1. O valor guardado não altera movimentações. Teste uma meta de R$ 1.000 com R$ 250 reservados (25%).

## 9. Orçamento
Leia OrcamentosPage. O ID combina período e categoria; porCategoria soma gastos reais. Teste Alimentação em novembro com limite de R$ 700: gasto R$ 770,90 e alerta de excesso. A exclusão remove apenas o limite.

## 10. CSV
Leia utils/exportacao.dart. Aspas são duplicadas e campos textuais que começam com caracteres de fórmulas recebem apóstrofo. O histórico só permite exportar após carregar o período. Cole o conteúdo em arquivo UTF-8 e confira os dados.

## 11. Interface
Leia theme/app_theme.dart, HomePage e ResumoCard. Explique Material 3, Navigator.push, componentes reutilizáveis e estados de carregamento. Teste em um aparelho de tela pequena.

## 12. Segurança e entrega
Leia firestore.rules e test/calculos_financeiros_test.dart. Simule leitura em UID alheio e valor negativo. Execute dart format, flutter analyze, flutter test e flutter build apk --debug. Documente resultados reais e pendências. Nunca utilize dados financeiros reais em aula.
