import { Controller } from '@hotwired/stimulus'
import { CompletionResult } from '@interfaces/completion-result'
import ListController from '@controllers/list-controller'

// https://github.com/redmine/redmine/blob/4.2-stable/public/javascripts/application.js#L637-L648
declare function observeAutocompleteField(
  id: string,
  selector: Function,
  options: { select: Function },
): any

export default class extends Controller {
  declare readonly inputTarget: HTMLInputElement
  declare readonly listAnchorTarget: Element

  static targets = ['input', 'listAnchor']
  static values = { update: Boolean }

  connect() {
    this.listenForInput()
    this.prefillFromURL()
  }

  private listenForInput() {
    this.cleanup()
    observeAutocompleteField(
      this.inputTarget.id,
      function (request: any, callback: any) {
        const url = window.RedmineTracky.issueCompletionPath
        const data = { term: request.term, scope: 'all' }

        $.get(url, data, null, 'json')
          .done((data: CompletionResult[]) => callback(data))
          .fail(() => callback([]))
      },
      {
        select: (_event: Event, item: { item: CompletionResult }) => {
          this.addIssue(item)
          this.cleanup()
          return false
        },
      },
    )
  }

  private prefillFromURL() {
    const urlParams = new URLSearchParams(window.location.search)

    this.prefillIssuesFromURL(urlParams)
    this.prefillFieldFromURL(urlParams, 'comments', '#timer_session_comments')
    this.prefillFieldFromURL(urlParams, 'timer_start', '#timer_session_timer_start')
    this.prefillFieldFromURL(urlParams, 'timer_end', '#timer_session_timer_end')
  }

  private prefillIssuesFromURL(urlParams: URLSearchParams) {
    const issueIds = urlParams.getAll('issue_ids[]')

    issueIds.filter(v => v !== "").forEach((id) => {
      const url = window.RedmineTracky.issueCompletionPath
      const data = { term: id, scope: 'all' }

      $.get(url, data, null, 'json')
        .done((results: CompletionResult[]) => {
          const [result] = results
          this.addIssue({ item: result })
        })
        .fail(() => {
          console.error(`Failed to fetch issue with ID: ${id}`)
        })
    })
  }

  private prefillFieldFromURL(urlParams: URLSearchParams, param: string, selector: string) {
    const value = urlParams.get(param)
    if (!value) return

    const field = document.querySelector<HTMLInputElement>(selector)
    if (field) {
      field.value = value
      field.dispatchEvent(new Event('change'))
    }
  }

  private addIssue(issue: { item: CompletionResult }) {
    const listController =
      this.application.getControllerForElementAndIdentifier(
        this.listAnchorTarget,
        'list',
      ) as ListController
    listController?.addItem(issue.item)
  }

  private clearInput() {
    $(this.inputTarget).val('')
  }

  private cleanup() {
    this.clearInput()
    $('.ui-autocomplete').hide()
    $('.ui-helper-hidden-accessible').hide()
  }
}
