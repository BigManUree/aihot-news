// 站点身份和读者看得到的文案。换成你的行业时，先改这个文件。
// 网页和后端都读它；改完重新构建（docker compose up --build）即可生效。
// 域名不在这里：部署时用环境变量 SITE_URL 设置。

export const SITE = {
  /** 站名：导航、页面标题、分享图、RSS、MCP、后台都用它。 */
  name: "AIHOT",
  /**
   * 行业词：拼进默认说法里，比如“AI 日报”“AI 动态”。
   * 本站只盯 AI 开发领域，保持 AI。
   */
  subject: "AI",
  /** 首页的完整标题（浏览器标签、搜索结果）。 */
  homeTitle: "AIHOT — AI Agent 互联网技术情报站 · 每日精选与日报",
  /** 一句话介绍：搜索引擎、分享卡片、RSS、llms.txt 会用。 */
  description: "面向 AI 开发者的技术情报站：自动盯住官方博客、GitHub、arXiv 与技术媒体，用模型筛选真正值得关注的 Agent、Coding Agent、MCP、开源项目、模型与 AI Infra 动态，归并同一事件，每天出一份日报。",
  /** 首页左上角和侧边栏下面的一行小字。 */
  tagline: "发现 AI 技术世界真正值得关注的变化",
  /** 界面语言（HTML lang、og:locale）。 */
  locale: "zh-CN",
  /** 默认域名，只在没设置 SITE_URL 时使用。 */
  defaultUrl: "http://localhost:3000",
  /**
   * MCP 工具名的前缀（小写字母、数字、下划线），工具会叫 aihot_get_latest、aihot_search……
   * 已经有人接入后就不要再改。
   */
  mcpPrefix: "aihot",
  /** 对外联系邮箱（选填）：使用规则、llms.txt、响应头里会写。 */
  contactEmail: null as string | null,
  /** 页脚的一行小字（选填）。 */
  footerNote: "由 AIHOT 开源框架驱动",
  /** 中国大陆网站的 ICP 备案号（选填），填了就显示在页脚并链接到工信部备案系统。 */
  icp: null as string | null,
  /** 结构化数据里的网站运营者（搜索引擎用）。 */
  organization: {
    name: "AIHOT",
    /** 创始人（选填）：{ name, url, description }。 */
    founder: null as null | { name: string; url?: string; description?: string },
  },
  /** 抓取信源时报上的名字（User-Agent 里用），不要冒用别的站。 */
  crawlerName: "AIHOTBot",
} as const;

/** 关于页的文案。数字（信源数、收录数、精选数、日报期数）来自站内实时统计，不用写在这里。 */
export const ABOUT = {
  kicker: `关于 ${SITE.name}`,
  /** 大标题：第一行正常颜色，第二行强调色。 */
  headline: ["AI 每天都有海量信息，", "真正值得开发者看的，只有几条。"] as [string, string],
  /** 标题下面的一段话。{sources} 会换成实时的信源数。 */
  lead: `${SITE.name} 替你盯着 {sources} 个信源：从官方博客、GitHub、arXiv 到技术媒体，抓取、归并、打分、精选，只留下可能改变 AI 开发方式的变化，每天早上 8 点出一份日报。免费，不用注册。`,
  /** 信源河动画下面的四个环节。 */
  steps: {
    collect: "优先看官方一手来源：厂商博客、GitHub Release、官方文档，再到 arXiv 与技术媒体；活跃的源 15 分钟就看一次。",
    store: "抓到的都存下来，同一件事的官方稿、媒体稿和社区讨论归到一起，一个热点只留一条并附原始来源；只计入热度的账号也参与热度计算。",
    select: "模型按技术影响力、开发者影响、Agent 影响、可用性与开源程度打分，写中文标题、摘要和推荐理由；融资软文、标题党、重复转载和普通 Chatbot 进不来。",
    publish: "每天 08:00 出日报，周一出周报，每月 1 日出月报；除了发生了什么，还会标出哪些开源项目值得你亲自拉下来试试。",
  },
  /**
   * 作者块（选填），null 就不显示。
   * avatarSourceId：一个 X 账号信源的 id，头像取它的（选填）。
   * 二维码在后台“设置”里上传，或者放进 industry/brand/contact/；没有二维码就不显示那张卡片。
   */
  maker: null as null | {
    name: string;
    greeting: string[];
    avatarSourceId?: string | null;
    wechat?: { title: string; note: string };
    feishu?: { title: string; note: string };
  },
  /** 页面底部的版权与下架说明（结尾会接“反馈页”的链接）。 */
  copyright: `${SITE.name} 是聚合摘要和阅读索引，原文版权归各来源所有。如果你是来源方，希望更正、下架或调整展示方式，可以通过`,
} as const;

/** “AI 日报”这类说法：行业词和名词之间，英文词加空格，中文词不加。 */
export function withSubject(noun: string): string {
  return /[A-Za-z0-9]$/.test(SITE.subject) ? `${SITE.subject} ${noun}` : `${SITE.subject}${noun}`;
}

/** “按主题看 AI”“往期 AI 日报”这类说法：行业词接在中文后面，英文词前加空格，中文词不加；noun 照 withSubject 接上。 */
export function subjectAfter(text: string, noun?: string): string {
  const gap = /^[A-Za-z0-9]/.test(SITE.subject) ? " " : "";
  return `${text}${gap}${noun ? withSubject(noun) : SITE.subject}`;
}
