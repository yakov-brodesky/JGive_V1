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
    "memoryRadio",
    "amountRadio",
    "customAmount",
    "totalAmount"
  ]

  connect() {
    this.syncNote()
    this.syncDedication()
    this.syncDedicationType()
    this.updateTotal()
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

  selectPresetAmount() {
    if (this.hasCustomAmountTarget) {
      this.customAmountTarget.value = ""
    }

    this.updateTotal()
  }

  enterCustomAmount() {
    if (this.hasCustomAmountTarget && this.customAmountTarget.value.trim()) {
      this.amountRadioTargets.forEach((radio) => {
        radio.checked = false
      })
    }

    this.updateTotal()
  }

  updateTotal() {
    if (!this.hasTotalAmountTarget) return

    const amountCents = this.selectedAmountCents()
    this.totalAmountTarget.textContent = amountCents ? this.formatIls(amountCents) : "ייבחר בטופס"
  }

  selectedAmountCents() {
    const customAmount = this.hasCustomAmountTarget ? this.customAmountTarget.value.trim() : ""

    if (customAmount) {
      const parsed = Number.parseFloat(customAmount)
      return Number.isFinite(parsed) && parsed > 0 ? Math.round(parsed * 100) : null
    }

    const selectedOption = this.amountRadioTargets.find((radio) => radio.checked)
    if (!selectedOption) return null

    const amountCents = Number.parseInt(selectedOption.dataset.amountCents, 10)
    return Number.isFinite(amountCents) && amountCents > 0 ? amountCents : null
  }

  formatIls(cents) {
    const shekels = Math.round(cents / 100)
    return `\u20AA${shekels.toLocaleString("he-IL")}`
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
