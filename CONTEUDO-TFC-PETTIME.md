3.5. PERSISTÊNCIA DE DADOS

A persistência de dados refere-se à capacidade de um sistema de armazenar informações de forma permanente, permitindo que elas sejam recuperadas e utilizadas posteriormente, mesmo após o encerramento do programa ou a reinicialização do sistema. Isso é essencial para garantir que os dados não sejam perdidos e possam ser acessados conforme necessário.

Por exemplo, no sistema PetTime para agendamento veterinário, a persistência de dados assegura que informações sobre usuários, pets, veterinários, agendamentos e histórico médico sejam armazenadas de forma confiável. Isso permite que o sistema recupere essas informações para uso futuro, mesmo após desligamentos ou falhas.

3.5.1. Banco de dados relacional: MySQL/MariaDB

O banco de dados utilizado no projeto foi o MySQL/MariaDB, escolhido por sua robustez, confiabilidade em manipulação de dados e ampla compatibilidade com sistemas de produção.

A persistência de dados foi implementada utilizando o banco de dados relacional MySQL. Todas as operações de leitura e gravação são centralizadas no backend desenvolvido em Node.js com Express, que se comunica diretamente com o banco de dados através do ORM Sequelize. Esta arquitetura garante integridade referencial, transações ACID e otimização de consultas.

3.6. TESTES AUTOMATIZADOS

Testes automatizados são processos que utilizam ferramentas específicas para validar funcionalidades e detectar falhas em softwares de forma automática. Eles são fundamentais para garantir a qualidade, eficiência e confiabilidade de aplicações, permitindo a execução rápida e repetitiva de testes e reduzindo o tempo necessário para encontrar problemas.

Além disso, ajudam a minimizar erros humanos, proporcionam maior cobertura de cenários de teste e identificam defeitos ainda nas etapas iniciais do desenvolvimento. Essa abordagem também favorece práticas de integração contínua, tornando os ciclos de desenvolvimento mais ágeis e seguros, além de reduzir custos a longo prazo.

3.6.1. Teste unitário no backend

Os testes unitários foram realizados no backend utilizando Jest, framework robusto de testes para JavaScript/Node.js, com foco em validar as funcionalidades individuais do sistema, garantindo que cada componente funcione conforme o esperado de forma isolada.

3.6.2. Teste unitário no frontend

No frontend desenvolvido em Flutter, foram implementados testes unitários utilizando o framework nativo do Flutter, focando na validação de modelos de dados, utilitários, validadores e regras de negócio específicas da aplicação móvel.

4. AVALIAÇÃO

4.1. VERIFICAÇÃO E AVALIAÇÃO

4.1.1. Testes unitários

Para a realização dos testes unitários do projeto, foram utilizadas duas ferramentas distintas: Jest para o backend Node.js e Flutter Test para o frontend móvel. Essas ferramentas robustas permitiram verificar a funcionalidade e a integridade das operações do sistema, garantindo que os componentes críticos funcionassem conforme o esperado.

A execução dos testes foi realizada no ambiente de desenvolvimento Visual Studio Code, permitindo a validação contínua do código e a identificação precoce de falhas. Essa abordagem garantiu eficiência e flexibilidade no processo de testes, eliminando a necessidade de configurações adicionais e facilitando a integração dos testes na rotina de desenvolvimento.

Problemas Identificados e Correções Aplicadas:

Erro de Validação de Modelos: Durante a execução inicial dos testes no frontend, foram identificados problemas relacionados aos métodos `copyWith` dos modelos Pet e Usuario. Esses erros indicavam que algumas propriedades não estavam sendo tratadas adequadamente quando valores nulos eram fornecidos. Ajustes foram implementados para garantir o comportamento correto dos modelos de dados.

Erro de Validação Brasileira: Conforme identificado durante os testes, problemas de validação específica para padrões brasileiros foram detectados nos validadores de CPF, telefone e email. Os validadores não estavam reconhecendo adequadamente caracteres acentuados e formatos específicos do Brasil. Correções foram aplicadas para garantir total compatibilidade com os padrões nacionais.

