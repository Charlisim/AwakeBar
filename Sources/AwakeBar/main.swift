import AppKit
import IOKit.pwr_mgt

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var assertion: IOPMAssertionID = 0
    private var active = false
    private var activityAssertion: IOPMAssertionID = 0
    private var lastActivity = Date.distantPast
    private var deadline: Date?
    private var timer: Timer?
    private var aboutWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        refreshMenu(menu)
        statusItem.menu = menu
        update()
        if CommandLine.arguments.contains("--about") { showAbout() }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(woke), name: NSWorkspace.didWakeNotification, object: nil)
    }

    func applicationWillTerminate(_ notification: Notification) { stop() }
    @objc private func woke() { update() }

    private func refreshMenu(_ menu: NSMenu) {
        menu.removeAllItems()
        let heading = NSMenuItem(title: active ? "Keeping your Mac awake" : "Your Mac can sleep", action: nil, keyEquivalent: "")
        menu.addItem(heading)
        menu.addItem(.separator())
        for minutes in [0, 20, 30, 60, 120] {
            let item = NSMenuItem(title: minutes == 0 ? "Keep awake indefinitely" : "Keep awake for \(minutes) minutes", action: #selector(selectDuration(_:)), keyEquivalent: "")
            item.target = self
            item.tag = minutes
            menu.addItem(item)
        }
        let custom = NSMenuItem(title: "Custom duration…", action: #selector(customDuration), keyEquivalent: "")
        custom.target = self
        menu.addItem(custom)
        menu.addItem(.separator())
        let stopItem = NSMenuItem(title: "Allow sleep", action: #selector(allowSleep), keyEquivalent: "")
        stopItem.tag = -1
        stopItem.target = self
        stopItem.isEnabled = active
        menu.addItem(stopItem)
        menu.addItem(.separator())
        let about = NSMenuItem(title: "About AwakeBar…", action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)
        let quit = NSMenuItem(title: "Quit AwakeBar", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    @objc private func showAbout() {
        if aboutWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 410), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = "AwakeBar"
            window.isReleasedWhenClosed = false
            let stack = NSStackView()
            stack.orientation = .vertical
            stack.spacing = 16
            stack.edgeInsets = NSEdgeInsets(top: 30, left: 32, bottom: 30, right: 32)
            let icon = NSImageView()
            icon.image = NSImage(named: NSImage.applicationIconName)
            icon.setFrameSize(NSSize(width: 80, height: 80))
            icon.widthAnchor.constraint(equalToConstant: 80).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 80).isActive = true
            stack.addArrangedSubview(icon)
            let title = NSTextField(labelWithString: "AwakeBar")
            title.font = .systemFont(ofSize: 28, weight: .bold)
            stack.addArrangedSubview(title)
            let subtitle = NSTextField(labelWithString: "Keep your Mac awake. On your terms.")
            subtitle.font = .systemFont(ofSize: 14)
            subtitle.textColor = .secondaryLabelColor
            stack.addArrangedSubview(subtitle)
            let detail = NSTextField(wrappingLabelWithString: "Choose a duration from the cup in your menu bar. Stay awake indefinitely, use a preset, or set your own timer.")
            detail.alignment = .center
            detail.widthAnchor.constraint(equalToConstant: 340).isActive = true
            stack.addArrangedSubview(detail)
            let button = NSButton(title: "Choose duration", target: self, action: #selector(openDurationMenu(_:)))
            button.bezelStyle = .rounded
            stack.addArrangedSubview(button)
            let version = NSTextField(labelWithString: "Version 1.0.0 · Open source · MIT License")
            version.textColor = .tertiaryLabelColor
            version.font = .systemFont(ofSize: 11)
            stack.addArrangedSubview(version)
            window.contentView = stack
            window.center()
            aboutWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        aboutWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func openDurationMenu(_ sender: NSButton) {
        guard let menu = statusItem.menu else { return }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
    }

    @objc private func selectDuration(_ sender: NSMenuItem) { start(minutes: sender.tag == 0 ? nil : sender.tag) }
    @objc private func allowSleep() { stop(); update() }
    @objc private func quitApp() { NSApp.terminate(nil) }

    @objc private func customDuration() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Custom duration"
        alert.informativeText = "Enter a whole number of minutes (1–10080)."
        alert.addButton(withTitle: "Keep awake")
        alert.addButton(withTitle: "Cancel")
        let field = NSTextField(string: "45")
        field.frame = NSRect(x: 0, y: 0, width: 260, height: 24)
        alert.accessoryView = field
        alert.window.initialFirstResponder = field
        while alert.runModal() == .alertFirstButtonReturn {
            if let minutes = Int(field.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)), (1...10080).contains(minutes) {
                start(minutes: minutes)
                return
            }
            alert.informativeText = "Please enter a whole number from 1 to 10080 minutes."
        }
    }

    private func start(minutes: Int?) {
        var newAssertion: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), "AwakeBar active session" as CFString, &newAssertion)
        guard result == kIOReturnSuccess else {
            let alert = NSAlert()
            alert.messageText = "Could not keep your Mac awake"
            alert.informativeText = "macOS returned error \(result). Your previous session is unchanged."
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
            return
        }
        stop()
        assertion = newAssertion
        active = true
        deadline = minutes.map { Date().addingTimeInterval(Double($0) * 60) }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }
        update()
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
        if active { IOPMAssertionRelease(assertion) }
        if activityAssertion != 0 { IOPMAssertionRelease(activityAssertion) }
        activityAssertion = 0
        lastActivity = .distantPast
        assertion = 0
        active = false
        deadline = nil
    }

    private func update() {
        if let deadline, deadline <= Date() { stop() }
        if active && Date().timeIntervalSince(lastActivity) >= 25 {
            IOPMAssertionDeclareUserActivity("AwakeBar active session" as CFString, kIOPMUserActiveLocal, &activityAssertion)
            lastActivity = Date()
        }
        statusItem.menu?.items.first?.title = active ? "Keeping your Mac awake" : "Your Mac can sleep"
        statusItem.menu?.item(withTag: -1)?.isEnabled = active
        statusItem.button?.image = NSImage(systemSymbolName: active ? "cup.and.saucer.fill" : "cup.and.saucer", accessibilityDescription: "AwakeBar")
        if active, let deadline {
            let remaining = max(0, Int(ceil(deadline.timeIntervalSinceNow)))
            statusItem.button?.title = " \(remaining / 60):\(String(format: "%02d", remaining % 60))"
        } else {
            statusItem.button?.title = active ? " ∞" : ""
        }
        statusItem.button?.toolTip = active ? "AwakeBar: keeping your Mac awake" : "AwakeBar: inactive"
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
