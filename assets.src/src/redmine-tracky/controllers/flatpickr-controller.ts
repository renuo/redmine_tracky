import Flatpickr from 'stimulus-flatpickr'

export default class extends Flatpickr {
  open(_selectedDates: Date[], dateStr: string, instance: any) {
    if (!dateStr) {
      instance.setDate(this.defaultDate())
    }
  }

  // Sessions started before today rarely run overnight, so an empty end defaults to the start instead of now
  private defaultDate(): Date | number {
    const start = this.startDateOfSession()
    const startOfToday = new Date().setHours(0, 0, 0, 0)

    if (start && start.getTime() < startOfToday) {
      return start
    }

    return Date.now()
  }

  private startDateOfSession(): Date | undefined {
    if (this.element.getAttribute('data-form-target') !== 'end') return

    const startInput = this.element
      .closest('form')
      ?.querySelector('[data-form-target="start"]') as any

    return startInput?._flatpickr?.selectedDates[0]
  }
}
