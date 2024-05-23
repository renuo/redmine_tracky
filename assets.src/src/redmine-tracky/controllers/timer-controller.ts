import { Controller } from '@hotwired/stimulus'
import { DateTime, Duration, DurationUnits } from 'luxon'
import { TimeDiff } from '@interfaces/time-diff'

export default class extends Controller {
  declare readonly startTarget: HTMLInputElement
  declare readonly endTarget: HTMLInputElement
  declare readonly descriptionTarget: HTMLInputElement
  declare readonly labelTarget: HTMLInputElement
  declare readonly timezoneValue: number
  readonly timeDiffFields: DurationUnits = ['hours', 'minutes', 'seconds']
  readonly timeDiffFormat = 'hh:mm:ss'

  static targets = ['start', 'end', 'label', 'description']
  static values = { timezone: Number }

  connect() {
    const start = this.startTarget.value
    const end = this.endTarget.value

    if (start) {
      document.title = '⏱️ Tracky'
    } else {
      document.title = '❌ Tracky'
    }

    if (start && end) {
      const diff: string = this.timeDifference()
      this.updateTimer(diff)
    } else if (start) {
      this.startTicker()
    }
  }

  disconnect() {
    this.stopTicker()
  }

  private startTicker() {
    const updateTime = () => {
      const diff = this.timeDifference()
      this.updateTimer(diff)
    }

    window.TimerInterval = setInterval(updateTime, 1000)
  }

  private stopTicker() {
    if (window.TimerInterval) {
      clearInterval(window.TimerInterval)
    }
  }

  private timeDiffToString(timeDiff: TimeDiff) {
    const duration = Duration.fromObject(timeDiff)
    const formattedDuration = duration.toFormat('hh:mm:ss').replaceAll('-', '')
    const sign = Object.values(timeDiff).some((value) => value < 0) ? '-' : ''
    return sign + formattedDuration
  }

  private dateTimeFromTarget(target: HTMLInputElement) {
    const dateTime = this.convertToDateTime(target.value)
    return dateTime.isValid ? dateTime : this.adjustedDateTime()
  }

  private timeDifference() {
    const startDateTime = this.dateTimeFromTarget(this.startTarget)
    const endDateTime = this.dateTimeFromTarget(this.endTarget)
    const duration = endDateTime.diff(startDateTime, this.timeDiffFields)

    return this.timeDiffToString((duration as any).values || {})
  }

  private convertToDateTime(value: string) {
    return DateTime.fromFormat(
      value,
      window.RedmineTracky.datetimeFormatJavascript,
    )
  }

  private updateTimer(time: string) {
    $(this.labelTarget).text(time)
  }

  private adjustedDateTime() {
    const localOffset = DateTime.local().offset
    return DateTime.local().minus({ minutes: localOffset - this.timezoneValue })
  }
}
