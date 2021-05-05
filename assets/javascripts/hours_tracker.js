export default class HoursTracker {

	// TODO: rewrite and implement cleaner
	static bind() {
		if (!$('[data-timer-id]').val()) {
			return;
		}
		// TODO: refactor
		if(window.timerInterval) {
			clearInterval(window.timerInterval);
		}

		const timerStartValue = $('[data-timer-start-input]').val();
		const timerEndValue = $('[data-timer-end-input]').val();

		const timerStartDateTime = luxon.DateTime.fromFormat(
			timerStartValue,
			window.RedmineTracky.datetimeFormatJavascript
		);
	
		let timerEndDateTime;
		
		if(timerEndValue === '') {
			timerEndDateTime = luxon.DateTime.local();
		} else {
			timerEndDateTime = luxon.DateTime.fromFormat(
				timerEndValue, 
				window.RedmineTracky.datetimeFormatJavascript
			);
		}

		const difference = HoursTracker.roundDifferences(timerEndDateTime.diff(timerStartDateTime,
			['hours', 'minutes', 'seconds']).toObject());

		if(timerEndValue === '') {
			HoursTracker.tickTimer(difference);
		} else {
			HoursTracker.displayTimer(difference);
		}
	}

	static roundDifferences(timerObject) {
		timerObject.seconds = Math.round(timerObject.seconds);
		return timerObject;
	}

	// TODO: rewrite and implement cleaner
	static tickTimer(timerObject) {
		const updateTime = function() {
			timerObject.seconds += 1;
			if(timerObject.seconds >= 60) {
				timerObject.seconds = 0;
				timerObject.minutes += 1;
				if(timerObject.minutes >= 60) {
					timerObject.minutes = 0;
					timerObject.hours += 1;
				}
			}
			HoursTracker.displayTimer(timerObject);
		};

		window.timerInterval = setInterval(updateTime, 1000);
	}

	static displayTimer(timerObject) {
		$('#hours-clock').text(HoursTracker.formatTimer(timerObject));
	}

	static padNumber(n, width) {
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
	}

	static formatTimer(timerObject) {
		const minutes = HoursTracker.padNumber(timerObject.minutes, 2);
		const seconds = HoursTracker.padNumber(timerObject.seconds, 2);
		if (timerObject.hours > 0) {
			return `${timerObject.hours}:${minutes}:${seconds}`;
		} else {
			return `${minutes}:${seconds}`;
		}
	}
}
