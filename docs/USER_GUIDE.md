# User guide

## Start a session

Open AwakeBar and click the cup in the menu bar. Choose indefinite mode, a preset, or **Custom duration…**. Custom input accepts a whole number from 1 to 10080 minutes (seven days).

An outlined cup means inactive. A filled cup means active. Indefinite mode shows `∞`; timed sessions show remaining minutes and seconds. A new duration replaces the current session.

## End a session

Choose **Allow sleep** to stop immediately. Timed sessions stop at the deadline; quitting also releases the assertions. Relaunching starts inactive.

If the Mac wakes after the deadline, the wake notification ends the expired session. Deadlines use wall-clock time, so changing the system clock affects the timer.

## Troubleshooting

- **Missing cup:** check that the app is running and there is room in a crowded or notched menu bar.
- **Downloaded build cannot open:** it is locally signed, not notarized. Use macOS's explicit approval flow or build from source. AwakeBar requires no accessibility permission.
- **Mac still locks:** check screen saver, manual lock, lid closure, forced sleep, and managed policies. Preventing idle display sleep does not guarantee overriding automatic-lock rules.
- **Check the assertion:** run `pmset -g assertions` while active and look for **AwakeBar active session** owned by AwakeBar. After stop or exit, it should disappear. Activity assertions can expire automatically.
- **Uninstall:** quit and move the bundle to Trash. No daemon or login item is installed.
