import type { Plugin } from "@opencode-ai/plugin"

type PermissionResponse = "once" | "always" | "reject"

type PermissionRequest = {
  id: string
  sessionID: string
  permission?: string
  type?: string
  title?: string
  patterns?: unknown[]
  pattern?: string | string[]
  metadata?: Record<string, unknown>
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
  const permission = request.permission ?? request.type ?? "unknown"
  const pattern = request.patterns ?? request.pattern ?? []
  const patterns = (Array.isArray(pattern) ? pattern : [pattern]).map(String)
  const command = request.metadata?.command
  const details = typeof command === "string" ? [command] : patterns

  return {
    title: "An OpenCode agent is requesting permission",
    permission: `Permission: ${permission}`,
    body: (details.join("\n") || request.title || "No additional details").slice(0, 4000),
  }
}

export const DesktopNotifications: Plugin = async ({ client, $ }) => {
  let permissionQueue = Promise.resolve()
  const pending = new Set<string>()

  const notify = async (message: string) => {
    if (process.platform === "darwin") {
      await $`osascript -e ${`display notification "${message}" with title "OpenCode"`}`
        .quiet()
        .nothrow()
      return
    }

    if (process.platform === "linux") {
      await $`notify-send --app-name=opencode --urgency=critical --expire-time=0 OpenCode ${message}`
        .quiet()
        .nothrow()
    }
  }

  const prompt = async (request: PermissionRequest): Promise<PermissionResponse> => {
    const { title, permission, body } = describe(request)

    if (process.platform === "darwin") {
      const result = await $`osascript -e ${appleScript} ${title} ${`${permission}\n\n${body}`}`
        .quiet()
        .nothrow()
      const answer = result.text().trim()
      if (answer === "Allow Once") return "once"
      if (answer === "Always Allow") return "always"
      return "reject"
    }

    if (process.platform === "linux") {
      const libdir = (await $`pkg-config --variable=libdir gtk4-layer-shell-0`.quiet().nothrow())
        .text()
        .trim()
      if (!libdir) return "reject"

      const preload = `${libdir}/libgtk4-layer-shell.so`
      const result = await $`env LD_PRELOAD=${preload} gjs -c ${gtkScript} ${title} ${permission} ${body}`
        .quiet()
        .nothrow()
      const answer = result.text().trim()
      if (answer === "once" || answer === "always") return answer
      return "reject"
    }

    return "reject"
  }

  const handlePermission = async (request: PermissionRequest) => {
    let response: PermissionResponse = "reject"

    try {
      response = await prompt(request)
    } catch (error) {
      console.error("Failed to show OpenCode permission prompt", error)
    }

    await client.postSessionIdPermissionsPermissionId({
      path: {
        id: request.sessionID,
        permissionID: request.id,
      },
      body: { response },
      throwOnError: true,
    })
  }

  const enqueuePermission = (request: PermissionRequest) => {
    if (pending.has(request.id)) return permissionQueue
    pending.add(request.id)

    permissionQueue = permissionQueue
      .then(() => handlePermission(request))
      .catch(async (error) => {
        console.error("Failed to answer OpenCode permission request", error)
        await notify("Failed to answer permission request")
      })
      .finally(() => pending.delete(request.id))

    return permissionQueue
  }

  return {
    event: async ({ event }) => {
      const current = event as unknown as {
        type: string
        properties?: PermissionRequest
      }

      if (
        (current.type === "permission.asked" || current.type === "permission.updated") &&
        current.properties?.id &&
        current.properties.sessionID
      ) {
        await enqueuePermission(current.properties)
        return
      }

      if (current.type === "question.asked") {
        await notify("Question requires input")
      }
    },
  }
}
