import { execFile } from "node:child_process"

type Decision = "once" | "always" | "reject"

type PermissionRequest = {
  id: string
  sessionID: string
  action: string
  resources: string[]
  metadata?: Record<string, unknown>
  message?: string
}

type PermissionAskedEvent = {
  type: "permission.asked"
  data: PermissionRequest
  location?: { directory?: string }
}

// Structural types avoid requiring either version's plugin package at runtime.
type V2Context = {
  location: { directory: string }
  event: { subscribe(options: { signal: AbortSignal }): AsyncIterable<unknown> }
  permission: {
    reply(input: { sessionID: string; requestID: string; decision: Decision }): Promise<unknown>
  }
}

type V1Input = {
  client: {
    postSessionIdPermissionsPermissionId(input: {
      path: { id: string; permissionID: string }
      body: { response: Decision }
      throwOnError: true
    }): Promise<unknown>
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null
}

function isPermissionAsked(event: unknown): event is PermissionAskedEvent {
  if (!isRecord(event) || event.type !== "permission.asked" || !isRecord(event.data)) {
    return false
  }

  return typeof event.data.id === "string" && typeof event.data.sessionID === "string"
}

function eventDirectory(event: unknown): string | undefined {
  if (!isRecord(event) || !isRecord(event.location)) {
    return undefined
  }

  return typeof event.location.directory === "string" ? event.location.directory : undefined
}

const appleScript = String.raw`
on run argv
  set dialogTitle to item 1 of argv
  set dialogBody to item 2 of argv
  try
    set answer to display dialog dialogBody with title dialogTitle buttons {"Reject", "Always Allow", "Allow Once"} default button "Allow Once" cancel button "Reject" with icon caution
    return button returned of answer
  on error number -128
    return "Reject"
  end try
end run
`

const gtkScript = String.raw`
imports.gi.versions.Gtk = "4.0"
imports.gi.versions.Gtk4LayerShell = "1.0"

const { Gdk, Gio, Gtk, Gtk4LayerShell: LayerShell } = imports.gi
let answered = false

const app = new Gtk.Application({
  application_id: "dev.opencode.PermissionPrompt",
  flags: Gio.ApplicationFlags.NON_UNIQUE,
})

app.connect("activate", () => {
  const styles = new Gtk.CssProvider()
  styles.load_from_string(
    ".permission-details {" +
      "background-color: rgba(0, 0, 0, 0.22);" +
      "border-radius: 6px;" +
      "font-family: monospace;" +
      "padding: 12px;" +
      "}",
  )
  Gtk.StyleContext.add_provider_for_display(
    Gdk.Display.get_default(),
    styles,
    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
  )

  const window = new Gtk.ApplicationWindow({
    application: app,
    title: ARGV[0],
    default_width: 720,
    default_height: 300,
  })

  LayerShell.init_for_window(window)
  LayerShell.set_namespace(window, "opencode-permission")
  LayerShell.set_layer(window, LayerShell.Layer.OVERLAY)
  LayerShell.set_keyboard_mode(window, LayerShell.KeyboardMode.EXCLUSIVE)

  const content = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 12,
    margin_top: 16,
    margin_bottom: 16,
    margin_start: 16,
    margin_end: 16,
  })

  const heading = new Gtk.Label({
    label: ARGV[0],
    xalign: 0,
  })
  heading.add_css_class("title-2")
  content.append(heading)

  const permission = new Gtk.Label({
    label: ARGV[1],
    xalign: 0,
  })
  content.append(permission)

  const scroller = new Gtk.ScrolledWindow({
    hexpand: true,
    vexpand: true,
    min_content_height: 160,
  })
  const details = new Gtk.Label({
    label: ARGV[2],
    selectable: false,
    focusable: false,
    wrap: true,
    xalign: 0,
    yalign: 0,
    margin_top: 8,
    margin_bottom: 8,
    margin_start: 8,
    margin_end: 8,
  })
  details.add_css_class("permission-details")
  scroller.set_child(details)
  content.append(scroller)

  const buttons = new Gtk.Box({
    orientation: Gtk.Orientation.HORIZONTAL,
    spacing: 8,
    halign: Gtk.Align.END,
  })

  const choose = (response) => {
    if (answered) return
    answered = true
    print(response)
    app.quit()
  }

  for (const [label, response] of [
    ["Reject", "reject"],
    ["Always Allow", "always"],
    ["Allow Once", "once"],
  ]) {
    const button = new Gtk.Button({ label })
    button.connect("clicked", () => choose(response))
    buttons.append(button)
  }

  content.append(buttons)
  window.set_child(content)
  window.connect("close-request", () => {
    choose("reject")
    return false
  })
  window.present()
})

app.run([])
`

function describe(request: PermissionRequest) {
  const command = request.metadata?.command
  const details = typeof command === "string" ? [command] : request.resources

  return {
    title: "An OpenCode agent is requesting permission",
    permission: `Permission: ${request.action}`,
    body: (details.join("\n") || request.message || "No additional details").slice(0, 4000),
  }
}

// Notification body is passed to osascript/notify-send as an argv item, never
// interpolated into script source, so quotes/newlines in agent output cannot
// break out of the AppleScript string literal or the shell command.
const notifyScript = String.raw`
on run argv
  set notifyBody to item 1 of argv
  display notification notifyBody with title "OpenCode"
end run
`

function clampText(value: string, max: number): string {
  const flat = value.replace(/[\0-\x1F\x7F]+/g, " ").trim()
  return flat.length > max ? `${flat.slice(0, max - 1)}…` : flat
}

// Dialog commands run without a timeout: the prompt must be able to wait for
// the user's answer, and failures resolve to an empty answer (reject).
function run(command: string, args: string[]): Promise<string> {
  return new Promise((resolve) => {
    execFile(command, args, { maxBuffer: 64 * 1024 }, (error, stdout) => {
      resolve(error ? "" : stdout)
    })
  })
}

async function notify(message: string) {
  const body = clampText(message, 500)
  if (process.platform === "darwin") {
    await run("osascript", ["-e", notifyScript, body])
    return
  }

  if (process.platform === "linux") {
    await run("notify-send", [
      "--app-name=opencode",
      "--urgency=critical",
      "--expire-time=0",
      "OpenCode",
      body,
    ])
  }
}

async function prompt(request: PermissionRequest): Promise<Decision> {
  const { title, permission, body } = describe(request)

  if (process.platform === "darwin") {
    const answer = (
      await run("osascript", ["-e", appleScript, title, `${permission}\n\n${body}`])
    ).trim()
    if (answer === "Allow Once") return "once"
    if (answer === "Always Allow") return "always"
    return "reject"
  }

  if (process.platform === "linux") {
    const libdir = (await run("pkg-config", ["--variable=libdir", "gtk4-layer-shell-0"])).trim()
    if (!/^[\w/.\-]+$/.test(libdir)) return "reject"

    const preload = `${libdir}/libgtk4-layer-shell.so`
    const answer = (
      await run("env", [
        `LD_PRELOAD=${preload}`,
        "gjs",
        "-c",
        gtkScript,
        title,
        permission,
        body,
      ])
    ).trim()
    if (answer === "once" || answer === "always") return answer
    return "reject"
  }

  return "reject"
}

// V1 uses server(); V2 uses setup(). Some V1 releases additionally call
// setup() with a transitional context that cannot subscribe to events.
// Keep one default export so neither loader sees helper functions as plugins.
const DesktopNotifications = {
  id: "desktop-notifications",
  async server({ client }: V1Input) {
    const enqueue = permissionQueue(async (request, decision) => {
      await client.postSessionIdPermissionsPermissionId({
        path: { id: request.sessionID, permissionID: request.id },
        body: { response: decision },
        throwOnError: true,
      })
    })

    return {
      async event({ event }: { event: unknown }) {
        if (!isRecord(event)) return
        if (event.type === "question.asked") {
          await notify("Question requires input")
          return
        }
        // V1 exposes payloads as properties and filters events by directory.
        if (event.type !== "permission.asked" || !isRecord(event.properties)) return
        const request = event.properties
        if (typeof request.id !== "string" || typeof request.sessionID !== "string") return
        if (typeof request.permission !== "string" || !Array.isArray(request.patterns)) return
        if (!request.patterns.every((pattern) => typeof pattern === "string")) return
        enqueue({
          id: request.id,
          sessionID: request.sessionID,
          action: request.permission,
          resources: request.patterns,
          metadata: isRecord(request.metadata) ? request.metadata : undefined,
        })
      },
    }
  },
  async setup(ctx: Partial<V2Context>) {
    // The V1 compatibility loader provides only transform APIs here. Its
    // separate server() entry point handles notifications through V1 hooks.
    if (!ctx.event || typeof ctx.event.subscribe !== "function" ||
        !ctx.permission || typeof ctx.permission.reply !== "function" || !ctx.location) {
      return
    }
    const { event: events, permission, location } = ctx
    const enqueue = permissionQueue(async (request, decision) => {
      await permission.reply({ sessionID: request.sessionID, requestID: request.id, decision })
    })
    const controller = new AbortController()

    // Every loaded location runs its own plugin instance and receives the
    // server-wide event stream, so an event's own location decides which
    // instance answers it. Events without a location fall back to the
    // instance that sees them.
    const owned = (event: unknown) => {
      const directory = eventDirectory(event)
      return directory === undefined || directory === location.directory
    }

    const consume = (async () => {
      try {
        for await (const event of events.subscribe({ signal: controller.signal })) {
          if (isPermissionAsked(event)) {
            if (owned(event)) enqueue(event.data)
            continue
          }

          if (isRecord(event) && event.type === "form.created" && owned(event)) {
            await notify("Question requires input")
          }
        }
      } catch (error) {
        if (!controller.signal.aborted) {
          console.error("OpenCode event subscription failed", error)
        }
      }
    })()

    return async () => {
      controller.abort()
      await consume.catch(() => {})
    }
  },
}

function permissionQueue(reply: (request: PermissionRequest, decision: Decision) => Promise<void>) {
  let queue: Promise<void> = Promise.resolve()
  const handled = new Set<string>()
  return (request: PermissionRequest) => {
    if (handled.has(request.id)) return
    handled.add(request.id)
    queue = queue.then(async () => {
      let decision: Decision = "reject"
      try {
        decision = await prompt(request)
      } catch (error) {
        console.error("Failed to show OpenCode permission prompt", error)
      }
      try {
        await reply(request, decision)
      } catch (error) {
        console.error("Failed to answer OpenCode permission request", error)
        await notify("Failed to answer permission request")
      }
    }).catch((error) => {
      console.error("Failed to handle OpenCode permission request", error)
    })
  }
}

export default DesktopNotifications
