//Got code from https://github.com/electron/electron/blob/master/docs/tutorial/quick-start.md
const {app, BrowserWindow} = require('electron')

let win

function createWindow () {
  win = new BrowserWindow({width: 800, height:600, webPreferences: {nodeIntegration: false}});
  win.loadURL('https://www.example.com/');

  win.on('closed', () => {
    win = null
  })
}

app.on('ready', createWindow)

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  if (win === null) {
    createWindow()
  }
})
