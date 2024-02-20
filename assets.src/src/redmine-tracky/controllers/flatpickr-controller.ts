import Flatpickr from 'stimulus-flatpickr'

export default class extends Flatpickr {
  open(_selectedDates: Date[], dateStr: String, instance: any) {
    if (!dateStr) {
      instance.setDate(Date.now())
    }
  }
}
