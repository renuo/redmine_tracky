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

  private connected = false

  static targets = [
    'description',
    'start',
    'stopButton',
    'end',
    'issue',
    'absolutInput',
  ]

  public connect() {
    this.connected = true
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
