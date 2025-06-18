# Quiz Study App 📚

AI（Gemini）を活用したクイズ学習アプリケーションです。質問を投稿すると、AIが自動で回答と例え話、そして理解度を確認するクイズを生成します。LINE連携により、クイズを日常的に受け取ることができる学習支援ツールです。

## ✨ 主な機能

### 🤖 AI回答生成
- **Google Gemini API**を使用した高品質な回答生成
- 質問に対する構造化された回答（200文字以内）
- 理解しやすい**例え話**の自動生成
- **抽象化レベル**（小学生〜大学生向け）の選択可能
- **ジャンル指定**による例え話のカスタマイズ

### 📝 クイズ機能
- 回答内容から自動生成される**3択クイズ**
- キーワード理解度を測定
- クイズの一括管理とLINE配信設定

### 📱 LINE連携
- LINE Messaging APIとの連携
- クイズの自動配信機能
- Webhook対応でリアルタイム通信

### 👤 ユーザー管理
- **Devise**による認証システム
- ユーザー別の質問・クイズ管理
- LINE アカウント連携

### 📊 学習管理
- 質問履歴の表示
- 回答とクイズの保存
- 一括削除機能

## 🛠 技術スタック

### バックエンド
- **Ruby 3.2.0**
- **Rails 7.1.5+**
- **MySQL** (開発・テスト環境)
- **PostgreSQL** (本番環境)

### フロントエンド
- **Turbo Rails** & **Stimulus**
- **Bootstrap 5.3.3**
- **Sass (Dart Sass)**
- **Import Maps**

### 外部API・サービス
- **Google Vertex AI (Gemini API)** - AI回答生成
- **LINE Messaging API** - メッセージ配信
- **Google Cloud Platform** - 認証・API管理

### 開発・テスト
- **RSpec** - テストフレームワーク
- **Factory Bot** - テストデータ生成
- **Capybara** - システムテスト

## 📊 データベース設計

### Users テーブル
| Column                | Type     | Options                   |
|----------------------|----------|---------------------------|
| id                   | bigint   | primary key              |
| name                 | string   |                          |
| email                | string   |                          |
| encrypted_password   | string   | null: false              |
| line_uid             | string   |                          |
| line_linked          | boolean  |                          |
| reset_password_token | string   |                          |
| reset_password_sent_at | datetime |                        |
| remember_created_at  | datetime |                          |

### Questions テーブル
| Column            | Type       | Options                        |
|------------------|------------|--------------------------------|
| id               | bigint     | primary key                   |
| content          | text       | null: false                   |
| user_id          | bigint     | null: false, foreign_key      |
| answer           | text       |                               |
| answer_text      | text       |                               |
| quiz_question    | text       |                               |
| quiz_choices     | text       |                               |
| quiz_answer      | string     |                               |
| analogy_text     | text       |                               |
| abstraction_level| string     |                               |
| analogy_genre    | string     |                               |

### Quizzes テーブル
| Column        | Type       | Options                        |
|--------------|------------|--------------------------------|
| id           | bigint     | primary key                   |
| quiz_text    | text       | null: false                   |
| quiz_choices | text       |                               |
| quiz_link    | string     |                               |
| send_to_line | boolean    |                               |
| user_id      | bigint     | null: false, foreign_key      |
| question_id  | bigint     | null: false, foreign_key      |

### Answers テーブル
| Column      | Type       | Options                        |
|------------|------------|--------------------------------|
| id         | bigint     | primary key                   |
| content    | text       |                               |
| from_gpt   | boolean    |                               |
| user_id    | bigint     | null: false, foreign_key      |
| question_id| bigint     | null: false, foreign_key      |
| quiz_id    | bigint     | null: false, foreign_key      |



## 📝 使用方法

### 基本的な流れ
1. **ユーザー登録・ログイン**
2. **質問の投稿**
   - 質問内容を入力
   - 抽象化レベルを選択（小学生〜大学生向け）
   - 例え話のジャンルを選択（オプション）
3. **AI回答の生成**
   - Gemini APIが自動で回答・例え話・クイズを生成
4. **クイズの保存・配信**
   - 生成されたクイズをデータベースに保存
   - LINE配信の設定
5. **学習管理**
   - 質問履歴の確認
   - クイズの管理

