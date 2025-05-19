// app/javascript/controllers/enter_submit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "form"]
 
  connect() {
    console.log("✅ EnterSubmitController connected!")
    this.textareaTarget.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        this.formTarget.requestSubmit()
      }
    })
  }
}