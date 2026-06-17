import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "notePanel",
    "noteCheckbox",
    "dedicationPanel",
    "dedicationToggle",
    "honoreeLabel",
    "honoreeField",
    "memoryRadio"
  ]

  connect() {
    this.syncNote()
    this.syncDedication()
    this.syncHonoreeLabel()
  }

  toggleNote() {
    this.syncNote()
  }

  toggleDedication() {
    this.syncDedication()
  }

  updateDedicationType() {
    this.syncHonoreeLabel()
  }

  syncNote() {
    if (!this.hasNotePanelTarget || !this.hasNoteCheckboxTarget) return

    this.notePanelTarget.hidden = !this.noteCheckboxTarget.checked
  }

  syncDedication() {
    if (!this.hasDedicationPanelTarget || !this.hasDedicationToggleTarget) return

    this.dedicationPanelTarget.hidden = !this.dedicationToggleTarget.checked
  }

  syncHonoreeLabel() {
    if (!this.hasHonoreeLabelTarget) return

    const isMemory = this.hasMemoryRadioTarget && this.memoryRadioTarget.checked
    const label = isMemory ? "לזכר מי ההקדשה" : "לכבוד מי ההקדשה"

    this.honoreeLabelTarget.textContent = label

    if (this.hasHonoreeFieldTarget) {
      this.honoreeFieldTarget.placeholder = label
    }
  }
}
