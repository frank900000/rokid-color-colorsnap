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
    generating: false,
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

  // AI 一键成片：真实 LanguageModel 生成字幕 + 按情绪自动配乐（能力不可用时本地启发式兜底）
  async makeFilm() {
    if (this.data.shots.length === 0) {
      this.setData({ hint: '还没有底片，先抓拍几张吧' });
      return;
    }
    this.setData({ generating: true, hint: 'AI 正在生成字幕与配乐…' });

    const shots = this.data.shots;
    const cover = shots[Math.floor(shots.length / 2)];
    const filtersUsed = [];
    shots.forEach(function (s) { if (filtersUsed.indexOf(s.filter) < 0) filtersUsed.push(s.filter); });
    const ctx = { count: shots.length, filters: filtersUsed, hour: new Date().getHours() };

    let caption = '';
    let subtitle = '';
    try {
      const status = await LanguageModel.availability();
      if (status === 'available') {
        const session = await LanguageModel.create({
          initialPrompts: [{
            role: 'system',
            content: '你是 Rokid Color 双目全彩眼镜的第一视角 Vlog AI 剪辑师，擅长用极短中文写出有画面感的成片标题与字幕。'
          }]
        });
        const raw = await session.prompt(
          '我抓拍了 ' + ctx.count + ' 张第一视角照片，用了这些滤镜：' + ctx.filters.join('、') +
          '。请给我两行：第一行为不超过 12 字的中文标题；第二行为不超过 20 字的中文字幕。只输出这两行，不要解释。'
        );
        const lines = String(raw).split('\n').map(function (s) { return s.trim(); }).filter(Boolean);
        caption = lines[0] || this.fallbackCaption(ctx);
        subtitle = lines[1] || this.fallbackSubtitle(ctx);
        if (session && session.destroy) { try { session.destroy(); } catch (e) {} }
      } else {
        caption = this.fallbackCaption(ctx);
        subtitle = this.fallbackSubtitle(ctx);
      }
    } catch (e) {
      caption = this.fallbackCaption(ctx);
      subtitle = this.fallbackSubtitle(ctx);
    }

    const music = this.pickMusic(cover.filter);
    this.setData({
      generating: false,
      film: {
        coverFilter: cover.filter,
        caption: caption,
        subtitle: subtitle,
        music: music.name,
        mood: music.mood,
        tags: ['#RokidColor全彩', '#第一视角', '#AI成片'],
        sharedTo: ''
      },
      hint: 'AI 成片完成，确认后可分享'
    });
  },

  // 配乐：按主滤镜情绪自动匹配
  pickMusic(filter) {
    const map = {
      none:  { name: 'Lo-Fi Sunset', mood: '极简松弛' },
      retro: { name: 'Retro City',   mood: '复古 CityPop' },
      neon:  { name: 'Neon Drive',   mood: '赛博电子' },
      dream: { name: 'Dream Pop',    mood: '梦幻流行' },
      anime: { name: 'Anime Vibes',  mood: '日系轻音' },
      dopa:  { name: 'Dopa Beats',  mood: '活力舞曲' }
    };
    return map[filter] || map.none;
  },

  // 本地兜底标题（模型不可用时）
  fallbackCaption(ctx) {
    const titles = {
      none:  ['把今天装进眼镜', '第一视角的小确幸', '今天也是彩色的'],
      retro: ['旧时光的暖调', '像一张泛黄明信片'],
      neon:  ['夜色里的赛博诗', '霓虹是我给夜的注脚'],
      dream: ['做了一个彩色的梦', '云朵掉进了镜头'],
      anime: ['像动画里的那一帧', '夏日番的片尾'],
      dopa:  ['把快乐调成满格', '多巴胺炸开的下午']
    };
    const list = titles[ctx.filters[0]] || titles.none;
    return list[ctx.count % list.length];
  },

  // 本地兜底字幕（结合时段 + 张数）
  fallbackSubtitle(ctx) {
    let when = '午后';
    const h = ctx.hour;
    if (h < 6) when = '凌晨';
    else if (h < 11) when = '清晨';
    else if (h < 14) when = '正午';
    else if (h < 18) when = '傍晚';
    else if (h < 22) when = '夜晚';
    else when = '深夜';
    return when + ' · 用 Rokid Color 抓拍的 ' + ctx.count + ' 个全彩瞬间';
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
    this.setData({ shots: [], film: null, generating: false, hint: '已清空，重新开始创作' });
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
    <button class="ai-btn" disabled="{{shots.length === 0 || generating}}" bindtap="makeFilm">
      {{ generating ? 'AI 生成中…' : '✨ AI 一键成片' }}
    </button>
    <button class="reset-btn" bindtap="reset">清空重来</button>

    <text class="hint">{{hint}}</text>

    <!-- 成片卡片（沉浸页） -->
    <view class="mask" wx:if="{{film}}">
      <view class="hero hero-{{film.coverFilter}}">
        <text class="hero-cap">{{film.caption}}</text>
        <text class="hero-sub">{{film.subtitle}}</text>
      </view>
      <text class="meta">AI 成片 · ♪ {{film.music}} · {{film.mood}}</text>
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
.cam-retro { background: linear-gradient(135deg, #6b4a2b, #2a1c10); }
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
.hero { width: 520rpx; height: 640rpx; border-radius: 24rpx; display: flex; flex-direction: column; align-items: flex-start; justify-content: flex-end; padding: 24rpx; }
.hero-none  { background: linear-gradient(135deg, #2a2a40, #0b0b14); }
.hero-retro { background: linear-gradient(135deg, #6b4a2b, #2a1c10); }
.hero-neon  { background: linear-gradient(135deg, #00e5ff, #ff2bd6); }
.hero-dream { background: linear-gradient(135deg, #ffb6e6, #b6c8ff); }
.hero-anime { background: linear-gradient(135deg, #1fa2ff, #12d8b8); }
.hero-dopa  { background: linear-gradient(135deg, #ff5ca8, #ffd166, #2de2e6); }
.hero-cap { color: #fff; font-size: 38rpx; font-weight: 800; text-shadow: 0 2rpx 8rpx rgba(0,0,0,.6); }
.hero-sub { color: rgba(255,255,255,.92); font-size: 24rpx; margin-top: 8rpx; text-shadow: 0 2rpx 6rpx rgba(0,0,0,.6); }
.meta { font-size: 22rpx; color: #a9a9c4; margin: 16rpx 0 8rpx; }
.tags { display: flex; flex-wrap: wrap; justify-content: center; }
.tag { font-size: 20rpx; color: #2de2e6; margin: 6rpx; padding: 4rpx 12rpx; border: 1rpx solid rgba(45,226,230,.4); border-radius: 14rpx; }
.share-row { display: flex; gap: 16rpx; margin-top: 18rpx; }
.share { flex: 1; text-align: center; padding: 20rpx 0; border-radius: 16rpx; font-size: 24rpx; font-weight: 700; color: #fff; background: rgba(255,255,255,.1); border: 1rpx solid rgba(255,255,255,.12); }
.shared { font-size: 22rpx; color: #ffd166; margin-top: 16rpx; }
</style>
