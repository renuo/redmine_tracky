export default class UpdateIssuesList {
    static issueContainer = () => '[data-update-issue-selection-container]';

    static elementID = () => 'timer_session[issue_ids]';

    static issueDeletionButton = () => 'data-update-issue-deletion-action';

    static bind() {
        $(document).ready(() => {
            $('[data-update-issue-deletion-action]').off('click');
            $('[data-update-issue-deletion-action]').on('click', function() {
                UpdateIssuesList.removeIssue($(this));
            });
        });
    }

    static removeIssue(element) {
        const parent = element.parent();
        parent.parent().remove();
    }

    static addIssue(item) {
        $(UpdateIssuesList.issueContainer()).append(UpdateIssuesList.buildNewIssueElement(item.id,
            item.label));
        UpdateIssuesList.bind();
    }

    static buildNewIssueElement(id, label) {
        return $(`
        <div class="issue-container">
					<label for='timer_session_issue_id_${id}'>${label}
					<span class="input-group-text text-danger" ${UpdateIssuesList.issueDeletionButton()}="">
						<i class="icon-only icon-del"></i>
					</span>
          <input hidden data-issue-element='${id}'
					id='timer_session_issue_id_${id}'
          class="ml-10 form-control" readonly name="${UpdateIssuesList.elementID()}[]" value="${id}"/>
          </label>
        </div>
    `);
    }
}
