import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "textarea"]

  connect() {
    this.textareaTarget.addEventListener("keydown", this.handleKeyPress.bind(this))
  }

  disconnect() {
    this.textareaTarget.removeEventListener("keydown", this.handleKeyPress.bind(this))
  }

  handleKeyPress(event) {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }
} 