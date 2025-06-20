import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-to"
export default class extends Controller {
  scroll(event) {
    // リンクがクリックされたときの元々の動き（ページ遷移など）を止める
    event.preventDefault()

    // リンクのhref属性（例: "#question_123"）を取得
    const targetId = event.currentTarget.getAttribute("href")
    
    // href属性の値を使って、ページ内の該当する要素を探す
    const targetElement = document.querySelector(targetId)

    // 要素が見つかったら、そこまでスムーズにスクロールする
    if (targetElement) {
      targetElement.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }
} 