import { Controller } from "@hotwired/stimulus"

// フォームのEnterキー送信を制御するコントローラー
export default class extends Controller {
  
  // textareaでキーが押された時に呼び出されるアクション
  onKeyPress(event) {
    // 押されたキーが「Enter」で、かつ「Shift」が押されていない場合
    if (event.key === 'Enter' && !event.shiftKey) {
      // デフォルトの動作（改行）をキャンセル
      event.preventDefault();
      
      // ▼▼▼ フォーム内の送信ボタンを探して、それをクリックする方式に変更 ▼▼▼
      const submitButton = this.element.form.querySelector('input[type="submit"], button[type="submit"]');
      if (submitButton) {
        submitButton.click();
      }
    }
  }
} 