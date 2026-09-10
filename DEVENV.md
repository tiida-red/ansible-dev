Mac上でVisual Studio Code（VSCode）を使用し、Ansible Automation Platform（AAP）の開発環境（Dev ContainersおよびExecution Environment）を構築するためのステップ・バイ・ステップの手順を説明します。

この手順では、最新の**Ansible開発ツール（Ansible development tools）**と**Ansible開発コンテナ（Ansible development container）**を活用し、一貫性のある開発環境を迅速に立ち上げる方法に焦点を当てます。

### 前提条件
*   **Mac**: 開発用端末。
*   **Gitリポジトリ**: 既存のプレイブックやロールが格納されていること。
*   **AAP環境**: AWS上のEC2に構築済み（Automation Controllerへのネットワークアクセスが可能であること）。

---

### ステップ1：Macへのコンテナエンジンのインストール
Mac上でコンテナ（Execution EnvironmentやDev Containers）を実行するために、コンテナエンジンをインストールします。

1.  **Podmanのインストール**: Red Hatが推奨するオープンソースのコンテナエンジンです。
    *   [Podman Desktop](https://podman-desktop.io/)をダウンロードしてインストールするか、Homebrewでインストールします。
    ```bash
    brew install podman
    podman machine init
    podman machine start
    ```
    *   *注意: Docker Desktopを使用することも可能ですが、AAP環境との互換性からPodmanが推奨されます。*

### ステップ2：VSCodeと拡張機能のセットアップ
VSCodeをAnsible開発に最適化します。

1.  **VSCodeのインストール**: [公式サイト](https://code.visualstudio.com/)から入手。
2.  **必須拡張機能のインストール**:
    *   **Ansible**: (Red Hat製) シンタックスハイライト、Lightspeed（AI支援）、およびEE連携を提供。
    *   **Dev Containers**: (Microsoft製) コンテナ内での開発を可能にする。

### ステップ3：GitリポジトリのクローンとVSCodeでの起動
1.  ターミナルでリポジトリをクローンします。
    ```bash
    git clone <あなたのGitリポジトリURL>
    cd <リポジトリ名>
    ```
2.  VSCodeでディレクトリを開きます。
    ```bash
    code .
    ```

### ステップ4：Ansible開発コンテナの導入
リポジトリ内にDev Containerの設定を作成し、Red Hatが提供する「Ansible開発コンテナ」を使用するように設定します。

1.  リポジトリ直下に `.devcontainer/devcontainer.json` ファイルを作成します。
2.  以下の内容を記述します（AAP 2.5以降で推奨される設定例）:
    ```json
    {
      "name": "Ansible Dev Container",
      "image": "registry.redhat.io/ansible-automation-platform-25/ansible-dev-tools-rhel8:latest",
      "customizations": {
        "vscode": {
          "extensions": [
            "redhat.ansible"
          ]
        }
      },
      "features": {
        "ghcr.io/devcontainers/features/docker-in-docker:1": {}
      },
      "remoteUser": "root"
    }
    ```
3.  VSCodeの右下に表示される「Reopen in Container」をクリック、またはコマンドパレット（`Cmd+Shift+P`）から `Dev Containers: Reopen in Container` を選択します。
4.  これにより、`ansible-navigator`、`ansible-builder`、`ansible-lint` などが含まれた標準的な開発環境がコンテナ内で立ち上がります。

### ステップ5：Execution Environment (EE) の設定
開発コンテナ内で、実際に実行に使用するExecution Environmentを指定します。

1.  **ansible-navigatorの設定**: リポジトリ直下に `ansible-navigator.yml` を作成します。
    ```yaml
    ansible-navigator:
      execution-environment:
        container-engine: podman
        image: registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel8:latest
        pull:
          policy: missing
      logging:
        level: debug
    ```
2.  これにより、`ansible-navigator run` を実行した際、指定したEEコンテナ内でプレイブックが動作するようになります。

### ステップ6：AWS上のAAP（Automation Controller）との連携
ローカルで作成したコンテンツを、EC2上のAAPに接続して実行・管理できるようにします。

1.  **接続情報の構成**: コンテナ内の `ansible.cfg` または環境変数で、EC2上のController URLとトークンを設定します。
2.  **プロジェクトの同期**: VSCodeで編集しGitへPushした内容を、AAP Controllerの「プロジェクト」からGit経由で同期するように設定します [↗](https://developers.redhat.com/articles/2025/07/10/ee-builder-ansible-automation-platform-openshift)。

### ステップ7：開発・テストの実行
1.  **プレイブックの実行**: VSCodeのターミナル（コンテナ内）で以下を実行します。
    ```bash
    ansible-navigator run site.yml -i inventory.ini --mode stdout
    ```
2.  **アーティファクトの確認**: 実行結果や事後情報を `ansible-navigator` のTUIモードで確認できます。

### 補足：カスタムEEのビルド（必要に応じて）
標準のEEに必要なライブラリが足りない場合は、コンテナ内で `ansible-builder` を使用して独自のEEを作成できます。
```bash
ansible-builder build --tag my-custom-ee:v1
```

これにより、Mac上のVSCodeから、本番のAAP環境と同一の実行条件（EE）で開発・テストを行うことが可能になります [↗](https://www.redhat.com/en/blog/new-red-hat-ansible-development-tools)。

**Sources**

- [Introducing the new Red Hat Ansible development tools](https://www.redhat.com/en/blog/new-red-hat-ansible-development-tools)
- [EE Builder with Ansible Automation Platform on OpenShift](https://developers.redhat.com/articles/2025/07/10/ee-builder-ansible-automation-platform-openshift)