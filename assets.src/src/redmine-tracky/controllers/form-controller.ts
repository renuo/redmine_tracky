import { Controller } from "@hotwired/stimulus"
import { DateTime, DurationUnits, Duration } from 'luxon';
import { FormData } from '@interfaces/form-data';

export default class extends Controller {
    readonly startTarget!: Element;
    readonly endTarget!: Element;
    readonly absolutInputTarget!: Element;
    readonly descriptionTarget!: Element;
    readonly issueTargets!: Array<Element>;

    private connected = false;

    static targets = ['description', 'start', 'end', 'issue', 'absolutInput'];

    public connect(): void {
        this.connected = true;
    }

    public disconnect(): void {
        this.connected = false;
    }

    public absoluteTime(event: Event): void {
        try {
            const value = parseFloat((this.absolutInputTarget as HTMLInputElement).value);
            const startDate: DateTime = this.convertToDateTime(this.valueForInput(this.startTarget));

            if (value && startDate.isValid) {
                const newEndDate: DateTime = startDate.plus({ hours: value });
                console.log(newEndDate);

                (this.endTarget as HTMLInputElement).value = newEndDate.toFormat(
                    'dd.LL.yyyy HH:mm'
                );

                this.endTarget.dispatchEvent(new Event('change'));
            }
        } finally {
            (this.absolutInputTarget as HTMLInputElement).value = '';
        }
    }

    public issueTargetConnected(_: Element) {
        if (this.connected) {
            this.change();
        }
    }

    public issueTargetDisconnected(_: Element) {
        if (this.connected) {
            this.change();
        }
    }

    public change(): void {
        const form: FormData = {
            timer_start: (this.startTarget as HTMLInputElement).value,
            timer_end: (this.endTarget as HTMLInputElement).value,
            comments: (this.descriptionTarget as HTMLInputElement).value,
            issue_ids: this.extractIssueIds() || []
        };

        this.dispatchUpdate(form);
    }

    private extractIssueIds(): Array<string> {
        return this.issueTargets.map((element: Element) => {
            return element.getAttribute('data-issue-id') || '';
        }).filter((value: string) => value !== null) || [];
    }

    private dispatchUpdate(form: FormData) {
        if ($('[data-ending-action-buttons]').length) {
            $.ajax({
                type: "POST",
                url: window.RedmineTracky.trackerUpdatePath,
                data: {
                    timer_session: form,
                },
                async: true,
            });
        }
    }

    private valueForInput(element: Element): any {
        return (element as HTMLInputElement).value;
    }

    private convertToDateTime(value: string): DateTime {
        return DateTime.fromFormat(
            value,
            window.RedmineTracky.datetimeFormatJavascript
        );
    }
}
