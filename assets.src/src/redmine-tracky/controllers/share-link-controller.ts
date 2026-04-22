import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLAnchorElement> {
  declare readonly copiedMessageValue: string

  static values = {
    copiedMessage: String,
  }

  public copy(event: Event) {
    event.preventDefault()
    const href = this.element.href
    const url = new URL(href, window.location.origin).toString()

    navigator.clipboard.writeText(url).then(() => {
      this.showFlash(this.copiedMessageValue)
    })
  }

  private showFlash(message: string) {
    const flashId = 'flash_notice'
    const existing = document.getElementById(flashId)
    if (existing) {
      existing.textContent = message
      existing.style.display = ''
      return
    }

    const container = document.getElementById('content')
    if (!container) return

    const flash = document.createElement('div')
    flash.id = flashId
    flash.className = 'flash notice'
    flash.textContent = message
    container.prepend(flash)
  }
}
