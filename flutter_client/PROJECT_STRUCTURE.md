<!-- feito por marcelo -->
# MesclaInvest — Flutter Client


## Tecnologias principais


| `flutter_modular` | Gerenciamento de rotas e injeção de dependências |
| `mobx` + `flutter_mobx` | Gerenciamento de estado reativo |
| `dio` | Cliente HTTP para consumo da API do back-end |
| `build_runner` + `mobx_codegen` | Geração de código automático dos Controllers do MobX |

---

## Gerando os arquivos do MobX

Após criar ou alterar um Controller (arquivo `.dart` com `@observable`, `@action`, etc.), rode:

```bash
flutter pub run build_runner build
```

Para assistir a alterações continuamente durante o desenvolvimento:

```bash
flutter pub run build_runner watch
```

Os arquivos gerados possuem o sufixo `.g.dart` e **não devem ser editados manualmente**.

Convenção de nomenclatura: `login_controller.dart` → gera `login_controller.g.dart`.

---

## Configurações globais

- **`lib/core/app_settings.dart`** — Constantes globais da aplicação: `baseUrl` da API, `appName` e `timeout` das requisições HTTP.

---

## Estrutura de pastas

```
flutter_client/
├── lib/
│   ├── main.dart                          # Ponto de entrada da aplicação
│   ├── app_module.dart                    # Módulo raiz do Modular (registra Dio como singleton)
│   ├── app_widget.dart                    # Widget raiz (MaterialApp.router + tema global)
│   │
│   ├── core/
│   │   └── app_settings.dart             # Constantes globais (baseUrl, appName, timeout)
│   │
│   ├── data/
│   │   ├── data_classes/                 # Modelos de domínio (entidades puras)
│   │   ├── dtos/                         # Objetos de transferência de dados (serialização JSON)
│   │   ├── enums/                        # Enumerações compartilhadas entre camadas
│   │   └── repositories/                # Interfaces e implementações de acesso a dados (via Dio)
│   │
│   ├── shared/
│   │   └── (vazio — reservado para widgets e utilitários reutilizáveis)
│   │
│   └── modules/
│       └── presentation/
│           ├── components/              # Widgets reutilizáveis entre páginas
│           └── pages/
│               ├── home_page/           # Página inicial autenticada
│               │   ├── home_page.dart
│               │   └── home_controller.dart
│               └── login_page/          # Página de autenticação
│                   ├── login_page.dart
│                   └── login_controller.dart
```

---

## Descrição de cada camada e página

### `main.dart`
Ponto de entrada do app. Inicializa o `ModularApp` com o `AppModule` e o `AppWidget`.

### `app_module.dart`
Módulo raiz do Modular. Registra dependências globais como o cliente `Dio` (singleton), configurado com `baseUrl`, `connectTimeout`, `sendTimeout` e `receiveTimeout` vindos do `AppSettings`.

### `app_widget.dart`
Widget raiz da aplicação. Configura o `MaterialApp.router` com o tema global (Material 3, semente de cor âmbar) e conecta o sistema de rotas do Modular.

---

### `core/`
Camada de configuração e constantes da aplicação.

- **`app_settings.dart`** — Centraliza valores sensíveis ao ambiente: URL base da API, nome do app e timeout das requisições.

---

### `data/`
Camada de dados. Responsável por toda comunicação com a API e pela modelagem dos dados.

- **`data_classes/`** — Modelos de domínio (ex: `Startup`, `Token`, `Usuario`). São classes puras que representam as entidades do negócio, sem lógica de serialização.
- **`dtos/`** — *Data Transfer Objects*: versões serializáveis dos modelos, com métodos `fromJson` / `toJson` para comunicação com a API.
- **`enums/`** — Enumerações usadas em todo o projeto (ex: estágio de maturidade da startup, tipo de ordem de compra/venda).
- **`repositories/`** — Classes responsáveis por buscar e enviar dados via `Dio`. Cada repositório concentra as chamadas de um recurso específico da API (ex: `StartupRepository`, `TokenRepository`).

---

### `shared/`
Reservado para widgets e funções utilitárias reutilizáveis que não pertencem a nenhum módulo específico (ex: componentes de loading, formatadores de moeda/data).

---

### `modules/presentation/`
Camada de apresentação. Contém toda a UI do aplicativo.

#### `components/`
Widgets reutilizáveis entre múltiplas páginas (ex: cards de startup, botões customizados, gráficos).

#### `pages/login_page/`
Página de autenticação do usuário. Deve conter:
- Formulário com campos de **e-mail** e **senha**.
- Botão de login que aciona o `LoginController`.
- Suporte a **MFA/2FA** (etapa adicional de verificação).
- Navegação para a `home_page` após login bem-sucedido.
- Exibição de erros de autenticação (credenciais inválidas, timeout, etc.).

#### `pages/home_page/`
Página inicial exibida após o login. Deve conter:
- **Catálogo de startups** do ecossistema Mescla, com filtros por estágio de maturidade.
- **Cards** resumidos de cada startup (nome, setor, variação do token).
- Acesso ao **dashboard pessoal** do investidor (carteira, saldo simulado, rentabilidade), gerenciado pelo `HomeController`.
- Navegação para páginas de detalhe de startup, balcão de negociação e perfil do usuário.
