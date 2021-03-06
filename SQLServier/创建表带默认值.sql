USE [ProjectManage]
GO
CREATE TABLE [dbo].[tb_contract](
	[ct_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_contract_ct_code]  DEFAULT ('0000000000'),
	[ci_id] [int] NOT NULL CONSTRAINT [DF_tb_contract_ci_id]  DEFAULT ((0)),
	[ct_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_contract_ct_name]  DEFAULT (N'合同清单细目'),
	[ct_unit] [nvarchar](10) NULL CONSTRAINT [DF_tb_contract_ct_unit]  DEFAULT (N'm3'),
	[ct_qty] [float] NULL CONSTRAINT [DF_tb_contract_ct_qty]  DEFAULT ((0)),
	[ct_price] [float] NULL CONSTRAINT [DF_tb_contract_ct_price]  DEFAULT ((0)),
	[ct_money] [float] NULL CONSTRAINT [DF_tb_contract_ct_money]  DEFAULT ((0)),
	[ct_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_contract] PRIMARY KEY CLUSTERED
(
	[ct_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tb_budget](
	[bg_id] [varchar](20) NOT NULL CONSTRAINT [DF_tb_budget_bg_id]  DEFAULT ('0000000000'),
	[ct_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_ct_code]  DEFAULT ('0000000000'),
	[bg_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_bg_code]  DEFAULT ('1000000000'),
	[bg_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_budget_bg_name]  DEFAULT (N'单项概算细目'),
	[bg_unit] [nvarchar](10) NULL CONSTRAINT [DF_tb_budget_bg_unit]  DEFAULT (N'm3'),
	[bg_qty] [float] NULL CONSTRAINT [DF_tb_budget_bg_qty]  DEFAULT ((0)),
	[bg_price] [float] NULL CONSTRAINT [DF_tb_budget_bg_price]  DEFAULT ((0)),
	[bg_money] [float] NULL CONSTRAINT [DF_tb_budget_bg_money]  DEFAULT ((0)),
	[bg_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_budget] PRIMARY KEY CLUSTERED 
(
	[bg_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tb_budget_bak](
	[bg_id] [varchar](20) NOT NULL CONSTRAINT [DF_tb_budget_bak_bg_id]  DEFAULT ('0000000000'),
	[ct_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_bak_ct_code]  DEFAULT ('0000000000'),
	[bg_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_bak_bg_code]  DEFAULT ('1000000000'),
	[gd_code] [varchar](20) NULL CONSTRAINT [DF_tb_budget_bak_gd_code]  DEFAULT ('1000000000'),
	[gd_label] [char](3) NULL CONSTRAINT [DF_tb_budget_bak_gd_label]  DEFAULT ('A'),
	[gd_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_budget_bak_gd_name]  DEFAULT (N'指导价清单细目'),
	[gd_unit] [nvarchar](10) NULL CONSTRAINT [DF_tb_budget_bak_gd_unit]  DEFAULT (N'm3'),
	[bg_qty] [float] NULL CONSTRAINT [DF_tb_budget_bak_bg_qty]  DEFAULT ((0)),
	[gd_price] [float] NULL CONSTRAINT [DF_tb_budget_bak_gd_price]  DEFAULT ((0)),
	[bg_money] [float] NULL CONSTRAINT [DF_tb_budget_bak_bg_money]  DEFAULT ((0)),
	[qy_budget] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_budget]  DEFAULT ((0)),
	[qy_dwg_design] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_dwg_design]  DEFAULT ((0)),
	[qy_dwg_change] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_dwg_change]  DEFAULT ((0)),
	[qy_chk_design] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_chk_design]  DEFAULT ((0)),
	[qy_chk_change] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_chk_change]  DEFAULT ((0)),
	[qy_act_design] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_act_design]  DEFAULT ((0)),
	[qy_act_change] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_act_change]  DEFAULT ((0)),
	[qy_do_design] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_do_design]  DEFAULT ((0)),
	[qy_do_change] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_do_change]  DEFAULT ((0)),
	[qy_up_design] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_up_design]  DEFAULT ((0)),
	[qy_up_change] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_up_change]  DEFAULT ((0)),
	[qy_down_design] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_down_design]  DEFAULT ((0)),
	[qy_down_change] [float] NULL CONSTRAINT [DF_tb_budget_bak_qy_down_change]  DEFAULT ((0)),
	[bg_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_budget_bak] PRIMARY KEY CLUSTERED 
