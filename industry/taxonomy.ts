// 这个行业的分类体系：类别、标签词表、公司（主体）名录，以及防止张冠李戴的身份词典。
// 模型按这里的词表打标签，主题页（topics.json）按标签归类，筛选栏按类别分组。
// 换行业时：类别的 key 会出现在网址里（/all?category=…），上线后就不要再改；标签和名录可以随时增减。

/**
 * 网页上的类别（筛选栏、卡片角标、RSS 分类订阅）。key 是网址和接口里的身份，上线后不要改。
 * section 是日报里的分节标题（几个类别可以共用一节，按这里的顺序排）；guide 告诉模型怎么归类。
 * 没归上类的资料在日报里放进第一个 key 为 industry 的类别所在的节（没有就放最后一节）。
 */
export const CATEGORIES = [
  { key: "agent", label: "AI Agent", section: "AI Agent", guide: "通用/个人/企业智能体，自主规划、工具调用、浏览器与电脑操作、长任务、多智能体、Agent 运行时、记忆、评测与可观测、权限与沙箱。重点是 Agent 从 Demo 走向可执行复杂任务的生产系统" },
  { key: "coding", label: "AI Coding", section: "AI Coding", guide: "编码 Agent 与编码助手（Claude Code、Codex、Cursor、Copilot、Windsurf、Cline、Roo、Aider、Gemini CLI、Devin 等）：新版本、自动改代码/Debug/测试/Review/提 PR/解决 Issue/Git 操作，以及 SWE-bench 等软件工程能力评测" },
  { key: "models", label: "Models", section: "模型", guide: "新模型与版本、权重开放、推理/编码/Agent/工具调用/多模态/长上下文能力、API、价格与许可证、模型评测结果。营销式刷榜降权" },
  { key: "open-source", label: "Open Source", section: "开源项目", guide: "值得开发者研究或直接使用的开源 AI 项目：Agent、Coding Agent、MCP、LLM 框架、AI SDK、RAG、AI 搜索、自动化/工作流、本地与自部署。结合 Star 增速、活跃度、文档与实际可用性，不只看 Star 数" },
  { key: "mcp", label: "MCP / A2A", section: "MCP / A2A", guide: "MCP（Server/Client/Gateway/工具/资源/提示词/安全/市场）、A2A 与 Agent 互操作、Agent 连接互联网与真实工具的新协议、新标准、新 SDK 与生态" },
  { key: "devtools", label: "Developer Tools", section: "开发者工具", guide: "AI/Agent/LLM SDK、提示词工具、评测、可观测与调试、AI 测试、部署与监控、工作流与自动化等真正提升 AI 开发效率的工具" },
  { key: "infra", label: "Infrastructure", section: "AI 基础设施", guide: "GPU/AI 芯片、CUDA/ROCm、vLLM/SGLang/llama.cpp/Ollama、模型 Serving、推理与训练、分布式训练、AI 云、向量数据库、模型网关等降低成本、提升性能与 Agent 执行效率的技术" },
  { key: "research", label: "Research", section: "研究", guide: "可能影响 Agent 与 AI 软件开发的研究：推理、RLHF/RLAIF、测试时计算、长上下文、记忆、规划、工具使用、Computer Use、多模态、世界模型、合成数据、蒸馏、量化、高效推理/训练。优先有开源代码、Demo、基准或工程落地的工作" },
  { key: "security", label: "AI Security", section: "AI 安全", guide: "提示词注入（含间接注入）、工具投毒、MCP 安全、凭据与数据泄漏、沙箱逃逸、Agent 权限、AI 供应链、红队、模型与 Agent 安全。真实漏洞与重要安全研究提权" },
  { key: "applications", label: "Applications", section: "AI 应用", guide: "AI 搜索、AI 编码、AI 浏览器、研究与数据分析、设计、办公、教育、自动化、企业 SaaS、机器人等有技术创新的应用；普通 Chatbot、写作或图片生成应用无创新则降权" },
  { key: "industry", label: "Industry", section: "行业动态", guide: "与 AI 技术、Agent、模型、开发工具、Infra 或开发者生态相关的公司动作；监管与政策、市场与生态。普通融资、招聘、高管变动、营销与纯资本市场消息降权" },
] as const;

/**
 * 内容理解一步给每篇资料判的“内容类型”（写在 prompts/content-understanding.md 里，改了类型要同步改那份提示词）。
 * 评分提示词（prompts/selection-score.md）按类型给五个维度不同的权重。
 */
