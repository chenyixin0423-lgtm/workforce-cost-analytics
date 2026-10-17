# HR Cost Analytics System / 人力成本分析系统

**AI-assisted workforce cost analytics and management prototype**  
**AI 辅助开发的人力成本分析与管理原型系统**

A local web application that transforms employee rosters and compensation-change records into monthly cost views, workforce dashboards, data-quality reports, and actionable management insights. Designed around an illustrative HR dataset, it distinguishes **recorded payment-related events**, **modeled salary costs**, and **amounts awaiting confirmation** rather than treating estimates as verified cash expenditure.

一款本地运行的人力成本管理 Web 应用。它将员工花名册和薪酬变动流水转换为月度成本明细、组织分析看板、数据质量报告和管理决策参考。系统基于示例人力资源数据，明确区分**支付性质流水**、**工资模型估算**和**待确认金额**，不会把估算值误称为已核实的实际现金支出。

---

## English

### Key Features

- **Employee and workforce management:** Search, filter, sort, and inspect employee records, employment history, and compensation events.
- **Monthly cost analysis:** Model salary across probation, confirmation, and pay changes; include recorded social-insurance contributions, paid bonuses, and severance events where supported by the source data.
- **Interactive dashboards:** Explore cost trends, department and group breakdowns, geographic categories, and comparable reporting periods.
- **Cost-change attribution:** Separate the effects of pay increases, hiring, departures, and employment duration. Display unexplained differences instead of forcing the numbers to reconcile.
- **Data quality checks:** Flag conflicting employee IDs, missing values, ambiguous duplicates, unusual compensation entries, and other items that need HR or finance review.
- **Role-based access:** Administrators can view cost information, edit supplemental records, and export results; the OD role can only access non-compensation employee data. Sensitive API access is checked server-side.
- **CSV import and export:** Recalculate from source CSV files on restart, retain manual edits in a separate local overlay, and export monthly results in an Excel-friendly CSV format.

### Technology and Structure

Built with **JavaScript, Node.js, HTML, and CSS**, using Node's built-in HTTP server, a static browser frontend, CSV-based inputs, and a local JSON edit layer. No cloud service or database is required for the documented local workflow.

```text
hr-cost-analytics/
├── data/                # Input CSV datasets
├── public/              # Browser-based interface
├── runtime/             # Optional portable Node.js runtime
├── test/                # Automated tests
├── engine.js            # Parsing, cost modeling, attribution, data-quality rules
├── server.js            # Local HTTP server, APIs, access control
├── package.json         # Project metadata and scripts
├── start.cmd            # Windows quick-start script
└── README.md
```

**Data flow:** CSV employee roster + event records → calculation and quality engine → local HTTP APIs → dashboards, employee views, and CSV export. Manual changes are stored separately and do not overwrite the source CSVs.

### Data Model and Calculation Principles

Core entities include **Employee**, **CostEvent**, **MonthlyCost**, **QualityIssue**, and a separate **EditOverlay**. Employees are matched using employee IDs rather than names. Events have effective dates, enabling month-by-month calculations.

- **Salary:** Estimated from probation/regular salary rates and effective-date changes, prorated for employment days in a month.
- **Contributions and one-off items:** Recorded social-insurance contributions, paid annual-bonus events, and severance are associated with their respective months; bonus agreements are not treated as payments.
- **Pending grants:** TUP grants are shown as pending confirmation, not as verified cash payments.
- **Missing information:** Unknown is kept distinct from zero or not applicable. Suspicious duplicate payments are flagged for review rather than automatically double-counted or silently discarded.
- **Comparisons:** The supplied sample analysis compares matching January–August periods in 2025 and 2026. Cost attribution is presented with any residual/unexplained components visible.

The resulting cost model supports analysis, **not a certified total of actual cash expenditure**: the supplied source data lacks complete payment evidence and some currency confirmations.

### Quick Start (Windows x64)

1. Keep the project files together, including `runtime/node-v24.19.0-win-x64.zip` if using the portable startup method.
2. Double-click **`start.cmd`** at the project root. The script extracts the bundled portable Node.js runtime when needed and starts the local server.
3. Open **http://127.0.0.1:3000/** if the browser does not open automatically.

Local demonstration accounts (not suitable for a public deployment):

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `admin123` |
| OD | `od` | `od123` |

For a different dataset, replace `data/roster.csv` and `data/changes.csv` with files matching the expected schema, then restart. The system stores manual entries in `.runtime-edits.json` without modifying the original CSVs. The sample reporting cutoff defaults to August 2026; set `FDE_CUTOFF=YYYY-MM` before starting to select another cutoff. This application is intended for **local demonstration**, not public internet hosting.

### Testing and Validation

Run tests from this repository root with Node.js available:

```bash
node --test test/*.test.js
```

The original delivery documented tests for CSV parsing, monthly cost modeling, missing-value treatment, change attribution, duplicate/conflicting inputs, API permissions, exports, and repeated submissions. A Windows cold-start check without preinstalled Node.js was also documented. These are results reported for the original delivery; they have **not been independently rerun as part of this README rewrite**.

### AI-Assisted Development

