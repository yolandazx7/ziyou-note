# 自有 · 手记｜GitHub Pages + Supabase PWA

一个可安装到 iPhone 主屏幕的私人课题分离练习本。静态前端，无构建步骤；GitHub Pages 托管网页，Supabase Auth + Postgres 存储练习。

## 1. 创建 Supabase 项目

1. 前往 https://supabase.com/dashboard 新建项目，妥善保存数据库密码。
2. 打开 **SQL Editor**，粘贴并执行 `schema.sql` 的全部内容。
3. 在 **Authentication → Providers → Email** 开启 Email，建议开启 **Confirm email**。
4. 在 **Project Settings → API**（新版界面也可能是 **Connect / API Keys**）找到 **Project URL** 和 **publishable key**（或 legacy `anon` key）。
5. 编辑 `config.js`，填写上述两个值。**不要填 `service_role` 或 `secret` key**，也不要把数据库密码提交到 GitHub。

## 2. 部署 GitHub Pages

1. GitHub 新建 Public repository，例如 `ziyou-journal`。
2. 上传本文件夹里的 `index.html`、`config.js`、`schema.sql`、`sw.js`、`manifest.webmanifest`、两个图标以及 README。确保 `index.html` 在仓库根目录。
3. 仓库 **Settings → Pages → Build and deployment → Deploy from a branch → main / (root) → Save**。
4. 等待发布，访问 `https://你的用户名.github.io/ziyou-journal/`。
5. 返回 Supabase **Authentication → URL Configuration**：
   - **Site URL** 设置为 `https://你的用户名.github.io/ziyou-journal/`
   - **Redirect URLs** 增加 `https://你的用户名.github.io/ziyou-journal/**`
   - 用真实部署 URL 替换示例。邮件验证与密码重置需要正确的重定向设置。
6. 在网页上注册，完成邮箱验证后登录。新建练习并等待状态显示「云端已同步」。在另一设备登录同一账号验证数据同步。

> 注意：Supabase 默认邮件发送服务可能有发送速率、收件人限制；如正式长期使用，可配置自有 SMTP 服务。部署不需要 GitHub Actions secrets，因为浏览器只使用公开 publishable/anon key，真正的数据保护由 Auth + RLS 实现。

## 3. iPhone 安装

用 **Safari** 打开部署网址 → 分享 → **添加到主屏幕**。首次在线打开后可离线访问已缓存的页面；离线填写暂存在当前设备，恢复网络后自动尝试同步。建议定期导出 JSON 备份。

## 4. 数据和隐私

- 练习存放于 `public.entries` 的 `content` JSONB 列；每条记录绑定 `auth.uid()`。数据库启用 RLS，并只授权已登录用户访问自己的记录。
- 不要把私人 JSON 备份上传到公开仓库。`config.js` 里的 publishable/anon key 是公开客户端标识，不是管理员密钥。
- 会话令牌和离线草稿存储在浏览器 localStorage 中。**不是端到端加密**，不要在共享或不可信设备上登录；退出账号并不会自动清除设备上先前的离线草稿。
- 多设备编辑同一条记录时使用 revision 比较；发现版本冲突时尽量保留两份记录而不是覆盖。但在同时离线编辑、达到 100 条上限或设备存储丢失等边界情况下，仍可能需要手动检查并通过备份恢复。
- 目前不提供云端删除功能；需要彻底删除数据时可在 Supabase 数据库中操作。请先导出备份。
- 不适合存放高敏感或需要医疗级保护的记录。

## 5. 测试清单

- [ ] 注册、邮箱确认、登录
- [ ] 新建练习、刷新网页后内容仍在
- [ ] 等待「云端已同步」后在另一设备登录并看到记录
- [ ] 断网后编辑、恢复联网后同步
- [ ] 两台设备同时修改同一条记录，检查是否出现冲突副本
- [ ] JSON 导出、合并导入
- [ ] 密码重置邮件、重新登录
- [ ] iPhone 添加到主屏幕并再次启动

## 6. 项目结构

```
index.html             App 页面、表单、Auth REST API 与同步逻辑
config.js              Supabase 公共客户端配置（需自行填写）
schema.sql             表结构、RLS 策略、版本保护触发器
sw.js                  静态资源缓存、离线加载
manifest.webmanifest   PWA 元数据
icon-192.png           应用图标
icon-512.png           应用图标
```

## 技术限制

这是一个无需构建的初版 PWA，不是 App Store 原生应用。默认邮箱密码登录；不包含 Apple 登录、推送通知、端到端加密或服务端自动备份。跨设备同步依赖网络和 Supabase 服务可用性。


## 品牌与使用说明

本版本采用原创名称「自有 · 手记」、蓝紫灰配色及重新绘制的应用图标。练习问题是根据通用的情绪记录、责任区分与行动反思框架独立组织的，不使用截图中的产品标识或页面设计。名称、配色调整并不等于完成法律意义上的版权审查；请勿复制原商品的文字、排版或图像。