export const ITEM_TYPES = ["model_release", "product_launch", "tool_or_prompt", "research_paper", "industry_event", "opinion_analysis", "tutorial_explainer"] as const;

// ── 标签词表 ────────────────────────────────────────────────────────────────────────────

/** 每篇资料的第一个标签必须是这些“分类标签”之一。 */
export const CATEGORY_TAGS = [
  "Agent/智能体", "AI Coding", "模型发布", "开源/仓库", "MCP/A2A", "开发工具", "AI Infra", "论文/研究", "安全/对齐", "AI 应用",
  "产品更新", "教程/实践", "现象/趋势", "大佬观点", "评测/基准", "行业动态", "政策/监管",
  "非AI/通用工具", "其他",
] as const;

/** 可选的主题标签。 */
export const TOPIC_TAGS = [
  "Agent", "Coding Agent", "多智能体", "Agent 运行时", "Agent 记忆", "Agent 评测/可观测", "Agent 权限/沙箱",
  "编码", "MCP/工具调用", "A2A", "函数调用", "Computer Use", "浏览器操作",
  "推理", "长上下文", "多模态", "语音", "视频", "图像生成",
  "RAG", "搜索", "AI 搜索", "工作流/自动化",
  "数据/训练", "合成数据", "量化/压缩", "高效推理", "部署/工程", "端侧", "本地部署", "向量数据库",
  "开源生态", "具身智能",
] as const;

/** 可选的实体标签（公司、机构、平台）。 */
export const ENTITY_TAGS = [
  "OpenAI", "Anthropic", "Google", "DeepMind", "Microsoft", "Meta", "NVIDIA", "AWS", "GitHub", "Hugging Face",
  "xAI", "Mistral", "Qwen", "DeepSeek", "Moonshot", "Zhipu", "MiniMax", "ByteDance", "Baidu", "Tencent",
  "Cursor", "OpenRouter", "arXiv",
] as const;

/** 模型常写的近义词，统一成词表里的写法。 */
export const TAG_SYNONYMS: Readonly<Record<string, string>> = {
  "教程/玩法": "教程/实践", "技巧/最佳实践": "教程/实践", "合作/生态": "行业动态", "融资/收购": "行业动态", "公司动态": "行业动态",
  合作: "行业动态", 生态: "行业动态", 融资: "行业动态", 收购: "行业动态", 投资: "行业动态", 并购: "行业动态",
  政策: "政策/监管", 监管: "政策/监管", 法规: "政策/监管", 安全: "安全/对齐", 对齐: "安全/对齐",
  论文: "论文/研究", 研究: "论文/研究", paper: "论文/研究", papers: "论文/研究",
  "open-source": "开源/仓库", 开源: "开源/仓库", 仓库: "开源/仓库", repo: "开源/仓库",
  教程: "教程/实践", 玩法: "教程/实践", 指南: "教程/实践", 技巧: "教程/实践", 最佳实践: "教程/实践", 实践: "教程/实践",
  产品: "产品更新", 更新: "产品更新", 发布: "模型发布", 模型: "模型发布", 趋势: "现象/趋势", 现象: "现象/趋势", 观点: "大佬观点",
  视频生成: "视频", 非ai: "非AI/通用工具", "non-ai": "非AI/通用工具", 通用工具: "非AI/通用工具", 工程工具: "非AI/通用工具",
  安全扫描: "非AI/通用工具", devops: "非AI/通用工具", 行业: "行业动态", 动态: "行业动态",
  // 开发者情报站新增归一
  agent: "Agent/智能体", 智能体: "Agent/智能体", "智能体/Agent": "Agent/智能体",
  "coding agent": "Coding Agent", 编码agent: "Coding Agent", 代码agent: "Coding Agent",
  "ai coding": "AI Coding", 编码助手: "AI Coding",
  mcp: "MCP/A2A", a2a: "MCP/A2A", "agent 协议": "MCP/A2A",
  开发工具: "开发工具", sdk: "开发工具",
  infra: "AI Infra", 基础设施: "AI Infra", 推理框架: "AI Infra",
  应用: "AI 应用",
  函数调用: "函数调用", "function calling": "函数调用", "tool calling": "MCP/工具调用",
  "computer use": "Computer Use", 电脑操作: "Computer Use", 浏览器: "浏览器操作",
  长上下文: "长上下文", 记忆: "Agent 记忆", 可观测: "Agent 评测/可观测", 沙箱: "Agent 权限/沙箱", 权限: "Agent 权限/沙箱",
  自动化: "工作流/自动化", 工作流: "工作流/自动化", 向量库: "向量数据库",
  本地: "本地部署", 自部署: "本地部署", 量化: "量化/压缩", 压缩: "量化/压缩",
};

