export default class TimerUpdater {
	static timerID() {
		return $('[data-timer-id]').val();
	}

	static bind() {
		$(document).ready(() => {
			if(TimerUpdater.timerID() !== '') {
				TimerUpdater.setupUpdaters();
			}
		});
	}

	static setupUpdaters() {
		TimerUpdater.updateComment();
		TimerUpdater.updateStartTime();
		TimerUpdater.updateEndTime();
	}

	static updateStartTime() {
		$('[data-timer-start-input]').off('change');
		$('[data-timer-start-input]').on('change', function() {
			const element = $(this);
			const inputValue = element.val();
			TimerUpdater.sendUpdate({ timer_start: inputValue });
		});
	}

	static updateEndTime(){
		$('[data-timer-end-input]').off('change');
		$('[data-timer-end-input]').on('change', function() {
			const element = $(this);
			const inputValue = element.val();
			TimerUpdater.sendUpdate({ timer_end: inputValue });
		});
	}

	// TODO: implement
	static updateIssue() {

	}

	static updateComment() {
		$('[data-timer-comment-input]').off('change');
		$('[data-timer-comment-input]').on('change', function() {
			const element = $(this);
			const inputValue = element.val();
			TimerUpdater.sendUpdate({ comments: inputValue });
		});
	}

	static disableButtons() {
		const container = $('[data-ending-action-buttons]');
		const buttons = container.find('button');
		buttons.attr('disabled', true);
	}

	static sendUpdate(updateData) {
		TimerUpdater.disableButtons();
		$.ajax({
			type: 'POST',
			url: window.RedmineTracky.trackerUpdatePath,
			data: {
				timer_session: updateData
			},
		})
	}
}
