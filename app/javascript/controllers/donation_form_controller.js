import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "notePanel",
    "noteCheckbox",
    "dedicationPanel",
    "dedicationToggle",
    "honoreeLabel",
    "honoreeField",
    "recipientNamePanel",
    "memoryRadio"
  ]

  connect() {
    this.syncNote()
    this.syncDedication()
    this.syncDedicationType()
  }

  toggleNote() {
    this.syncNote()
  }

  toggleDedication() {
    this.syncDedication()
  }

  updateDedicationType() {
    this.syncDedicationType()
  }

  syncNote() {
    if (!this.hasNotePanelTarget || !this.hasNoteCheckboxTarget) return

    this.notePanelTarget.hidden = !this.noteCheckboxTarget.checked
  }

  syncDedication() {
    if (!this.hasDedicationPanelTarget || !this.hasDedicationToggleTarget) return

    this.dedicationPanelTarget.hidden = !this.dedicationToggleTarget.checked
  }

  syncDedicationType() {
    const isMemory = this.hasMemoryRadioTarget && this.memoryRadioTarget.checked
    const label = isMemory ? "לזכר מי ההקדשה" : "לכבוד מי ההקדשה"

    if (this.hasHonoreeLabelTarget) {
      this.honoreeLabelTarget.innerHTML = `${label} <span class="required">*</span>`
    }

    if (this.hasHonoreeFieldTarget) {
      this.honoreeFieldTarget.placeholder = label
    }

    if (this.hasRecipientNamePanelTarget) {
      this.recipientNamePanelTarget.hidden = !isMemory
    }
  }
}
