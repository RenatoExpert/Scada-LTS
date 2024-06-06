#	Manual de Desenvolvimento
Resumindo o fluxo de trabalho, algumas boas práticas e erros para evitar.

##	Fluxo de trabalho
1. Criar uma branch com um tema especifico
2. Realizar todas as modificações naquela nova branch
3. Antes de finalizar, atualizar a branch `git pull; git merge main` e testar novamente
4. Enviar para o repositório e abrir um pull request

##	Recomendações
###	Boas práticas para pull requests
1. Sempre trabalhe com atualizações granulares, ou seja, resolva apenas um problema em cada branch e pull request
2. Quanto mais granular, menor o tempo de transição, menor a chance de dar um conflito na hora do merge
3. Sempre ler e revisar o patch, isso evita muitos erros. `git diff main`

###	Boas práticas de desenvolvimento
1. Usar os conceitos de *Clean Code* ajudam na fluidez do projeto
2. Sempre testar bastante antes de submeter ao código principal
3. Priorizar a generalidade e reuso do código. Lembre-se do DRY "Dont Repeat Youself"

###	O que evitar
1. Gambiarras, maus nomes para variáveis, funções muito longas, código dificil de entender à primeira vista
2. Commits diretos na branch main
3. Não revisar o código ou não testar

##	Alguns arquivos e diretórios recorrentes
###	Dockerfile
Scripts para geração das imagens Docker
###	compose-*.yml
Descrições de infraestrutura para implementação automática das imagens docker
###	src/
Diretório com o código fonte do backend
###	opcua\_server
Diretório do servidor OPCUA
###	scadalts-ui
Código fonte das bibliotecas NPM, dos componentes em VueJS e da interface moderna
###	volumes
Aqui ficam arquivos dos containers de docker

##	Operações básicas
###	Git
####	Clonar o repositório
`git clone git@github.com:argos-scada/Scada-LTS`
####	Trocar de branch (exemplo para a branch "test")
`git checkout test`
####	Criar uma nova branch
`git checkout -b nova_branch`
####	Enviar atualizações
`git push`

###	Docker
####	Construir e executar a aplicação
`docker compose -f compose-test.yml up --build`
####	Apenas construir a aplicação
`docker compose -f compose-test.yml build`
####	Apenas executar, sem recompilar
`docker compose -f compose-test.yml up`

