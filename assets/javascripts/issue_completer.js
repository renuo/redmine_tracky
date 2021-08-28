export default class IssueCompleter {

    static completionID(update) {
        return update ? 'timer_session_update_issue_id' : 'timer_session_issue_id';
    }

    static bind(update = false) {
        var issueCompleter;
        if (update) {
            issueCompleter = new IssueCompleter(IssueCompleter.completionID(update), window.UpdateIssuesList, update);
        } else {
            issueCompleter = new IssueCompleter(IssueCompleter.completionID(update), window.IssueListHandler, update);
        }

        issueCompleter.bindToField();
    }

    constructor(fieldID, issueList, update) {
        this.fieldID = fieldID;
        this.issueList = issueList;
        this.update = update;
    }

    bindToField() {
        $(document).ready(() => {
            // Code used from the Redmine codebase
            // https://github.com/redmine/redmine/blob/7337343f569599c4f1250b22312e093685027568/app/views/timelog/_form.html.erb
            // LINE: 55
            // ON 12.05.2021
            observeAutocompleteField(this.fieldID,
                function(request, callback) {
                    var url = window.RedmineTracky.issueCompletionPath;
                    var data = {
                        term: request.term
                    };
                    data['scope'] = 'all';
                    $.get(url, data, null, 'json')
                        .done(function(data) {
                            callback(data);
                        })
                        .fail(function(jqXHR, status, error) {
                            callback([]);
                        });
                }, {
                    select: (event, item) => {
                        this.issueList.addIssue(item.item);
                        if (!this.update) {
                            window.ActionBinder.timerUpdate().updateIssue();
                        }
                    }
                }
            );
        });
    }
}
