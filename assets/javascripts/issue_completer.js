export default class IssueCompleter {

	static completionID(update) {
		return update ? 'timer_session_update_issue_id' :'timer_session_issue_id';
	}

	static bind(update = false) {
		$(document).ready(() => {
		observeAutocompleteField(IssueCompleter.completionID(update),
			function(request, callback) {
				var url = window.RedmineTracky.issueCompletionPath;
				var data = {
					term: request.term
				};
				data['scope'] = 'all';
				$.get(url, data, null, 'json')
					.done(function(data){
						callback(data);
					})
					.fail(function(jqXHR, status, error){
						callback([]);
					});
			},
			{
				select: function(event, item) {
					if(update) {
						window.UpdateIssuesList.addIssue(item.item);
					} else{
						window.IssueListHandler.addIssue(item.item);
						window.ActionBinder.timerUpdate().updateIssue();
					}
				}
			}
		);
	});
	}
}
