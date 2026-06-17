import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "sort", "grid", "card", "empty"]

  connect() {
    this.filter()
  }

  preventSubmit(event) {
    event.preventDefault()
    this.filter()
  }

  filter() {
    const query = this.normalize(this.queryTarget.value)
    const cards = [...this.cardTargets]
    let visibleCount = 0

    this.sortCards(cards)

    cards.forEach((card) => {
      const matches = this.normalize(card.dataset.searchText).includes(query)
      card.hidden = !matches
      if (matches) visibleCount += 1
    })

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = visibleCount !== 0
    }
  }

  sortCards(cards) {
    const sortedCards = cards.sort((a, b) => {
      if (this.sortTarget.value === "amount") {
        return Number(b.dataset.amountCents) - Number(a.dataset.amountCents)
      }

      return Number(b.dataset.createdAt) - Number(a.dataset.createdAt)
    })

    sortedCards.forEach((card) => this.gridTarget.appendChild(card))
  }

  normalize(value) {
    return (value || "").toString().trim().toLowerCase()
  }
}
