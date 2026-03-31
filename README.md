# MesclaInvest 

**Disciplina:** Projeto Integrador 3 - Engenharia de Software 2026 Semestre 1

**Instituição:** Pontifícia Universidade Católica de Campinas (PUC-Campinas)  

**Professor Orientador:** Professora Renata Antonia Tadeu Arantes

 **Mapa Mental**: [Artefato criado na ferramenta Miro](https://miro.com/app/board/uXjVGww0ESY=/?share_link_id=349184105866).

 **Figma**: [Artefato criado no Figma](https://www.figma.com/design/7kIFc6Hmt5Pts6Sz3vaRDz/pi-3-mescla-invest?node-id=1-189&t=2uFCxR8mExioZfor-1).

 **Planilhas**:
   - **Coleção de Startups**: [Artefato criado no Excel](https://tinyurl.com/388xdxbj).

**Firebase/Firestore**: [Banco de Dados](https://console.firebase.google.com/u/0/project/projetointegrador3-grupo18/overview?hl=pt-br&fb_gclid=Cj0KCQjw4a3OBhCHARIsAChaqJOj-gQb5Fa7s_CXDZ_Hj5shcfi0tJHbE2HYav1f2hfwtdmkn89oVWcaAlgOEALw_wcB&fb_utm_campaign=Cloud-SS-DR-Firebase-FY26-global-pmax-1713590&fb_utm_content=pmax&fb_utm_medium=display&fb_utm_source=PMAX).

---

## Descrição do Projeto

O **MesclaInvest** é um ecossistema digital simulado de investimentos voltado para as startups vinculadas ao hub de inovação Mescla, da PUC-Campinas. O projeto consiste em um aplicativo móvel que funciona como uma plataforma de relações com investidores e corretora simulada. 

O objetivo principal é permitir que usuários conheçam os projetos do ecossistema e realizem a compra e venda simulada de *tokens* (participações digitais) dessas startups, acompanhando a valorização de seus investimentos por meio de gráficos e dashboards interativos. Ressalta-se que o ambiente é 100% pedagógico e simulado, sem transações financeiras reais ou uso de blockchain em produção.

### Principais Funcionalidades:
* Autenticação de usuários (com opção de MFA/2FA).
* Catálogo de Startups com filtros por estágio de maturidade.
* Acesso a documentos, estrutura societária e murais de perguntas.
* Balcão de negociação para compra e venda de tokens com saldo simulado.
* Dashboard para acompanhamento da variação e valorização dos tokens no tempo.

---

## Integrantes da Equipe

* **Abdallah Ali Borges El-Khatib** - RA: [25018711]
* **Gabriel Scolfaro de Azeredo** - RA: [25006194]
* **Marcelo Zarpelon** - RA: [25015323]
* **Miguel Afonso Castro de Almeida** - RA: [25016044]
* **Pedro Henrique Bonetto da Costa** - RA: [25018203]

---


## Tecnologias Utilizadas

Este projeto segue rigorosamente os requisitos tecnológicos estabelecidos no Documento de Visão:

* **Frontend (Mobile):** Flutter (Linguagem Dart)
* **Backend:** Node.js com [TypeScript]
* **Banco de Dados:** Firebase Firestore (NoSQL)
* **Controle de Versão:** Git / GitHub

---

# Como executar o Projeto

## Pré-requisitos

- Flutter instalado
- Node.js instalado (Versão mais recente)
- Firebase CLI instalado (`npm install -g firebase-tools`)


## 1. Clone o repositório

```bash
git clone https://github.com/zarpela/ES-PI3-2026-T3-G18.git
```

## 2. Acesse a pasta do projeto

```bash
cd ES-PI3-2026-T3-G18
```

---

## Frontend (Flutter)

Entre na pasta flutter_client:
```bash
cd flutter_client
```

Instale as dependências:
```bash
flutter pub get
```

Para rodar o app:
```bash
flutter run
```

---

## Backend (Firebase Functions)


Entre na pasta functions:
```bash
cd functions
```

Instale as dependências:
```bash
npm install
```

---

