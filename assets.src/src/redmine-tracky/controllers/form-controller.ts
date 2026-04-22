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
  declare readonly shareCopiedMessageValue: string
  declare readonly sharePrefilledMessageValue: string
  declare readonly shareIgnoredMessageValue: string
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
    shareCopiedMessage: String,
    sharePrefilledMessage: String,
    shareIgnoredMessage: String,
    sessionActive: Boolean,
  }

  public connect() {
    this.connected = true
    if (this.sessionActiveValue) {
      this.showShareIgnoredNotice()
    } else {
      this.prefillFieldsFromURL()
    }
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

  public share(event: Event) {
    event.preventDefault()

    const params = new URLSearchParams()
    this.extractIssueIds().forEach((id) => params.append('issue_ids[]', id))
    if (this.descriptionTarget.value) params.set('comments', this.descriptionTarget.value)
    if (this.startTarget.value) params.set('timer_start', this.startTarget.value)
    if (this.endTarget.value) params.set('timer_end', this.endTarget.value)

    const url = new URL(window.location.pathname, window.location.origin)
    url.search = params.toString()

    navigator.clipboard.writeText(url.toString()).then(() => {
      this.showFlash(this.shareCopiedMessageValue, 'notice')
    })
  }

  private prefillFieldsFromURL() {
    const urlParams = new URLSearchParams(window.location.search)

    const prefilled = [
      this.prefillField(urlParams, 'comments', this.descriptionTarget),
      this.prefillField(urlParams, 'timer_start', this.startTarget),
      this.prefillField(urlParams, 'timer_end', this.endTarget),
    ].some(Boolean)

    if (prefilled) {
      this.showFlash(this.sharePrefilledMessageValue, 'notice')
      this.clearShareParams()
    }
  }

  private clearShareParams() {
    // Defer so child controllers (e.g. issue-completion) can read the URL before we wipe it.
    setTimeout(() => {
      const url = new URL(window.location.href)
      url.searchParams.delete('comments')
      url.searchParams.delete('timer_start')
      url.searchParams.delete('timer_end')
      url.searchParams.delete('issue_ids[]')
      window.history.replaceState({}, '', url.toString())
    }, 0)
  }

  private prefillField(urlParams: URLSearchParams, param: string, target: HTMLInputElement): boolean {
    const value = urlParams.get(param)
    if (!value) return false

    target.value = value
    target.dispatchEvent(new Event('change'))
    return true
  }

  private showShareIgnoredNotice() {
    if (!this.sessionActiveValue) return

    const urlParams = new URLSearchParams(window.location.search)
    const hasShareParams = urlParams.has('comments') ||
      urlParams.has('timer_start') ||
      urlParams.has('timer_end') ||
      urlParams.getAll('issue_ids[]').some((v) => v !== '')

    if (hasShareParams) {
      this.showFlash(this.shareIgnoredMessageValue, 'warning')
      this.clearShareParams()
    }
  }

  private showFlash(message: string, type: 'notice' | 'warning') {
    const flashId = `flash_${type}`
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
    flash.className = `flash ${type}`
    flash.textContent = message
    container.prepend(flash)
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
