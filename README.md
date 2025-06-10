# Quiz Study App

質問を投稿し、AIが回答とクイズを生成するアプリケーション。

## データベース設計

### Users テーブル

| Column                | Type    | Options                   |
|----------------------|---------|---------------------------|
| name                 | string  |                           |
| email                | string  |                           |
| encrypted_password   | string  | null: false              |
| line_uid             | string  | unique: true             |
| line_linked          | boolean |                           |
| reset_password_token | string  |                           |
| remember_created_at  | datetime|                           |

#### Association
- has_many :questions

### Questions テーブル

| Column        | Type       | Options                        |
|--------------|------------|--------------------------------|
| content      | text       | null: false                    |
| user         | references | null: false, foreign_key: true |
| answer_text  | text       |                                |
| quiz_question| text       |                                |
| quiz_choices | text       |                                |
| quiz_answer  | string     |                                |

#### Association
- belongs_to :user
- has_many :answers
- has_many :quizzes

### Answers テーブル

| Column      | Type       | Options                        |
|------------|------------|--------------------------------|
| content    | text       | null: false                    |
| from_gpt   | boolean    |                                |
| question   | references | null: false, foreign_key: true |

#### Association
- belongs_to :question

### Quizzes テーブル

| Column       | Type       | Options                        |
|-------------|------------|--------------------------------|
| quiz_text   | text       | null: false                    |
| send_to_line| boolean    |                                |
| question    | references | null: false, foreign_key: true |

#### Association
- belongs_to :question
- has_many :answers

## 機能一覧

1. ユーザー認証（Devise）
   - サインアップ
   - ログイン/ログアウト
   - パスワードリセット

2. LINE連携
   - LINEアカウントとの連携
   - クイズのLINE配信

3. 質問管理
   - 質問の投稿
   - 質問一覧の表示
   - 質問詳細の表示

4. AI回答生成（Gemini API）
   - 質問に対する回答の自動生成
   - クイズの自動生成

5. クイズ機能
   - 三択クイズの生成
   - クイズの回答
   - 正解の表示
