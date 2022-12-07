import { Controller } from "@hotwired/stimulus";
import { CompletionResult } from '@interfaces/completion-result';
import ListController from '@controllers/list-controller';

declare function observeAutocompleteField(id: string,
    selector: Function,
    { select: Function }: any
): any;

export default class extends Controller {
    static targets = ['input', 'listAnchor'];

    readonly inputTarget!: Element;
    readonly listAnchorTarget!: Element;

    static values = {
        update: Boolean,
    }

    connect(): void {
        this.listenForInput();
    }

    private listenForInput() {
        this.cleanup();
        observeAutocompleteField(
            this.inputTarget.id,
            function (request: any, callback: any) {
                var url = window.RedmineTracky.issueCompletionPath;
                var data = {
                    term: request.term,
                    scope: 'all',
                };
                $.get(url, data, null, "json")
                    .done(function (data: Array<CompletionResult>) {
                        callback(data);
                    })
                    .fail(function (jqXHR, status, error) {
                        callback([]);
                    });
            },
            {
                select: (event: Event, item: { item: CompletionResult }) => {
                    this.addIssue(item);
                    this.cleanup();
                    return false;
                },
            }
        );
    }

    private addIssue(issue: { item: CompletionResult }) {
        const listController: ListController = this.application.getControllerForElementAndIdentifier(this.listAnchorTarget, 'list') as ListController;
        listController?.addItem(issue.item);
    }

    private clearInput() {
        $(this.inputTarget).val('');
    }

    private cleanup() {
        this.clearInput();
        $(".ui-autocomplete").hide();
        $(".ui-helper-hidden-accessible").hide();
    }
}
