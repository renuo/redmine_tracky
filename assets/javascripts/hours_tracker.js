export default class HoursTracker {

	static bind() {
		if (!$('[data-timer-id]').val()) {
			return;
		}
		const hoursTracker = new HoursTracker();
		hoursTracker.run();
	}

	run() {
		this.endTicker();
		const [difference, tick] = this.timeDifference();
		if(tick){
			this.tickTimer(difference);
		} else {
			this.displayTimer(difference);
		}
	}

	dateElements () {
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
		return [[timerStartDateTime, timerEndDateTime], timerEndValue === ''];
	}

	timeDifference() {
		const [timerValues, tick] = this.dateElements();
		return [this.roundDifferences(timerValues[1].diff(timerValues[0],
			['hours', 'minutes', 'seconds']).toObject()), tick];
	}

	endTicker() {
		if(window.timerInterval) {
			clearInterval(window.timerInterval);
		}
	}

	roundDifferences(timerObject) {
		timerObject.seconds = Math.round(timerObject.seconds);
		return timerObject;
	}

	// TODO: rewrite and implement cleaner
	tickTimer(timerObject) {
		const updateTime = () => {
			timerObject.seconds += 1;
			if(timerObject.seconds >= 60) {
				timerObject.seconds = 0;
				timerObject.minutes += 1;
				if(timerObject.minutes >= 60) {
					timerObject.minutes = 0;
					timerObject.hours += 1;
				}
			}
			this.displayTimer(timerObject);
		};

		window.timerInterval = setInterval(updateTime, 1000);
	}

	displayTimer(timerObject) {
		const formatedTimer = this.formatTimer(timerObject);
		$('#hours-clock').text(formatedTimer);
		this.setTitle(formatedTimer);
	}

	padNumber(n, width) {
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
	}

	setTitle(time){
		document.title = `${window.RedmineTracky.documentTitle} - ${time}`;
	}

	formatTimer(timerObject) {
		const minutes = this.padNumber(timerObject.minutes, 2);
		const seconds = this.padNumber(timerObject.seconds, 2);
		if (timerObject.hours > 0) {
			return `${timerObject.hours}:${minutes}:${seconds}`;
		} else {
			return `${minutes}:${seconds}`;
		}
	}
}
