import { Controller } from "@hotwired/stimulus"
import { CompletionResult } from '@interfaces/completion-result';

export default class extends Controller {
    readonly tableTarget!: Element;

    static targets = ['table'];

    addItem(item: CompletionResult): void {
        const tbody = this.tableTarget.getElementsByTagName('tbody')[0];
        tbody.appendChild(
            this.buildItem(
                item
            )
        );
    }

    removeItem(event: Event): void {
        const { target } = event;
        const row: Element = (target as Element).closest('[data-form-target="issue"]') as Element;
        row.remove();
    }

    private buildItem(item: CompletionResult): Element {
        const row = document.createElement('tr');
        row.setAttribute('data-form-target', 'issue');
        row.classList.add('issue-container');
        row.setAttribute('data-issue-id', item.id.toString());

        [
            this.buildLabelColumn(item),
            this.buildSubjectColumn(item),
            this.buildDeletionButtonColumn(item)
        ].forEach((element: Element) => row.appendChild(element));

        return row;
    }

    private buildLabelColumn(item: CompletionResult): Element {
        const bold = document.createElement('b');
        const a = document.createElement('a');

        a.setAttribute('href', `/issues/${item.id}`);
        a.setAttribute('target', '_blank');
        a.setAttribute('rel', 'noopener');

        a.innerHTML = `${item.project} - ${item.id}: `;
        bold.appendChild(a);
        return this.buildColumn([bold]);
    }

    private buildSubjectColumn(item: CompletionResult): Element {
        return this.buildColumn(
            [
                document.createTextNode(item.subject)
            ]
        )
    }

    private buildDeletionButtonColumn(item: CompletionResult): Element {
        const span = document.createElement('span');
        span.classList.add('text-danger');
        span.classList.add('input-group-text');
        span.setAttribute('data-action', "click->list#removeItem");
        const icon = document.createElement('i');
        icon.classList.add('icon-only');
        icon.classList.add('icon-del');
        span.appendChild(icon);

        const input = document.createElement('input');
        input.setAttribute('id', `timer_session_issue_id_${item.id}`);
        input.setAttribute('readonly', '');
        input.setAttribute('hidden', '');
        input.setAttribute('name', 'timer_session[issue_ids][]');
        input.setAttribute('value', item.id.toString());

        return this.buildColumn(
            [
                span,
                input
            ]
        );
    }

    private buildColumn(elements: Array<Element | Text>): Element {
        const column = document.createElement('td');
        elements.forEach((element: Element | Text) => {
            column.appendChild(element);
        });
        return column;
    }
}
