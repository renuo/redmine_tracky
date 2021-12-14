export default class DateTimePickerRegister {
  static bind() {
    const dateFormat = window.RedmineTracky.datetimeFormat;
    this.cleanup();

    $(".datetime-picker").each((index, element) => {
      $(element).datetimepicker("destroy");
      $(element).datetimepicker({
        format: dateFormat,
        step: 1,
      });
    });
  }

  static cleanup() {
    $(".xdsoft_datetimepicker").remove();
  }
}
