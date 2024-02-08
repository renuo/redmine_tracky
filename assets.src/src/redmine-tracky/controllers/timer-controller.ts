import { Controller } from "@hotwired/stimulus"
import { DateTime, DurationUnits, Duration } from 'luxon';
import { TimeDiff } from '@interfaces/time-diff';

export default class extends Controller {
    readonly startTarget!: HTMLInputElement;
    readonly endTarget!: HTMLInputElement;
    readonly descriptionTarget!: Element;
    readonly labelTarget!: Element;
    readonly timeDiffFields: DurationUnits = ['hours', 'minutes', 'seconds'];
    readonly timeDiffFormat: string = "hh:mm:ss";
    readonly timezoneValue!: number;

    static targets = ['start', 'end', 'label', 'description'];
    static values = {
        timezone: Number
    };

    connect(): void {
        const start = (this.startTarget as HTMLInputElement).value;
        if (start) {
            document.title = '⏱️ Tracky'
        } else {
            document.title = '❌ Tracky'
        }
        const end = (this.endTarget as HTMLInputElement).value;
        if (start && end) {
            const diff: string = this.timeDifference();
            this.updateTimer(
                diff,
            );
        } else if (start) {
            this.startTicker();
        }
    }

    disconnect(): void {
        this.stopTicker();
    }

    private startTicker(): void {
        const updateTime = () => {
            const diff: string = this.timeDifference();
            this.updateTimer(
                diff,
            );
        };

        window.TimerInterval = setInterval(updateTime, 1000);
    }

    private stopTicker(): void {
        if (window.TimerInterval) {
            clearInterval(window.TimerInterval);
        }
    }

    private timeDiffToString(timeDiff: TimeDiff) {
        const sign = (timeDiff.minutes < 0 || timeDiff.seconds < 0) ? '-' : '';
        const [hours, mins, secs] = [timeDiff.hours, timeDiff.minutes, Math.round(timeDiff.seconds)]
                                    .map((value) => value.toString().replace('-', '').padStart(2, '0'));
        const hoursFormat = Number(hours) > 0 ? `${hours}:` : '';
    
        return `${sign}${hoursFormat}${mins}:${secs}`;
    }

    private dateTimeFromTarget(target: HTMLInputElement) {
        const dateTime = this.convertToDateTime(target.value);
        return dateTime.isValid ? dateTime : this.adjustedDateTime();
    }

    private timeDifference() {
        const startDateTime = this.dateTimeFromTarget(this.startTarget);
        const endDateTime = this.dateTimeFromTarget(this.endTarget);
        const duration = endDateTime.diff(startDateTime, this.timeDiffFields);

        return this.timeDiffToString((duration as any).values || {});
    }

    private convertToDateTime(value: string): DateTime {
        return DateTime.fromFormat(
            value,
            window.RedmineTracky.datetimeFormatJavascript
        );
    }

    private updateTimer(time: string) {
        $(this.labelTarget).text(time);
    }

    private adjustedDateTime(): DateTime {
        const localOffset = DateTime.local().offset;
        return DateTime.local().minus({ minutes: localOffset-this.timezoneValue });
    }
}
