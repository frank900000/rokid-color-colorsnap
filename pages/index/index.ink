<script def>
{
  "navigationBarTitleText": "奇光 ColorSnap"
}
</script>

<script setup>
export default {
  data: {
    filters: [
      { key: 'none',  label: '原图' },
      { key: 'retro', label: '复古' },
      { key: 'neon',  label: '赛博霓虹' },
      { key: 'dream', label: '梦幻' },
      { key: 'anime', label: '动漫' },
      { key: 'dopa',  label: '多巴胺' }
    ],
    currentFilter: 'none',
    shots: [],
    film: null,
    hint: 'Ring 单击或点按快门，抓拍你的全彩瞬间'
  },

  onLoad() {
    console.log('[ColorSnap] 页面加载 · 全彩 AR 滤镜就绪');
  },

  // 选择滤镜
  selectFilter(e) {
    this.setData({ currentFilter: e.currentTarget.dataset.key });
  },

  // 第一视角抓拍（Ring 单击或点按快门触发）
  capture() {
    const shots = this.data.shots;
    const id = shots.length + 1;
    this.setData({
      shots: shots.concat([{ id: id, filter: this.data.currentFilter }]),
      hint: '已抓拍第 ' + id + ' 张 · 滤镜「' + this.data.currentFilter + '」'
    });
  },

  // AI 一键成片：挑选最佳帧 + 自动字幕 + 配乐 + 全彩排版
  makeFilm() {
    if (this.data.shots.length === 0) {
      this.setData({ hint: '还没有底片，先抓拍几张吧' });
      return;
    }
    const captions = ['我的全彩一日', 'City Walk 全彩碎片', '把黄昏装进眼镜', '第一视角的小确幸', '今天也是彩色的'];
    const cover = this.data.shots[Math.floor(this.data.shots.length / 2)];
    const caption = captions[Math.floor(Math.random() * captions.length)];
    this.setData({
      film: {
        coverFilter: cover.filter,
        caption: caption,
        music: 'Lo-Fi Sunset',
        tags: ['#RokidColor全彩', '#第一视角', '#AI成片'],
        sharedTo: ''
      },
      hint: 'AI 成片完成，确认后可分享'
    });
  },

  // 生成分享卡片（需用户确认）
  share(e) {
    if (!this.data.film) return;
    const to = e.currentTarget.dataset.to;
    this.setData({
      'film.sharedTo': to,
      hint: '已生成「' + to + '」分享卡片，请在乐奇分享通道确认发布'
    });
  },

  // 清空重来
  reset() {
    this.setData({ shots: [], film: null, hint: '已清空，重新开始创作' });
  }
}
</script>

<page>
  <view class="container">
    <text class="brand">奇光 ColorSnap · Rokid Color 全彩</text>

    <!-- 全彩 AR 滤镜预览 + 第一视角 -->
    <view class="cam cam-{{currentFilter}}">
      <text class="cam-tag">第一视角 · {{currentFilter}}</text>
      <text class="ring-hint">Ring 单击 = 抓拍</text>
    </view>

    <!-- 滤镜选择 -->
    <scroll-view class="filters" scroll-x="true">
      <view wx:for="{{filters}}" wx:key="key"
            class="chip {{currentFilter === item.key ? 'active' : ''}}"
            data-key="{{item.key}}" bindtap="selectFilter">{{item.label}}</view>
    </scroll-view>

    <!-- 底片 -->
    <text class="count">我的底片 ({{shots.length}})</text>
    <scroll-view class="strip" scroll-x="true">
      <view wx:for="{{shots}}" wx:key="id" class="thumb thumb-{{item.filter}}">
        <text class="thumb-id">{{item.id}}</text>
      </view>
    </scroll-view>

    <!-- 操作 -->
    <button class="shutter" bindtap="capture">📸 抓拍</button>
    <button class="ai-btn" disabled="{{shots.length === 0}}" bindtap="makeFilm">✨ AI 一键成片</button>
    <button class="reset-btn" bindtap="reset">清空重来</button>

    <text class="hint">{{hint}}</text>

    <!-- 成片卡片（沉浸页） -->
    <view class="mask" wx:if="{{film}}">
      <view class="hero hero-{{film.coverFilter}}">
        <text class="hero-cap">{{film.caption}}</text>
      </view>
      <text class="meta">AI 成片 · ♪ {{film.music}}</text>
      <view class="tags">
        <text wx:for="{{film.tags}}" wx:key="*this" class="tag">{{item}}</text>
      </view>
      <view class="share-row">
        <view class="share" data-to="小红书" bindtap="share">小红书</view>
        <view class="share" data-to="朋友圈" bindtap="share">朋友圈</view>
        <view class="share" data-to="微博" bindtap="share">微博</view>
      </view>
      <text class="shared" wx:if="{{film.sharedTo}}">已生成「{{film.sharedTo}}」分享卡片 ✓</text>
    </view>
  </view>
</page>

<style>
.container {
  display: flex;
  flex-direction: column;
  padding: 16rpx;
  color: #f4f4fb;
  background: #0b0b14;
  min-height: 100vh;
}
.brand { font-size: 30rpx; font-weight: 800; margin: 8rpx 4rpx; }

