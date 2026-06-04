const { app, BrowserWindow, dialog } = require('electron');
const { autoUpdater } = require('electron-updater');
const path = require('path');
const log = require('electron-log');

log.transports.file.level = 'info';
autoUpdater.logger = log;
autoUpdater.autoDownload = true;
autoUpdater.autoInstallOnAppQuit = true;

// OTA feed URL — السيرفر يستضيف latest.yml + .exe هنا
autoUpdater.setFeedURL({
  provider: 'generic',
  url: 'https://www.hndriver.company/downloads/desktop/admin/'
});

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    icon: path.join(__dirname, 'icon.ico'),
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false
    }
  });
  // الويب لايف — أي تعديل واجهة ينعكس فوراً
  mainWindow.loadURL('https://admin.hndriver.company');
  mainWindow.setMenuBarVisibility(false);
}

app.whenReady().then(() => {
  createWindow();

  // فحص التحديث بعد ثانيتين من الإقلاع
  setTimeout(() => autoUpdater.checkForUpdatesAndNotify(), 2000);
  // ثم كل 30 دقيقة
  setInterval(() => autoUpdater.checkForUpdates(), 30 * 60 * 1000);
});

autoUpdater.on('update-available', (info) => {
  log.info('تحديث متاح:', info.version);
});

autoUpdater.on('update-downloaded', (info) => {
  dialog.showMessageBox(mainWindow, {
    type: 'info',
    title: 'تحديث جاهز',
    message: `الإصدار ${info.version} تم تنزيله. سيتم تطبيقه عند إعادة التشغيل.`,
    buttons: ['إعادة تشغيل الآن', 'لاحقاً']
  }).then(result => {
    if (result.response === 0) autoUpdater.quitAndInstall();
  });
});

autoUpdater.on('error', (err) => log.error('OTA error:', err));

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});
