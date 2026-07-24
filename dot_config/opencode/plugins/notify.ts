import type { Plugin } from "@opencode-ai/plugin"

export const DesktopNotifications: Plugin = async ({ $ }) => ({
  event: async ({ event }) => {
    const message =
      event.type === "permission.asked"
        ? "Permission required"
        : event.type === "question.asked"
          ? "Question requires input"
          : undefined
    if (!message) return

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
  },
})
