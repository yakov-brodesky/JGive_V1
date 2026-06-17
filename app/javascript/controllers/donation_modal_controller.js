import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  static values = { open: Boolean }

  connect() {
    this.scrollY = 0
    this.onKeydown = this.onKeydown.bind(this)

    if (this.openValue) this.open()
  }

  disconnect() {
    this.unlockScroll()
    document.removeEventListener("keydown", this.onKeydown)
  }

  open() {
    this.scrollY = window.scrollY
    this.modalTarget.hidden = false
    this.lockScroll()
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.modalTarget.hidden = true
    this.unlockScroll()
    document.removeEventListener("keydown", this.onKeydown)
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  lockScroll() {
    document.documentElement.classList.add("modal-open")
    document.body.classList.add("modal-open")
    document.body.style.top = `-${this.scrollY}px`
  }

  unlockScroll() {
    document.documentElement.classList.remove("modal-open")
    document.body.classList.remove("modal-open")
    document.body.style.top = ""
    window.scrollTo(0, this.scrollY)
  }
}
