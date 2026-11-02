// 奇光 ColorSnap — AIUI 智能体全局入口（生命周期 + 共享状态）
// 真实开发请在 AIUI Studio（aiui.rokid.com）导入本工程，使用模拟器 / 真机验证。

export default {
  onLaunch() {
    console.log('[ColorSnap] 奇光启动 · Rokid Color 全彩模式');
  },
  onShow() {
    console.log('[ColorSnap] 智能体进入前台');
  },
  onHide() {
    console.log('[ColorSnap] 智能体进入后台');
  },
  globalData: {
    // 预留：跨页面共享的抓拍库与当前滤镜
    shots: [],
    currentFilter: 'none'
  }
};
