export default class DateTimePickerRegister {
	static bind() {
		const dateFormat = window.RedmineTracky.datetimeFormat;
		$('.datetime-picker').each((index, element) => {
			$(element).datetimepicker({
				format: dateFormat,
				step: 1
			});
		});
	}
}	
