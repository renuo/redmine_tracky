export default class DateTimePickerRegister {
	static bind() {
		$(document).ready(() => {
			$('.datetime-picker').each((index, element) => {
				$(element).datetimepicker({
					step: 1
				});
			});
		});
	}
}	
