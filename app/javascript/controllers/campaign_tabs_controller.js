import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link", "panel"]

  connect() {
    this.selectByHash(window.location.hash || "#project", false)
  }

  navigate(event) {
    const hash = event.currentTarget.hash
    if (!hash) return

    event.preventDefault()
    this.selectByHash(hash, true)
  }

  selectByHash(hash, pushHistory) {
    const selectedPanel = this.panelTargets.find((panel) => `#${panel.id}` === hash) || this.panelTargets[0]
    if (!selectedPanel) return

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel !== selectedPanel
    })

    this.linkTargets.forEach((link) => {
      const selected = link.hash === `#${selectedPanel.id}`
      link.classList.toggle("is-active", selected)
      link.setAttribute("aria-selected", selected.toString())
      link.tabIndex = selected ? 0 : -1
    })

    if (pushHistory) {
      window.history.pushState({}, "", `#${selectedPanel.id}`)
    }
  }

  next(event) {
    event.preventDefault()
    this.selectByOffset(1)
  }

  previous(event) {
    event.preventDefault()
    this.selectByOffset(-1)
  }

  selectByOffset(offset) {
    const currentIndex = this.linkTargets.findIndex((link) => link.getAttribute("aria-selected") === "true")
    const nextIndex = (currentIndex + offset + this.linkTargets.length) % this.linkTargets.length
    const nextLink = this.linkTargets[nextIndex]

    nextLink.focus()
    this.selectByHash(nextLink.hash, true)
  }
}
