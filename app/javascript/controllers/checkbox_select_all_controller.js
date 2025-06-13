import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="checkbox-select-all"
export default class extends Controller {
  static targets = ["master", "child"]

  connect() {
    // このコントローラーがHTMLに接続されたときに、コンソールにメッセージを出します
    console.log("✅ CheckboxSelectAll controller connected!", this.element);
    // master と child を見つけられたかどうかも報告させます
    console.log("  Master checkbox:", this.hasMasterTarget ? this.masterTarget : "NOT FOUND");
    console.log("  Child checkboxes found:", this.childTargets.length);
  }

  toggle() {
    // チェックボックスがクリックされた時に、ちゃんと反応しているかメッセージを出します
    console.log("▶️ Toggle action triggered!");
    console.log("  Master is now:", this.masterTarget.checked ? "Checked" : "Unchecked");

    this.childTargets.forEach(child => {
      child.checked = this.masterTarget.checked
    })
    console.log("  All child checkboxes updated.");
  }
} 