export default class TimerUpdater {
    static timerID() {
        return $('[data-timer-id]').val();
    }

    static bind() {
        $(document).ready(() => {
            if (TimerUpdater.timerID() !== '') {
                const timerUpdater = new TimerUpdater();
                timerUpdater.setupUpdaters();
            }
        });
    }

    setupUpdaters() {
        this.updateComment();
        this.updateStartTime();
        this.updateEndTime();
    }

    updateStartTime() {
        $('[data-timer-start-input]').off('blur');
        $('[data-timer-start-input]').on('blur', () => {
            const element = event.target

            new TimerUpdater().sendUpdate({
                timer_start: element.value
            });
        });
    }

    updateEndTime() {
        $('[data-timer-end-input]').off('blur');
        $('[data-timer-end-input]').on('blur', () => {
            const element = event.target;

            new TimerUpdater().sendUpdate({
                timer_end: element.value
            });
        });
    }

    static updateIssue() {
        if (!TimerUpdater.timerID()) {
            return;
        }
        const ids = $("input[name^='timer_session[issue_ids]']").map(function() {
            return $(this).val();
        }).get() || [''];


        new TimerUpdater().sendUpdate({
            issue_ids: ids.length ? Array.from(new Set(ids)) : [' ']
        });
    }

    updateComment() {
        $('[data-timer-comment-input]').off('blur');
        $('[data-timer-comment-input]').on('blur', () => {
            const element = $(event.target);
            const inputValue = element.val();
            this.sendUpdate({
                comments: inputValue
            });
        });
    }

    sendUpdate(updateData) {
        $.ajax({
            type: 'POST',
            url: window.RedmineTracky.trackerUpdatePath,
            data: {
                timer_session: updateData
            },
        })
    }
}