(
	[bg_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tb_guidance](
	[bg_code] [varchar](20) NOT NULL CONSTRAINT [DF_tb_guidance_bg_code]  DEFAULT ('1000000000'),
	[gd_code] [varchar](20) NULL CONSTRAINT [DF_tb_guidance_gd_code]  DEFAULT ('2000000000'),
	[gd_label] [char](3) NULL CONSTRAINT [DF_tb_guidance_gd_label]  DEFAULT ('A'),
	[gd_name] [nvarchar](100) NULL CONSTRAINT [DF_tb_guidance_gd_name]  DEFAULT (N'指导价清单细目'),
	[gd_unit] [nvarchar](10) NULL CONSTRAINT [DF_tb_guidance_gd_unit]  DEFAULT (N'm3'),
	[gd_rate] [float] NULL CONSTRAINT [DF_tb_guidance_gd_rate]  DEFAULT ((0)),
	[gd_price] [float] NULL CONSTRAINT [DF_tb_guidance_gd_price]  DEFAULT ((0)),
	[gd_item] [float] NULL CONSTRAINT [DF_tb_guidance_gd_item]  DEFAULT ((0)),
	[gd_wark] [nvarchar](255) NULL,
	[gd_cost] [nvarchar](255) NULL,
	[gd_role] [nvarchar](255) NULL,
	[gd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_guidance] PRIMARY KEY CLUSTERED 
(
	[bg_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tb_quantity_sum](
	[qy_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_qy_id]  DEFAULT ((0)),
	[pi_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_sum_pi_id]  DEFAULT ((0)),
	[qy_date] [date] NULL CONSTRAINT [DF_tb_quantity_sum_qy_date]  DEFAULT ((getdate())),
	[cy_code] [varchar](20) NULL CONSTRAINT [DF_tb_quantity_sum_cy_code]  DEFAULT ('3000000000'),
	[bg_id] [varchar](20) NULL CONSTRAINT [DF_tb_quantity_sum_ct_code]  DEFAULT ('0000000000'),
	[qy_budget] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_budget]  DEFAULT ((0)),
	[qy_dwg_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_dwg_design]  DEFAULT ((0)),
	[qy_dwg_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_dwg_change]  DEFAULT ((0)),
	[qy_chk_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_chk_design]  DEFAULT ((0)),
	[qy_chk_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_chk_change]  DEFAULT ((0)),
	[qy_act_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_act_design]  DEFAULT ((0)),
	[qy_act_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_act_change]  DEFAULT ((0)),
	[qy_do_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_do_design]  DEFAULT ((0)),
	[qy_do_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_do_change]  DEFAULT ((0)),
	[qy_up_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_up_design]  DEFAULT ((0)),
	[qy_up_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_up_change]  DEFAULT ((0)),
	[qy_down_design] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_down_design]  DEFAULT ((0)),
	[qy_down_change] [float] NULL CONSTRAINT [DF_tb_quantity_sum_qy_down_change]  DEFAULT ((0)),
	[qy_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_quantity_sum] PRIMARY KEY CLUSTERED 
(
	[qy_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[tb_quantity](
	[qy_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_qy_id]  DEFAULT ((0)),
	[pi_id] [int] NOT NULL CONSTRAINT [DF_tb_quantity_pi_id]  DEFAULT ((0)),
	[qy_date] [date] NULL CONSTRAINT [DF_tb_quantity_qy_date]  DEFAULT ((getdate())),
	[cy_code] [varchar](20) NULL CONSTRAINT [DF_tb_quantity_cy_code]  DEFAULT ('3000000000'),
	[bg_id] [varchar](20) NULL CONSTRAINT [DF_tb_quantity_ct_code]  DEFAULT ('0000000000'),
	[qy_do_design] [float] NULL CONSTRAINT [DF_tb_quantity_qy_do_design]  DEFAULT ((0)),
	[qy_do_change] [float] NULL CONSTRAINT [DF_tb_quantity_qy_do_change]  DEFAULT ((0)),
	[qy_up_design] [float] NULL CONSTRAINT [DF_tb_quantity_qy_up_design]  DEFAULT ((0)),
	[qy_up_change] [float] NULL CONSTRAINT [DF_tb_quantity_qy_up_change]  DEFAULT ((0)),
	[qy_down_design] [float] NULL CONSTRAINT [DF_tb_quantity_qy_down_design]  DEFAULT ((0)),
	[qy_down_change] [float] NULL CONSTRAINT [DF_tb_quantity_qy_down_change]  DEFAULT ((0)),
	[qy_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_quantity] PRIMARY KEY CLUSTERED 
(
	[qy_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE VIEW [dbo].[tp_budget_rep_sum]
AS
SELECT   TOP (100) PERCENT ct_code AS 清单编码, MIN(gd_name) AS 细目名称, MIN(gd_unit) AS 计量单位, SUM(bg_qty) 
                AS 概算数量, MIN(gd_price) AS 指导单价, SUM(bg_money) AS 清单合价, SUM(qy_dwg_design + qy_dwg_change) 
                AS 图纸数量, SUM(qy_chk_design + qy_chk_change) AS 复核数量, SUM(qy_act_design + qy_act_change) AS 现场数量, 
                SUM(qy_do_design + qy_do_change) AS 完成数量, SUM(qy_up_design + qy_up_change) AS 对上数量, 
                SUM(qy_down_change + qy_down_design) AS 对下数量
FROM      dbo.tb_budget_rep
GROUP BY ct_code

GO
CREATE VIEW [dbo].[tp_budget_sum]
AS
SELECT   TOP (100) PERCENT ct_code AS 清单编码, MIN(bg_name) AS 细目名称, MIN(bg_unit) AS 计量单位, SUM(bg_qty) 
                AS 清单数量, MIN(bg_price) AS 综合单价, SUM(bg_money) AS 清单合价
FROM      dbo.tb_budget
GROUP BY ct_code

GO
CREATE VIEW [dbo].[tp_quantity_sum]
AS
SELECT   ROW_NUMBER() OVER (ORDER BY bg_id) AS gy_id, MIN(pi_id) AS pi_id, MIN(qy_date) AS qy_date, MIN(cy_code) 
AS cy_code, bg_id, SUM(qy_do_design) AS qy_do_design, SUM(qy_do_change) AS qy_do_change, SUM(qy_up_design) 
AS qy_up_design, SUM(qy_up_change) AS qy_up_change, SUM(qy_down_design) AS qy_down_design, 
SUM(qy_down_change) AS qy_down_change, MIN(qy_info) AS qy_info
FROM      dbo.tb_quantity
GROUP BY bg_id

GO
CREATE VIEW [dbo].[tv_budget]
AS
SELECT  bg_id AS 预算ID, ct_code AS 清单编码, bg_code AS 定额编码, bg_name AS 细目名称, bg_unit AS 单位, bg_qty AS 数量, 
                   bg_price, bg_money AS 合价, bg_info AS 备注
FROM      dbo.tb_budget

GO
CREATE VIEW [dbo].[tv_contract]
AS
SELECT   ct_code AS 清单编码, ci_id AS 节点ID, ct_name AS 细目名称, ct_unit AS 计价单位, ct_qty AS 工程数量, 
                ct_price AS 综合单价, ct_money AS 合价, ct_info AS 备注
FROM      dbo.tb_contract

GO
CREATE VIEW [dbo].[tv_quantity]
AS
SELECT  qy_id AS 数量ID, pi_id AS 节点ID, qy_date AS 施工日期, cy_code AS 劳务编号, bg_id AS 预算ID, 
                   qy_do_design AS 已完设计数量, qy_do_change AS 已完变更数量, qy_up_design AS 对上计价设计数量, 
                   qy_up_change AS 对上计价变更数量, qy_down_design AS 对下计价设计数量, qy_down_change AS 对下计价变更数量, 
                   qy_info AS 备注
FROM      dbo.tb_quantity

GO
CREATE VIEW [dbo].[tv_quantity_sum]
AS
SELECT   qy_id AS 数量ID, pi_id AS 节点ID, qy_date AS 施工日期, cy_code AS 劳务编号, bg_id AS 预算ID, 
                qy_budget AS 分项概算数量, qy_dwg_design AS 图纸设计数量, qy_dwg_change AS 图纸变更数量, 
                qy_chk_design AS 复核图纸设计数量, qy_chk_change AS 复核图纸变更数量, qy_act_design AS 现场设计数量, 
                qy_act_change AS 现场变更数量, qy_do_design AS 已完设计数量, qy_do_change AS 已完变更数量, 
                qy_up_design AS 对上计价设计数量, qy_up_change AS 对上计价变更数量, qy_down_design AS 对下计价设计数量, 
                qy_down_change AS 对下计价变更数量, qy_info AS 备注
FROM      dbo.tb_quantity_sum

GO
CREATE VIEW [dbo].[tp_quantity]
AS
SELECT   dbo.tb_quantity.qy_id AS 数量ID, dbo.tb_quantity.pi_id AS 节点ID, dbo.tb_quantity.qy_date AS 施工日期, 
                dbo.tb_quantity.cy_code AS 劳务编号, dbo.tb_guidance.gd_name AS 细目名称, dbo.tb_guidance.gd_unit AS 单位, 
                dbo.tb_quantity.qy_do_design AS 已完设计数量, dbo.tb_quantity.qy_do_change AS 已完变更数量, 
                dbo.tb_quantity.qy_up_design AS 对上计价设计数量, dbo.tb_quantity.qy_up_change AS 对上计价变更数量, 
                dbo.tb_quantity.qy_down_design AS 对下计价设计数量, dbo.tb_quantity.qy_down_change AS 对下计价变更数量, 
                dbo.tb_quantity.qy_info AS 备注
FROM      dbo.tb_quantity LEFT OUTER JOIN
                dbo.tb_budget ON dbo.tb_quantity.bg_id = dbo.tb_budget.bg_id LEFT OUTER JOIN
                dbo.tb_guidance ON dbo.tb_budget.bg_code = dbo.tb_guidance.bg_code
