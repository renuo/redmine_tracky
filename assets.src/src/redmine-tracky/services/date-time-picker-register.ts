export default class DateTimePickerRegister {
    static bind() {
        const dateFormat = window.RedmineTracky.datetimeFormat;
        this.cleanup();

        $(".datetime-picker").each((index, element) => {
            ($(element) as any).datetimepicker("destroy");
            ($(element) as any).datetimepicker({
                format: dateFormat,
                step: 1,
            });
        });
    }

    static cleanup() {
        $(".xdsoft_datetimepicker").remove();
    }
}
