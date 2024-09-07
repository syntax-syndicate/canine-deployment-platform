import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "card"]
  static values = { repository: String }

  connect() {
    console.log("HelmChartSelector controller connected")
  }

  selectChart(event) {
    event.preventDefault()
    this.inputTarget.value = event.currentTarget.dataset.newAddOnsRepositoryValue
    this.cardTargets.forEach(card => card.classList.remove('ring', 'ring-primary'))
    event.currentTarget.classList.add('ring', 'ring-primary')
  }
}