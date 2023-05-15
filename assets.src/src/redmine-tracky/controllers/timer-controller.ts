import { Controller } from "@hotwired/stimulus"
import { DateTime, DurationUnits, Duration } from 'luxon';
import { TimeDiff, timeDiffToString } from '@interfaces/time-diff';

export default class extends Controller {
    readonly startTarget!: Element;
    readonly endTarget!: Element;
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

    private timeDifference(): string {
        const startDateTime = this.convertToDateTime((this.startTarget as HTMLInputElement).value);
        const endDateTime = this.convertToDateTime((this.endTarget as HTMLInputElement).value);

        const duration: Duration = (endDateTime.isValid ? endDateTime : this.adjustedDateTime()).diff(
            startDateTime.isValid ? startDateTime : this.adjustedDateTime(),
            this.timeDiffFields
        );

        const timeDiff: TimeDiff = (duration as any).values as TimeDiff || {};

        return timeDiffToString(timeDiff);
    }

    private convertToDateTime(value: string): DateTime {
        return DateTime.fromFormat(
            value,
            window.RedmineTracky.datetimeFormatJavascript
        );
    }

    private updateTimer(time: string): void {
        time = time.split(':').map((t) => t.padStart(2, '0')).join(':')
        $(this.labelTarget).text(
            this.handleNegativeTime(time)
        );
    }

    private handleNegativeTime(time: string): string {
        if (time.startsWith('-')) {
            return `-${time.replace(/-/g, '')}`;
        }
        return time;
    }
    
    private adjustedDateTime(): DateTime {
        const localOffset = DateTime.local().offset;
        return DateTime.local().minus({ minutes: localOffset-this.timezoneValue });
    }

}
