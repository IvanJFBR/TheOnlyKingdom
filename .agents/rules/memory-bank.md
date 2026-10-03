# Memory Bank & Context Handoff Protocol

Este protocolo evita degradação de contexto, alucinações e perda de histórico em conversas longas através da persistência de estado em arquivos e handoffs estruturados.

---

## 1. Estrutura do Memory Bank
O estado contínuo do projeto fica salvo na pasta `.agents/memory/`:
- `projectbrief.md`: Visão geral do jogo, escopo e tecnologias centrais.
- `systemPatterns.md`: Padrões de arquitetura, convenções técnicas (ex: escala de tiles, caminhos do VisuStella, scripts de geração).
- `activeContext.md`: Estado atual, foco recente, decisões tomadas na sessão e o que está pendente.
- `progress.md`: O que já está implementado e validado, problemas conhecidos e backlog de tarefas.

---

## 2. Inicialização de um Novo Agente
Ao iniciar uma nova sessão ou receber a primeira mensagem neste repositório:
1. **Consulte o Memory Bank:** Leia `.agents/memory/activeContext.md` e `.agents/memory/systemPatterns.md` antes de tomar decisões arquiteturais.
2. Confirme o entendimento do estado atual e pergunte qual é a prioridade da nova sessão.

---

## 3. Gatilhos de Atualização e Handoff (Encerramento de Contexto)
O agente deve acionar o procedimento de handoff quando:
- Uma grande etapa ou milestone for concluído com sucesso.
- A conversa estiver ficando muito longa ou com muitas saídas de terminal acumuladas.
- O usuário solicitar o encerramento, handoff ou preparação para um novo chat.

### Procedimento de Handoff:
1. **Atualizar os arquivos do Memory Bank:**
   - Registre o que foi finalizado em `progress.md`.
   - Atualize `activeContext.md` com o status exato dos arquivos, decisões recentes e próximos passos imediatos.
   - Adicione novos aprendizados técnicos ou regras em `systemPatterns.md`.
2. **Gerar o Prompt do Próximo Agente:**
   - Finalize a resposta fornecendo um bloco de texto curto e objetivo que o usuário poderá simplesmente colar na abertura do novo chat.
   - Esse prompt deve instruir o novo agente a ler `.agents/memory/activeContext.md` e prosseguir a partir do ponto exato onde a sessão parou.