Erro de Utilitários de Data: Um erro de configuração foi detectado nos utilitários de manipulação de data, especificamente relacionado ao cálculo de idade e formatação de datas. Este problema foi identificado durante a validação dos modelos de negócio, gerando falhas nos testes unitários.

RESULTADOS DOS TESTES - FRONTEND

Após as correções necessárias, os testes unitários do frontend foram executados novamente e todos os testes passaram com sucesso. A execução dos 289 testes unitários no Flutter, cobrindo os módulos de modelos (Pet, Usuario), validadores (CPF, telefone, email), utilitários (string, data) e regras de negócio, resultou em 100% de sucesso.

RESULTADOS DOS TESTES - BACKEND

Os testes unitários do backend também foram executados com sucesso total. A execução dos 70 testes utilizando Jest, cobrindo os módulos de validadores, regras de negócio, serviços de pets, utilitários de senha e testes de performance/stress, resultou em 100% de aprovação.

Resumo dos Resultados:
- Frontend (Flutter): 289/289 testes aprovados (100%)
- Backend (Node.js + Jest): 70/70 testes aprovados (100%)
- Total: 359/359 testes unitários aprovados (100%)

Os resultados obtidos asseguram que o ambiente está preparado para lidar com as operações do sistema em produção, garantindo estabilidade, confiabilidade e desempenho adequado para os usuários finais. A cobertura abrangente dos testes unitários demonstra a qualidade do código desenvolvido e a robustez das funcionalidades implementadas.

4.1.2. Análise estática

Para garantir a qualidade e conformidade do código, foram realizadas análises estáticas utilizando ferramentas específicas para cada tecnologia: ESLint para o backend Node.js e Flutter Analyzer para o frontend Flutter. Essas revisões permitiram identificar áreas que necessitavam de melhorias, incluindo problemas de importação, inconsistências de estilo e trechos de código que poderiam gerar dificuldades de manutenção no futuro.

Com essas análises, foi possível abordar falhas que, de outra forma, poderiam comprometer a robustez e a sustentabilidade do projeto. As ferramentas utilizadas indicaram pontuações altas, refletindo a conformidade do código com as boas práticas de programação e um bom nível de qualidade no desenvolvimento do projeto.

4.2. USABILIDADE

A usabilidade é essencial no desenvolvimento de sistemas móveis, pois afeta diretamente tanto a experiência do usuário quanto a eficácia na realização dos objetivos do aplicativo. Para garantir um alto padrão de usabilidade neste projeto, foi adotado um processo de avaliação estruturado com base em um Checklist de Usabilidade específico para aplicações móveis.

Esse checklist serve como ferramenta para analisar aspectos fundamentais do sistema móvel, como facilidade de navegação, clareza das informações, consistência visual, responsividade da interface, prevenção de erros e acessibilidade. A verificação foi realizada em parceria entre o desenvolvedor e a orientadora, proporcionando uma avaliação equilibrada e objetiva da funcionalidade do sistema.

Para a avaliação de usabilidade do projeto PetTime, foi utilizado o "Checklist de Usabilidade para Aplicações Móveis", disponível nos Anexos. O documento foi preenchido pelo desenvolvedor e pela orientadora, possibilitando uma análise comparativa e abrangente.

O Checklist de Usabilidade consiste em um conjunto de critérios desenvolvidos para avaliar a interface e a experiência do usuário no sistema móvel em diversos aspectos. Cada critério oferece quatro opções de avaliação:

• Sim: O critério foi atendido integralmente.
• Parcial: O critério foi atendido, mas de forma parcial.
• Não: O sistema não atende ao critério.
• Não se aplica: O critério não é relevante para o sistema.

Os critérios avaliados incluem aspectos como navegação intuitiva, feedback visual adequado, tempo de resposta satisfatório, tratamento de erros, consistência de design, acessibilidade e adaptação a diferentes tamanhos de tela, garantindo uma experiência completa e satisfatória para os usuários do aplicativo PetTime.