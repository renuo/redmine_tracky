export default class DateTimePickerRegister {
  static bind() {
    const format = window.RedmineTracky.datetimeFormat
    this.cleanup()

    $('.datetime-picker').each((_, elem) => {
      const element = $(elem) as any
      element.datetimepicker('destroy')
      element.datetimepicker({ format, step: 1 })
    })
  }

  static cleanup() {
    $('.xdsoft_datetimepicker').remove()
  }
}
