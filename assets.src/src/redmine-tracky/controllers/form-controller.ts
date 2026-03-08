import { Controller } from '@hotwired/stimulus'
import { DateTime } from 'luxon'
import { FormData } from '@interfaces/form-data'

export default class extends Controller {
  declare readonly startTarget: HTMLInputElement
  declare readonly hasStopButtonTarget: boolean
  declare readonly endTarget: HTMLInputElement
  declare readonly absolutInputTarget: HTMLInputElement
  declare readonly descriptionTarget: HTMLInputElement
  declare readonly issueTargets: Element[]
  declare readonly shareCopiedValue: string
  declare readonly shareIgnoredValue: string
  declare readonly sessionActiveValue: boolean

  private connected = false

  static targets = [
    'description',
    'start',
    'stopButton',
    'end',
    'issue',
    'absolutInput',
  ]

  static values = {
    shareCopied: String,
    shareIgnored: String,
    sessionActive: Boolean,
  }

  public connect() {
    this.connected = true
    this.showShareIgnoredNotice()
  }

  public disconnect() {
    this.connected = false
  }

  public absoluteTime(_event: Event) {
    try {
      const value = parseFloat(this.absolutInputTarget.value)
      const startDate = this.convertToDateTime(this.startTarget.value)

      if (value && startDate.isValid) {
        const newEndDate = startDate.plus({ hours: value })
        this.endTarget.value = newEndDate.toFormat('dd.LL.yyyy HH:mm')
        this.endTarget.dispatchEvent(new Event('change'))
      }
    } finally {
      this.absolutInputTarget.value = ''
    }
  }

  public issueTargetConnected(_: Element) {
    if (this.connected) {
      this.change()
    }
  }

  public issueTargetDisconnected(_: Element) {
    if (this.connected) {
      this.change()
    }
  }

  public change() {
    const form: FormData = {
      timer_start: this.startTarget.value,
      timer_end: this.endTarget.value,
      comments: this.descriptionTarget.value,
      issue_ids: this.extractIssueIds() || [],
    }

    this.dispatchUpdate(form)
  }

  public share(_event: Event) {
    const parts: string[] = []
    const issueIds = this.extractIssueIds()
    const comments = this.descriptionTarget.value
    const timerStart = this.startTarget.value
    const timerEnd = this.endTarget.value

    issueIds.forEach((id) => parts.push(`issue_ids[]=${encodeURIComponent(id)}`))
    if (comments) parts.push(`comments=${encodeURIComponent(comments)}`)
    if (timerStart) parts.push(`timer_start=${encodeURIComponent(timerStart)}`)
    if (timerEnd) parts.push(`timer_end=${encodeURIComponent(timerEnd)}`)

    const query = parts.length > 0 ? `?${parts.join('&')}` : ''
    const url = `${window.location.origin}${window.location.pathname}${query}`

    this.copyToClipboard(url).then(() => {
      this.showFlashNotice(this.shareCopiedValue)
    })
  }

  private copyToClipboard(text: string): Promise<void> {
    if (navigator.clipboard?.writeText) {
      return navigator.clipboard.writeText(text).catch(() => {
        this.copyToClipboardFallback(text)
      })
    }
    this.copyToClipboardFallback(text)
    return Promise.resolve()
  }

  private copyToClipboardFallback(text: string) {
    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
  }

  private showShareIgnoredNotice() {
    if (!this.sessionActiveValue) return

    const urlParams = new URLSearchParams(window.location.search)
    const hasShareParams = urlParams.has('comments') ||
      urlParams.has('timer_start') ||
      urlParams.has('timer_end') ||
      urlParams.getAll('issue_ids[]').some((v) => v !== '')

    if (hasShareParams) {
      this.showFlashNotice(this.shareIgnoredValue)
    }
  }

  private showFlashNotice(message: string) {
    const flash = document.getElementById('flash_notice')
    if (flash) {
      flash.textContent = message
      flash.style.display = ''
      return
    }

    const container = document.getElementById('content')
    if (!container) return

    const notice = document.createElement('div')
    notice.id = 'flash_notice'
    notice.className = 'flash notice'
    notice.textContent = message
    container.prepend(notice)
  }

  private extractIssueIds(): string[] {
    return (
      this.issueTargets
        .map((element) => element.getAttribute('data-issue-id') || '')
        .filter((value) => value !== null) || []
    )
  }

  private dispatchUpdate(form: FormData) {
    if (this.hasStopButtonTarget) {
      $.ajax({
        type: 'POST',
        url: window.RedmineTracky.trackerUpdatePath,
        data: { timer_session: form },
        async: true,
      })
    }
  }

  private convertToDateTime(value: string) {
    return DateTime.fromFormat(
      value,
      window.RedmineTracky.datetimeFormatJavascript,
    )
  }
}