/** 模型漏了分类标签时，按内容类型补一个。 */
export const CATEGORY_BY_ITEM_TYPE: Readonly<Record<string, string>> = {
  model_release: "模型发布", product_launch: "产品更新", tool_or_prompt: "教程/实践", research_paper: "论文/研究",
  industry_event: "行业动态", opinion_analysis: "大佬观点", tutorial_explainer: "教程/实践",
};

// ── 公司与主体 ──────────────────────────────────────────────────────────────────────────

/** 公司主题：id → 显示名、卡片上显示的标签（null 表示只用 entity:<id> 归类）、别名。 */
export const ENTITIES: Record<string, { name: string; displayTag: string | null; aliases: string[] }> = {
  openai: { name: "OpenAI", displayTag: "OpenAI", aliases: ["OpenAI", "ChatGPT", "Sora", "Codex", "GPT"] },
  anthropic: { name: "Anthropic", displayTag: "Anthropic", aliases: ["Anthropic", "Claude"] },
  google: { name: "Google", displayTag: "Google", aliases: ["Google", "DeepMind", "Gemini", "谷歌"] },
  deepseek: { name: "DeepSeek", displayTag: "DeepSeek", aliases: ["DeepSeek", "深度求索"] },
  qwen: { name: "千问 Qwen", displayTag: null, aliases: ["Qwen", "通义", "阿里"] },
  kimi: { name: "Kimi / 月之暗面", displayTag: null, aliases: ["Kimi", "月之暗面", "Moonshot"] },
  minimax: { name: "MiniMax", displayTag: null, aliases: ["MiniMax", "海螺"] },
  zhipu: { name: "智谱 GLM", displayTag: null, aliases: ["智谱", "GLM", "Z.ai"] },
  xai: { name: "xAI", displayTag: "xAI", aliases: ["xAI", "Grok"] },
  meta: { name: "Meta", displayTag: "Meta", aliases: ["Meta", "Llama"] },
  microsoft: { name: "Microsoft", displayTag: "Microsoft", aliases: ["Microsoft", "微软", "Copilot"] },
  nvidia: { name: "NVIDIA", displayTag: null, aliases: ["NVIDIA", "英伟达"] },
  "hugging-face": { name: "Hugging Face", displayTag: "Hugging Face", aliases: ["Hugging Face"] },
  cursor: { name: "Cursor", displayTag: null, aliases: ["Cursor", "Anysphere"] },
  openrouter: { name: "OpenRouter", displayTag: null, aliases: ["OpenRouter"] },
  github: { name: "GitHub", displayTag: "GitHub", aliases: ["GitHub", "Github"] },
  aws: { name: "Amazon AWS", displayTag: "AWS", aliases: ["AWS", "Amazon AWS", "亚马逊云"] },
};

/**
 * 身份词典：摘要和标题里出现的公司，必须在原文里也出现过，否则退回原标题、丢掉摘要（防止模型张冠李戴）。
 * 行业没有这个问题时可以留空数组。
 */
