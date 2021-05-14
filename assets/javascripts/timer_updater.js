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
        $('[data-timer-start-input]').off('change');
        $('[data-timer-start-input]').on('change', () => {
            const element = $(event.target);
            const inputValue = element.val();
            new TimerUpdater().sendUpdate({
                timer_start: inputValue
            });
        });
    }

    updateEndTime() {
        $('[data-timer-end-input]').off('change');
        $('[data-timer-end-input]').on('change', () => {
            const element = $(event.target);
            const inputValue = element.datetimepicker('getValue');
            new TimerUpdater().sendUpdate({
                timer_end: inputValue
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
        $('[data-timer-comment-input]').off('change');
        $('[data-timer-comment-input]').on('change', () => {
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