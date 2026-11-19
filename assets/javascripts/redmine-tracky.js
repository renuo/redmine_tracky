import { Controller } from '@hotwired/stimulus'
import { application } from 'controllers/application'

const pad = (number) => String(number).padStart(2, '0')

function parseDateTime(value) {
  const match = /^(\d{1,2})\.(\d{1,2})\.(\d{4}) (\d{1,2}):(\d{2})$/.exec(value)
  if (!match) return null

  const [day, month, year, hours, minutes] = match.slice(1).map(Number)
  const date = new Date(year, month - 1, day, hours, minutes)
  const valid =
    date.getDate() === day &&
    date.getMonth() === month - 1 &&
    date.getHours() === hours &&
    date.getMinutes() === minutes

  return valid ? date : null
}

function formatDateTime(date) {
  return `${pad(date.getDate())}.${pad(date.getMonth() + 1)}.${date.getFullYear()} ` +
    `${pad(date.getHours())}:${pad(date.getMinutes())}`
}

function formatDuration(milliseconds) {
  const sign = milliseconds < 0 ? '-' : ''
  const totalSeconds = Math.floor(Math.abs(milliseconds) / 1000)
  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const seconds = totalSeconds % 60

  return `${sign}${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
}

class FormController extends Controller {
  static targets = ['description', 'start', 'stopButton', 'end', 'issue', 'absolutInput']

  connect() {
    this.connected = true
  }

  disconnect() {
    this.connected = false
  }

  absoluteTime() {
    try {
      const hours = parseFloat(this.absolutInputTarget.value)
      const start = parseDateTime(this.startTarget.value)

      if (hours && start) {
        this.endTarget.value = formatDateTime(new Date(start.getTime() + hours * 3600 * 1000))
        this.endTarget.dispatchEvent(new Event('change'))
      }
    } finally {
      this.absolutInputTarget.value = ''
    }
  }

  issueTargetConnected() {
    if (this.connected) this.change()
  }

  issueTargetDisconnected() {
    if (this.connected) this.change()
  }

  change() {
    if (!this.hasStopButtonTarget) return

    $.ajax({
      type: 'POST',
      url: window.RedmineTracky.trackerUpdatePath,
      data: {
        timer_session: {
          timer_start: this.startTarget.value,
          timer_end: this.endTarget.value,
          comments: this.descriptionTarget.value,
          issue_ids: this.issueTargets.map((element) => element.getAttribute('data-issue-id') || ''),
        },
      },
    })
  }
}

class TimerController extends Controller {
  static targets = ['start', 'end', 'label', 'description', 'timezoneWarning']
  static values = { timezone: Number }

  connect() {
    this.timezoneWarningTarget.hidden = -new Date().getTimezoneOffset() === this.timezoneValue

    const start = this.startTarget.value
    const end = this.endTarget.value

    document.title = start ? '⏱️ Tracky' : '❌ Tracky'

    if (start && end) {
      this.updateLabel()
    } else if (start) {
      window.TimerInterval = setInterval(() => this.updateLabel(), 1000)
    }
  }

  disconnect() {
    if (window.TimerInterval) clearInterval(window.TimerInterval)
  }

  updateLabel() {
    const start = parseDateTime(this.startTarget.value) || new Date()
    const end = parseDateTime(this.endTarget.value) || new Date()

    $(this.labelTarget).text(formatDuration(end - start))
  }
}

class ListController extends Controller {
  static targets = ['table']

  addItem(item) {
    this.tableTarget.querySelector('tbody').appendChild(this.buildItem(item))
  }

  removeItem({ target }) {
    target.closest('[data-form-target="issue"]')?.remove()
  }

  buildItem(item) {
    const issue = this.tableTarget.querySelector('template').content.cloneNode(true)
    const link = issue.querySelector('a')
    const input = issue.querySelector('input')

    link.href = `/issues/${item.id}`
    link.innerHTML = `${item.project} - ${item.id}: `
    input.id = `timer_session_issue_id_${item.id}`
    input.value = item.id.toString()
    issue.querySelector('tr').setAttribute('data-issue-id', item.id.toString())
    issue.querySelector('[data-issue-subject]').innerHTML = item.subject

    return issue
  }
}

class IssueCompletionController extends Controller {
  static targets = ['input', 'listAnchor']

  connect() {
    this.listenForInput()
    this.fetchIssuesFromURL()
  }

  listenForInput() {
    this.cleanup()
    // Redmine's own autocomplete, see public/javascripts/application.js
    observeAutocompleteField(
      this.inputTarget.id,
      (request, callback) => {
        $.get(window.RedmineTracky.issueCompletionPath, { term: request.term, scope: 'all' }, null, 'json')
          .done((results) => callback(results))
          .fail(() => callback([]))
      },
      {
        select: (_event, { item }) => {
          this.addIssue(item)
          this.cleanup()
          return false
        },
      },
    )
  }

  fetchIssuesFromURL() {
    new URLSearchParams(window.location.search)
      .getAll('issue_ids[]')
      .filter((id) => id !== '')
      .forEach((id) => {
        $.get(window.RedmineTracky.issueCompletionPath, { term: id, scope: 'all' }, null, 'json')
          .done(([result]) => this.addIssue(result))
          .fail(() => console.error(`Failed to fetch issue with ID: ${id}`))
      })
  }

  addIssue(item) {
    this.application.getControllerForElementAndIdentifier(this.listAnchorTarget, 'list')?.addItem(item)
  }

  cleanup() {
    $(this.inputTarget).val('')
    $('.ui-autocomplete').hide()
    $('.ui-helper-hidden-accessible').hide()
  }
}

class FlatpickrController extends Controller {
  connect() {
    this.picker = window.flatpickr(this.element, {
      dateFormat: 'd.m.Y H:i',
      enableTime: true,
      time_24hr: true,
      minuteIncrement: 1,
      allowInput: true,
      onOpen: (_selectedDates, dateString, instance) => {
        if (!dateString) instance.setDate(this.defaultDate())
      },
    })
  }

  disconnect() {
    const value = this.element.value
    this.picker.destroy()
    this.element.value = value
  }

  // Sessions started before today rarely run overnight, so an empty end defaults to the start instead of now
  defaultDate() {
    const start = this.startDateOfSession()
    const startOfToday = new Date().setHours(0, 0, 0, 0)

    return start && start.getTime() < startOfToday ? start : Date.now()
  }

  startDateOfSession() {
    if (this.element.getAttribute('data-form-target') !== 'end') return undefined

    return this.element.closest('form')?.querySelector('[data-form-target="start"]')?._flatpickr?.selectedDates[0]
  }
}

application.register('form', FormController)
application.register('timer', TimerController)
application.register('list', ListController)
application.register('issue-completion', IssueCompletionController)
application.register('flatpickr', FlatpickrController)
