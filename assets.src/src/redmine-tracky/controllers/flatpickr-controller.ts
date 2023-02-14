import Flatpickr from 'stimulus-flatpickr';

export default class extends Flatpickr {
    open(_selectedDates: Array<Date>, dateStr: String, instance: any) {
        if (!dateStr) {
            instance.setDate(Date.now());
        }
    }
}
