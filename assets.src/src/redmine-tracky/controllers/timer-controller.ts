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

            this.updateTab(
                diff,
                (this.descriptionTarget as HTMLInputElement).value
            );
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

    private updateTab(time: string, description: string): void {
        document.title = this.formatValues(time, description);
    }

    private updateTimer(time: string): void {
        $(this.labelTarget).text(
            time
        );
    }

    private formatValues(time: string, description: string): string {
        const components = [time, description];
        return components.filter(el => {
            return el != null && el != '';
        }).join(' - ');
    }

    private adjustedDateTime(): DateTime {
        const localOffset = DateTime.local().offset / 60;
        return DateTime.local().plus({ hours: (localOffset-this.timezoneValue)*-1 });
    }
}