.cam {
  position: relative;
  width: 100%;
  height: 360rpx;
  border-radius: 24rpx;
  overflow: hidden;
  background: linear-gradient(135deg, #23233a, #0b0b14);
}
.cam-tag { position: absolute; top: 14rpx; left: 14rpx; font-size: 22rpx; background: rgba(0,0,0,.45); padding: 6rpx 14rpx; border-radius: 14rpx; color: #2de2e6; }
.ring-hint { position: absolute; bottom: 14rpx; right: 14rpx; font-size: 20rpx; background: rgba(0,0,0,.45); padding: 6rpx 14rpx; border-radius: 14rpx; color: #ffd166; }

/* 全彩滤镜预览（不同滤镜对应不同色偏，模拟 AR 叠加） */
.cam-none  { background: linear-gradient(135deg, #2a2a40, #0b0b14); }
.cam-retro { background: linear-gradient(135deg, #6b4a2b, #2a1c10); filter: sepia(.4); }
.cam-neon  { background: linear-gradient(135deg, #00e5ff, #ff2bd6); }
.cam-dream { background: linear-gradient(135deg, #ffb6e6, #b6c8ff); }
.cam-anime { background: linear-gradient(135deg, #1fa2ff, #12d8b8); }
.cam-dopa  { background: linear-gradient(135deg, #ff5ca8, #ffd166, #2de2e6); }

.filters { display: flex; white-space: nowrap; margin: 16rpx 0; }
.chip {
  flex: 0 0 auto; padding: 12rpx 22rpx; border-radius: 24rpx; font-size: 24rpx;
  color: #a9a9c4; background: rgba(255,255,255,.06);
  border: 1rpx solid rgba(255,255,255,.12); margin-right: 12rpx;
}
.chip.active { color: #fff; background: linear-gradient(90deg, #7c5cff, #ff5ca8); border-color: transparent; font-weight: 700; }

.count { font-size: 24rpx; color: #a9a9c4; margin: 8rpx 4rpx; }
.strip { display: flex; white-space: nowrap; }
.thumb {
  flex: 0 0 auto; width: 150rpx; height: 200rpx; border-radius: 16rpx; margin-right: 12rpx;
  display: flex; align-items: flex-end; justify-content: flex-end; padding: 8rpx; color: #fff; font-size: 20rpx;
}
.thumb-none  { background: linear-gradient(135deg, #2a2a40, #0b0b14); }
.thumb-retro { background: linear-gradient(135deg, #6b4a2b, #2a1c10); }
.thumb-neon  { background: linear-gradient(135deg, #00e5ff, #ff2bd6); }
.thumb-dream { background: linear-gradient(135deg, #ffb6e6, #b6c8ff); }
.thumb-anime { background: linear-gradient(135deg, #1fa2ff, #12d8b8); }
.thumb-dopa  { background: linear-gradient(135deg, #ff5ca8, #ffd166, #2de2e6); }

.shutter { margin-top: 18rpx; padding: 24rpx; border-radius: 20rpx; color: #0b0b14; font-weight: 800; font-size: 30rpx; background: #ffffff; }
.ai-btn { margin-top: 14rpx; padding: 26rpx; border-radius: 20rpx; color: #0b0b14; font-weight: 800; font-size: 30rpx; background: linear-gradient(90deg, #ffd166, #ff5ca8); }
.ai-btn[disabled] { opacity: .5; }
.reset-btn { margin-top: 12rpx; padding: 18rpx; border-radius: 18rpx; color: #a9a9c4; font-size: 24rpx; background: rgba(255,255,255,.06); border: 1rpx solid rgba(255,255,255,.12); }

.hint { font-size: 22rpx; color: #2de2e6; margin: 12rpx 4rpx; min-height: 30rpx; }

.mask { position: fixed; left: 0; top: 0; right: 0; bottom: 0; background: rgba(5,5,12,.8); display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 32rpx; }
.hero { width: 520rpx; height: 640rpx; border-radius: 24rpx; display: flex; align-items: flex-end; padding: 24rpx; }
.hero-none  { background: linear-gradient(135deg, #2a2a40, #0b0b14); }
.hero-retro { background: linear-gradient(135deg, #6b4a2b, #2a1c10); }
.hero-neon  { background: linear-gradient(135deg, #00e5ff, #ff2bd6); }
.hero-dream { background: linear-gradient(135deg, #ffb6e6, #b6c8ff); }
.hero-anime { background: linear-gradient(135deg, #1fa2ff, #12d8b8); }
.hero-dopa  { background: linear-gradient(135deg, #ff5ca8, #ffd166, #2de2e6); }
.hero-cap { color: #fff; font-size: 34rpx; font-weight: 800; text-shadow: 0 2rpx 8rpx rgba(0,0,0,.6); }
.meta { font-size: 22rpx; color: #a9a9c4; margin: 16rpx 0 8rpx; }
.tags { display: flex; flex-wrap: wrap; justify-content: center; }
.tag { font-size: 20rpx; color: #2de2e6; margin: 6rpx; padding: 4rpx 12rpx; border: 1rpx solid rgba(45,226,230,.4); border-radius: 14rpx; }
.share-row { display: flex; gap: 16rpx; margin-top: 18rpx; }
.share { flex: 1; text-align: center; padding: 20rpx 0; border-radius: 16rpx; font-size: 24rpx; font-weight: 700; color: #fff; background: rgba(255,255,255,.1); border: 1rpx solid rgba(255,255,255,.12); }
.shared { font-size: 22rpx; color: #ffd166; margin-top: 16rpx; }
</style>