This prototype was developed with **extensive AI coding assistance** across implementation, testing, debugging, documentation, and review. The workflow included a separate review pass and manual verification of disputed results. For example, it rejected treating estimated wages or TUP grants as verified payouts, and rejected labeling all unexplained cost changes as salary increases. AI involvement is disclosed rather than presenting the code as entirely hand-written.

### Scope and Limitations

This is a portfolio prototype based on an illustrative recruiting-assignment dataset, not an operational payroll or accounting system. Some source records are missing, contradictory, or lack supporting payment and currency evidence; the system reports those limitations rather than inventing figures. The demonstration credentials and local-only security model must not be used for production. Redistribution of the original supplied data should be assessed separately from the software code.

---

## 中文说明

### 主要功能

- **员工及组织管理：** 支持员工信息查询、筛选、排序，以及任职和薪酬事件查看。
- **月度成本分析：** 根据试用、转正、调薪等生效日期估算工资，并根据记录汇总社保、年终实发、补偿等项目。
- **交互式经营看板：** 展示成本趋势、部门与分组构成、地域分布以及可比时间区间的变化。
- **成本变化归因：** 分析调薪、增员、减员和在职月数变化的影响，未能解释的差额单独展示，不强行凑平。
- **数据质量检查：** 识别重复工号、缺失字段、疑似重复支付、异常薪酬记录等问题，并提示后续核对。
- **分角色权限：** 管理员可访问成本信息、录入补充变动和导出结果；OD 仅可查看非薪酬花名册，并由服务端限制敏感接口。
- **CSV 数据处理：** 启动时读取原始 CSV、重新计算分析结果，手工编辑独立保存，支持导出 Excel 可打开的 CSV 文件。

### 技术栈与项目结构

使用 **JavaScript、Node.js、HTML、CSS** 开发，后端基于 Node.js 内置 HTTP 服务，前端为静态网页；以 CSV 为输入，以本地 JSON 保存补充编辑内容。原始本地运行方案不需要数据库或云服务。

项目目录见上方英文部分。主要模块包括 `engine.js`（数据解析、成本模型与质量规则）、`server.js`（本地接口与权限）、`public/`（前端）、`data/`（输入数据）、`test/`（自动化测试）和 `start.cmd`（Windows 启动脚本）。

**处理流程：** 员工花名册与变动流水 CSV → 成本计算及质量检查 → 本地 HTTP 接口 → 管理看板、员工详情与 CSV 导出。手工变动独立保存，不会直接改写原始数据。

### 数据模型与计算原则

核心数据对象包括 **Employee（员工）**、**CostEvent（成本事件）**、**MonthlyCost（月度成本）**、**QualityIssue（质量问题）** 和 **EditOverlay（手工编辑层）**。以工号而非姓名识别员工，并根据事件生效日期进行月度计算。

- **工资：** 根据试用期、转正工资和调薪事件建立时间序列，按月内实际在职天数估算。
- **社保与一次性项目：** 根据原始记录的月份处理社保、年终实发及补偿；年终约定不等同于实际发放。
- **待确认授予：** TUP 授予单列，不当作已兑现现金。
- **缺失与重复：** 区分未知、零和不适用；疑似重复付款保留核对线索，不静默删除，也不直接重复计入。
- **跨年比较：** 原示例默认比较 2025 年与 2026 年各自的 1–8 月，并展示未归因的差异。

**可计算模型成本并非完整实际现金支出。** 原始数据缺少部分工资付款凭证及币种确认，系统会如实保留未知项。

### 快速运行（Windows x64）

1. 保持项目目录完整；若使用便携启动方式，请保留 `runtime/node-v24.19.0-win-x64.zip`。
2. 在项目根目录双击 **`start.cmd`**，脚本会在需要时解压便携 Node.js 并启动本地服务。
3. 如果浏览器未自动打开，访问 **http://127.0.0.1:3000/**。

演示账号为管理员 `admin / admin123`，OD 账号为 `od / od123`；仅供本地演示，不适合公网部署。

替换 `data/roster.csv` 与 `data/changes.csv` 为符合相同字段要求的数据后重启，即可重新计算。手工补充记录保存在 `.runtime-edits.json`，不会修改原始 CSV。默认分析截止月为 2026 年 8 月，可在启动前设置 `FDE_CUTOFF=YYYY-MM`。

### 测试与验证

在仓库根目录、可用 Node.js 的环境中执行：

```bash
node --test test/*.test.js
```

原始交付文档记录了 CSV 解析、月度成本及缺失值、成本归因、冲突和重复数据、API 权限、导出、重复提交等测试，以及未预装 Node.js 的 Windows 冷启动检查。**本次仅整理 README，未独立重新运行这些测试。**

### AI 辅助开发说明

项目在代码实现、测试、调试、文档整理及审查过程中**广泛使用 AI 编程工具**，并进行了独立复核及人工确认。例如，开发过程中否决了将工资估算或 TUP 授予直接视为实际支出的方案，也纠正了将所有未解释成本变化归为调薪的做法。项目不将 AI 生成的代码描述为完全人工手写。

### 已知限制

这是基于招聘作业示例数据制作的**作品集原型**，不是正式薪资或会计系统。部分原始数据存在缺失、冲突或缺少付款、币种佐证，相关金额和归因结果必须结合这些限制理解。演示账号及本地权限设计不适用于直接公网部署；原始提供的数据能否再分发，应与代码的公开权限分开判断。