export const IDENTITY_LEXICON: ReadonlyArray<{ id: string; name: string; patterns: RegExp[] }> = [
  { id: "openai", name: "OpenAI", patterns: [/openai|chatgpt|\bgpt-?[o\d]|\bsora\b|\bcodex\b/i] },
  { id: "anthropic", name: "Anthropic", patterns: [/anthropic|\bclaude\b/i, /\b(?:opus|sonnet|haiku)\s*\d+(?:[.\-]\d+)*\b/i, /\bfable\s*\d+(?:[.\-]\d+)*\b|\bmythos\b/i] },
  { id: "google", name: "Google / Gemini", patterns: [/google|deepmind|\bgemini\b|notebooklm|\bveo\s?\d|\bAlphaFold\b|\bAMIE\b/i] },
  { id: "deepseek", name: "DeepSeek", patterns: [/deepseek|深度求索/i] },
  { id: "xai", name: "xAI / Grok", patterns: [/\bxai\b|\bgrok\b/i] },
  { id: "meta", name: "Meta / Llama", patterns: [/\bMeta\b/, /\bmeta\s?ai\b|\bllama\b/i] },
  { id: "microsoft", name: "Microsoft / Copilot", patterns: [/microsoft|copilot|微软/i] },
  { id: "nvidia", name: "NVIDIA", patterns: [/nvidia|英伟达|\bnemotron\b|\bnemo\b|\bblackwell\b|\brubin(?:\s+ultra)?\b|\bcuda\b/i] },
  { id: "qwen", name: "千问 Qwen", patterns: [/\bqwen|通义|千问/i] },
  { id: "hugging-face", name: "Hugging Face", patterns: [/hugging\s?face/i] },
  { id: "cursor", name: "Cursor", patterns: [/\bCursor\b/] },
  { id: "kimi", name: "Kimi / 月之暗面", patterns: [/\bkimi\b|月之暗面|\bmoonshot\s?ai\b/i] },
  { id: "openrouter", name: "OpenRouter", patterns: [/openrouter/i] },
  { id: "minimax", name: "MiniMax", patterns: [/minimax/i] },
  { id: "zhipu", name: "智谱 GLM", patterns: [/智谱|\bglm-?[4-9]/i] },
  { id: "hunyuan", name: "腾讯混元", patterns: [/混元|hunyuan/i] },
  { id: "doubao", name: "字节豆包", patterns: [/豆包|doubao|字节跳动|bytedance/i] },
  { id: "mistral", name: "Mistral", patterns: [/mistral/i] },
  { id: "perplexity", name: "Perplexity", patterns: [/\bPerplexity\b/] },
  { id: "runway", name: "Runway", patterns: [/\brunway\b/i] },
  { id: "suno", name: "Suno", patterns: [/\bsuno\b/i] },
  { id: "midjourney", name: "Midjourney", patterns: [/midjourney/i] },
  { id: "stability-ai", name: "Stability AI", patterns: [/stability\s?ai/i] },
  { id: "elevenlabs", name: "ElevenLabs", patterns: [/eleven\s?labs/i] },
  { id: "vllm", name: "vLLM", patterns: [/\bvllm\b/i] },
  { id: "ollama", name: "Ollama", patterns: [/\bollama\b/i] },
  { id: "windsurf", name: "Windsurf", patterns: [/windsurf/i] },
  { id: "devin", name: "Devin", patterns: [/\bdevin\b/i] },
  { id: "manus", name: "Manus", patterns: [/\bmanus\b/i] },
  { id: "apple", name: "Apple AI", patterns: [/\bapple\s?(intelligence|silicon|ai)\b|苹果(智能|\s?AI)/i] },
  { id: "amazon", name: "Amazon / AWS", patterns: [/amazon|\baws\b|亚马逊/i] },
  { id: "baidu", name: "百度文心", patterns: [/百度|baidu|文心|\bernie\s?bot\b/i] },
];

/** 这些域名上的文章，发布方就是对应的公司（托管平台如 GitHub、arXiv 不算）。 */
export const PUBLISHER_DOMAINS: ReadonlyArray<{ entityId: string; domains: readonly string[] }> = [
  { entityId: "openai", domains: ["openai.com"] },
  { entityId: "anthropic", domains: ["anthropic.com", "claude.com"] },
  { entityId: "google", domains: ["deepmind.google", "ai.google", "blog.google"] },
  { entityId: "deepseek", domains: ["deepseek.com"] },
  { entityId: "xai", domains: ["x.ai"] },
  { entityId: "meta", domains: ["ai.meta.com"] },
  { entityId: "microsoft", domains: ["microsoft.com"] },
  { entityId: "nvidia", domains: ["nvidia.com"] },
  { entityId: "qwen", domains: ["qwen.ai"] },
  { entityId: "cursor", domains: ["cursor.com"] },
  { entityId: "openrouter", domains: ["openrouter.ai"] },
];

/** 原文里的这些写法也算提到了对应公司。 */
export const IDENTITY_CONTEXT_ALIASES: ReadonlyArray<{ entityId: string; pattern: RegExp }> = [
  { entityId: "meta", pattern: /@AIatMeta\b/i },
  { entityId: "zhipu", pattern: /\bZhipu(?:\s+AI\b|['’]s\b)/i },
];
