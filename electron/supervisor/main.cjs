const { app, BrowserWindow, dialog } = require('electron');
const { autoUpdater } = require('electron-updater');
const path = require('path');
const log = require('electron-log');

log.transports.file.level = 'info';
autoUpdater.logger = log;
autoUpdater.autoDownload = true;
autoUpdater.autoInstallOnAppQuit = true;

autoUpdater.setFeedURL({
  provider: 'generic',
  url: 'https://www.hndriver.company/downloads/desktop/supervisor/'
});

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    icon: path.join(__dirname, 'icon.ico'),
    webPreferences: { contextIsolation: true, nodeIntegration: false }
  });
  // المشرف يستخدم نفس واجهة الأدمن مع صلاحيات محدودة
  mainWindow.loadURL('https://admin.hndriver.company/?role=supervisor');
  mainWindow.setMenuBarVisibility(false);
}

app.whenReady().then(() => {
  createWindow();
  setTimeout(() => autoUpdater.checkForUpdatesAndNotify(), 2000);
  setInterval(() => autoUpdater.checkForUpdates(), 30 * 60 * 1000);
});

autoUpdater.on('update-downloaded', (info) => {
  dialog.showMessageBox(mainWindow, {
    type: 'info',
    title: 'تحديث جاهز',
    message: `الإصدار ${info.version} تم تنزيله. سيتم تطبيقه عند إعادة التشغيل.`,
    buttons: ['إعادة تشغيل الآن', 'لاحقاً']
  }).then(result => { if (result.response === 0) autoUpdater.quitAndInstall(); });
});

autoUpdater.on('error', (err) => log.error('OTA error:', err));
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
