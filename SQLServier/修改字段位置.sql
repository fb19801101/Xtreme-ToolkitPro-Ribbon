USE [ProjectManage]
GO
SELECT name,colid FROM syscolumns WHERE id = object_id('tb_road_qty') ORDER BY colid

/****** Object:  Table [dbo].[tb_bridge_down]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_bridge_down]
CREATE TABLE [dbo].[tb_bridge_down](
	[bd_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[bl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[f5] [int],
	[f6] [int],
	[bd_qty_pre_design] [float] NOT NULL,
	[bd_qty_pre_change] [float] NOT NULL,
	[bd_qty_cur_design] [float] NOT NULL,
	[bd_qty_cur_change] [float] NOT NULL,
	[bd_time] [date] NOT NULL,
	[bd_estab] [nvarchar](5) NOT NULL,
	[bd_check] [nvarchar](5) NOT NULL,
	[bd_audit] [nvarchar](5) NOT NULL,
	[bd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_down] PRIMARY KEY CLUSTERED 
(
	[bd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_bridge_down] DROP COLUMN [f1],[f2],[f3],[f4],[f5],[f6]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_bridge_qty]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_bridge_qty]
CREATE TABLE [dbo].[tb_bridge_qty](
	[bq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[bl_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[bq_qty_dwg_design] [float] NOT NULL,
	[bq_qty_dwg_change] [float] NOT NULL,
	[bq_qty_chk_design] [float] NOT NULL,
	[bq_qty_chk_change] [float] NOT NULL,
	[bq_qty_doe_design] [float] NOT NULL,
	[bq_qty_doe_change] [float] NOT NULL,
	[bq_time] [date] NOT NULL,
	[bq_estab] [nvarchar](5) NOT NULL,
	[bq_check] [nvarchar](5) NOT NULL,
	[bq_audit] [nvarchar](5) NOT NULL,
	[bq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_qty] PRIMARY KEY CLUSTERED 
(
	[bq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_bridge_qty] DROP COLUMN [f1],[f2],[f3]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_bridge_up]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_bridge_up]
CREATE TABLE [dbo].[tb_bridge_up](
	[bu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[bl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[bu_qty_pre_design] [float] NOT NULL,
	[bu_qty_pre_change] [float] NOT NULL,
	[bu_qty_cur_design] [float] NOT NULL,
	[bu_qty_cur_change] [float] NOT NULL,
	[bu_time] [date] NOT NULL,
	[bu_estab] [nvarchar](5) NOT NULL,
	[bu_check] [nvarchar](5) NOT NULL,
	[bu_audit] [nvarchar](5) NOT NULL,
	[bu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_bridge_up] PRIMARY KEY CLUSTERED 
(
	[bu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_bridge_up] DROP COLUMN [f1],[f2],[f3],f4

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_down]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_orbital_down]
CREATE TABLE [dbo].[tb_orbital_down](
	[od_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[ol_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[f5] [int],
	[f6] [int],
	[od_qty_pre_design] [float] NOT NULL,
	[od_qty_pre_change] [float] NOT NULL,
	[od_qty_cur_design] [float] NOT NULL,
	[od_qty_cur_change] [float] NOT NULL,
	[od_time] [date] NOT NULL,
	[od_estab] [nvarchar](5) NOT NULL,
	[od_check] [nvarchar](5) NOT NULL,
	[od_audit] [nvarchar](5) NOT NULL,
	[od_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_down] PRIMARY KEY CLUSTERED 
(
	[od_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_orbital_down] DROP COLUMN [f1],[f2],[f3],[f4],[f5],[f6]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_qty]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_orbital_qty]
CREATE TABLE [dbo].[tb_orbital_qty](
	[oq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[ol_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[oq_qty_dwg_design] [float] NOT NULL,
	[oq_qty_dwg_change] [float] NOT NULL,
	[oq_qty_chk_design] [float] NOT NULL,
	[oq_qty_chk_change] [float] NOT NULL,
	[oq_qty_doe_design] [float] NOT NULL,
	[oq_qty_doe_change] [float] NOT NULL,
	[oq_time] [date] NOT NULL,
	[oq_estab] [nvarchar](5) NOT NULL,
	[oq_check] [nvarchar](5) NOT NULL,
	[oq_audit] [nvarchar](5) NOT NULL,
	[oq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_qty] PRIMARY KEY CLUSTERED 
(
	[oq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_orbital_qty] DROP COLUMN [f1],[f2],[f3]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_orbital_up]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_orbital_up]
CREATE TABLE [dbo].[tb_orbital_up](
	[ou_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[ol_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[ou_qty_pre_design] [float] NOT NULL,
	[ou_qty_pre_change] [float] NOT NULL,
	[ou_qty_cur_design] [float] NOT NULL,
	[ou_qty_cur_change] [float] NOT NULL,
	[ou_time] [date] NOT NULL,
	[ou_estab] [nvarchar](5) NOT NULL,
	[ou_check] [nvarchar](5) NOT NULL,
	[ou_audit] [nvarchar](5) NOT NULL,
	[ou_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_orbital_up] PRIMARY KEY CLUSTERED 
(
	[ou_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_orbital_up] DROP COLUMN [f1],[f2],[f3],f4

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_down]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_road_down]
CREATE TABLE [dbo].[tb_road_down](
	[rd_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[rl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[f5] [int],
	[f6] [int],
	[rd_qty_pre_design] [float] NOT NULL,
	[rd_qty_pre_change] [float] NOT NULL,
	[rd_qty_cur_design] [float] NOT NULL,
	[rd_qty_cur_change] [float] NOT NULL,
	[rd_time] [date] NOT NULL,
	[rd_estab] [nvarchar](5) NOT NULL,
	[rd_check] [nvarchar](5) NOT NULL,
	[rd_audit] [nvarchar](5) NOT NULL,
	[rd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_down] PRIMARY KEY CLUSTERED 
(
	[rd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_road_down] DROP COLUMN [f1],[f2],[f3],[f4],[f5],[f6]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_qty]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_road_qty]
CREATE TABLE [dbo].[tb_road_qty](
	[rq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[rl_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[rq_qty_dwg_design] [float] NOT NULL,
	[rq_qty_dwg_change] [float] NOT NULL,
	[rq_qty_chk_design] [float] NOT NULL,
	[rq_qty_chk_change] [float] NOT NULL,
	[rq_qty_doe_design] [float] NOT NULL,
	[rq_qty_doe_change] [float] NOT NULL,
	[rq_time] [date] NOT NULL,
	[rq_estab] [nvarchar](5) NOT NULL,
	[rq_check] [nvarchar](5) NOT NULL,
	[rq_audit] [nvarchar](5) NOT NULL,
	[rq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_qty] PRIMARY KEY CLUSTERED 
(
	[rq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_road_qty] DROP COLUMN [f1],[f2],[f3]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_road_up]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_road_up]
CREATE TABLE [dbo].[tb_road_up](
	[ru_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[rl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[ru_qty_pre_design] [float] NOT NULL,
	[ru_qty_pre_change] [float] NOT NULL,
	[ru_qty_cur_design] [float] NOT NULL,
	[ru_qty_cur_change] [float] NOT NULL,
	[ru_time] [date] NOT NULL,
	[ru_estab] [nvarchar](5) NOT NULL,
	[ru_check] [nvarchar](5) NOT NULL,
	[ru_audit] [nvarchar](5) NOT NULL,
	[ru_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_road_up] PRIMARY KEY CLUSTERED 
(
	[ru_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_road_up] DROP COLUMN [f1],[f2],[f3],f4

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_temp_down]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_temp_down]
CREATE TABLE [dbo].[tb_temp_down](
	[pd_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[pl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[f5] [int],
	[f6] [int],
	[pd_qty_pre_design] [float] NOT NULL,
	[pd_qty_pre_change] [float] NOT NULL,
	[pd_qty_cur_design] [float] NOT NULL,
	[pd_qty_cur_change] [float] NOT NULL,
	[pd_time] [date] NOT NULL,
	[pd_estab] [nvarchar](5) NOT NULL,
	[pd_check] [nvarchar](5) NOT NULL,
	[pd_audit] [nvarchar](5) NOT NULL,
	[pd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_down] PRIMARY KEY CLUSTERED 
(
	[pd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_temp_down] DROP COLUMN [f1],[f2],[f3],[f4],[f5],[f6]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_temp_qty]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_temp_qty]
CREATE TABLE [dbo].[tb_temp_qty](
	[pq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[pl_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[pq_qty_dwg_design] [float] NOT NULL,
	[pq_qty_dwg_change] [float] NOT NULL,
	[pq_qty_chk_design] [float] NOT NULL,
	[pq_qty_chk_change] [float] NOT NULL,
	[pq_qty_doe_design] [float] NOT NULL,
	[pq_qty_doe_change] [float] NOT NULL,
	[pq_time] [date] NOT NULL,
	[pq_estab] [nvarchar](5) NOT NULL,
	[pq_check] [nvarchar](5) NOT NULL,
	[pq_audit] [nvarchar](5) NOT NULL,
	[pq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_qty] PRIMARY KEY CLUSTERED 
(
	[pq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_temp_qty] DROP COLUMN [f1],[f2],[f3]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_temp_up]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_temp_up]
CREATE TABLE [dbo].[tb_temp_up](
	[pu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[pl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[pu_qty_pre_design] [float] NOT NULL,
	[pu_qty_pre_change] [float] NOT NULL,
	[pu_qty_cur_design] [float] NOT NULL,
	[pu_qty_cur_change] [float] NOT NULL,
	[pu_time] [date] NOT NULL,
	[pu_estab] [nvarchar](5) NOT NULL,
	[pu_check] [nvarchar](5) NOT NULL,
	[pu_audit] [nvarchar](5) NOT NULL,
	[pu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_temp_up] PRIMARY KEY CLUSTERED 
(
	[pu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_temp_up] DROP COLUMN [f1],[f2],[f3],f4

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_down]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_tunnel_down]
CREATE TABLE [dbo].[tb_tunnel_down](
	[td_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[tl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[f5] [int],
	[f6] [int],
	[td_qty_pre_design] [float] NOT NULL,
	[td_qty_pre_change] [float] NOT NULL,
	[td_qty_cur_design] [float] NOT NULL,
	[td_qty_cur_change] [float] NOT NULL,
	[td_time] [date] NOT NULL,
	[td_estab] [nvarchar](5) NOT NULL,
	[td_check] [nvarchar](5) NOT NULL,
	[td_audit] [nvarchar](5) NOT NULL,
	[td_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_down] PRIMARY KEY CLUSTERED 
(
	[td_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_tunnel_down] DROP COLUMN [f1],[f2],[f3],[f4],[f5],[f6]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_qty]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_tunnel_qty]
CREATE TABLE [dbo].[tb_tunnel_qty](
	[tq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[tl_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[tq_qty_dwg_design] [float] NOT NULL,
	[tq_qty_dwg_change] [float] NOT NULL,
	[tq_qty_chk_design] [float] NOT NULL,
	[tq_qty_chk_change] [float] NOT NULL,
	[tq_qty_doe_design] [float] NOT NULL,
	[tq_qty_doe_change] [float] NOT NULL,
	[tq_time] [date] NOT NULL,
	[tq_estab] [nvarchar](5) NOT NULL,
	[tq_check] [nvarchar](5) NOT NULL,
	[tq_audit] [nvarchar](5) NOT NULL,
	[tq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_qty] PRIMARY KEY CLUSTERED 
(
	[tq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_tunnel_qty] DROP COLUMN [f1],[f2],[f3]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_tunnel_up]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_tunnel_up]
CREATE TABLE [dbo].[tb_tunnel_up](
	[tu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[tl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[tu_qty_pre_design] [float] NOT NULL,
	[tu_qty_pre_change] [float] NOT NULL,
	[tu_qty_cur_design] [float] NOT NULL,
	[tu_qty_cur_change] [float] NOT NULL,
	[tu_time] [date] NOT NULL,
	[tu_estab] [nvarchar](5) NOT NULL,
	[tu_check] [nvarchar](5) NOT NULL,
	[tu_audit] [nvarchar](5) NOT NULL,
	[tu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_tunnel_up] PRIMARY KEY CLUSTERED 
(
	[tu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_tunnel_up] DROP COLUMN [f1],[f2],[f3],f4

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_down]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_yard_down]
CREATE TABLE [dbo].[tb_yard_down](
	[yd_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[yl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[f5] [int],
	[f6] [int],
	[yd_qty_pre_design] [float] NOT NULL,
	[yd_qty_pre_change] [float] NOT NULL,
	[yd_qty_cur_design] [float] NOT NULL,
	[yd_qty_cur_change] [float] NOT NULL,
	[yd_time] [date] NOT NULL,
	[yd_estab] [nvarchar](5) NOT NULL,
	[yd_check] [nvarchar](5) NOT NULL,
	[yd_audit] [nvarchar](5) NOT NULL,
	[yd_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_down] PRIMARY KEY CLUSTERED 
(
	[yd_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_yard_down] DROP COLUMN [f1],[f2],[f3],[f4],[f5],[f6]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_qty]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_yard_qty]
CREATE TABLE [dbo].[tb_yard_qty](
	[yq_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[yl_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[yq_qty_dwg_design] [float] NOT NULL,
	[yq_qty_dwg_change] [float] NOT NULL,
	[yq_qty_chk_design] [float] NOT NULL,
	[yq_qty_chk_change] [float] NOT NULL,
	[yq_qty_doe_design] [float] NOT NULL,
	[yq_qty_doe_change] [float] NOT NULL,
	[yq_time] [date] NOT NULL,
	[yq_estab] [nvarchar](5) NOT NULL,
	[yq_check] [nvarchar](5) NOT NULL,
	[yq_audit] [nvarchar](5) NOT NULL,
	[yq_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_qty] PRIMARY KEY CLUSTERED 
(
	[yq_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_yard_qty] DROP COLUMN [f1],[f2],[f3]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tb_yard_up]    Script Date: 2017/11/1 17:17:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS(SELECT name FROM sysobjects WHERE id = object_id('tb_road_down'))
	DROP TABLE [dbo].[tb_yard_up]
CREATE TABLE [dbo].[tb_yard_up](
	[yu_code] [varchar](10) NOT NULL,
	[pt_code] [varchar](5) NOT NULL,
	[yl_code] [varchar](5) NOT NULL,
	[lr_code] [varchar](5) NOT NULL,
	[u_code] [varchar](5) NOT NULL,
	[f1] [int],
	[f2] [int],
	[f3] [int],
	[f4] [int],
	[yu_qty_pre_design] [float] NOT NULL,
	[yu_qty_pre_change] [float] NOT NULL,
	[yu_qty_cur_design] [float] NOT NULL,
	[yu_qty_cur_change] [float] NOT NULL,
	[yu_time] [date] NOT NULL,
	[yu_estab] [nvarchar](5) NOT NULL,
	[yu_check] [nvarchar](5) NOT NULL,
	[yu_audit] [nvarchar](5) NOT NULL,
	[yu_info] [nvarchar](40) NULL,
 CONSTRAINT [PK_tb_yard_up] PRIMARY KEY CLUSTERED 
(
	[yu_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tb_yard_up] DROP COLUMN [f1],[f2],[f3],[f4]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_code]  DEFAULT ('BD00000000') FOR [bd_code]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bl_code]  DEFAULT ('BL001') FOR [bl_code]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_qty_pre_design]  DEFAULT ((0)) FOR [bd_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_qty_pre_change]  DEFAULT ((0)) FOR [bd_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_qty_cur_design]  DEFAULT ((0)) FOR [bd_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_qty_cur_change]  DEFAULT ((0)) FOR [bd_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_time]  DEFAULT (getdate()) FOR [bd_time]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_estab]  DEFAULT (N'编制') FOR [bd_estab]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_check]  DEFAULT (N'未复核') FOR [bd_check]
GO
ALTER TABLE [dbo].[tb_bridge_down] ADD  CONSTRAINT [DF_tb_bridge_down_bd_audit]  DEFAULT (N'未审核') FOR [bd_audit]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_code]  DEFAULT ('BQ00000000') FOR [bq_code]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bl_code]  DEFAULT ('BL001') FOR [bl_code]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_qty_dwg_design]  DEFAULT ((0)) FOR [bq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_qty_dwg_change]  DEFAULT ((0)) FOR [bq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_qty_chk_design]  DEFAULT ((0)) FOR [bq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_qty_chk_change]  DEFAULT ((0)) FOR [bq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_qty_doe_design]  DEFAULT ((0)) FOR [bq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_qty_doe_change]  DEFAULT ((0)) FOR [bq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_time]  DEFAULT (getdate()) FOR [bq_time]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_estab]  DEFAULT (N'编制') FOR [bq_estab]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_check]  DEFAULT (N'未复核') FOR [bq_check]
GO
ALTER TABLE [dbo].[tb_bridge_qty] ADD  CONSTRAINT [DF_tb_bridge_qty_bq_audit]  DEFAULT (N'未审核') FOR [bq_audit]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_code]  DEFAULT ('BU00000000') FOR [bu_code]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bl_code]  DEFAULT ('BL001') FOR [bl_code]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_qty_pre_design]  DEFAULT ((0)) FOR [bu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_qty_pre_change]  DEFAULT ((0)) FOR [bu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_qty_cur_design]  DEFAULT ((0)) FOR [bu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_qty_cur_change]  DEFAULT ((0)) FOR [bu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_time]  DEFAULT (getdate()) FOR [bu_time]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_estab]  DEFAULT (N'编制') FOR [bu_estab]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_check]  DEFAULT (N'未复核') FOR [bu_check]
GO
ALTER TABLE [dbo].[tb_bridge_up] ADD  CONSTRAINT [DF_tb_bridge_up_bu_audit]  DEFAULT (N'未审核') FOR [bu_audit]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_code]  DEFAULT ('OD00000000') FOR [od_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_ol_code]  DEFAULT ('OL001') FOR [ol_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_pre_design]  DEFAULT ((0)) FOR [od_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_pre_change]  DEFAULT ((0)) FOR [od_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_cur_design]  DEFAULT ((0)) FOR [od_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_qty_cur_change]  DEFAULT ((0)) FOR [od_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_time]  DEFAULT (getdate()) FOR [od_time]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_estab]  DEFAULT (N'编制') FOR [od_estab]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_check]  DEFAULT (N'未复核') FOR [od_check]
GO
ALTER TABLE [dbo].[tb_orbital_down] ADD  CONSTRAINT [DF_tb_orbital_down_od_audit]  DEFAULT (N'未审核') FOR [od_audit]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_code]  DEFAULT ('OQ00000000') FOR [oq_code]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_ol_code]  DEFAULT ('OL001') FOR [ol_code]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_dwg_design]  DEFAULT ((0)) FOR [oq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_dwg_change]  DEFAULT ((0)) FOR [oq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_chk_design]  DEFAULT ((0)) FOR [oq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_chk_change]  DEFAULT ((0)) FOR [oq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_doe_design]  DEFAULT ((0)) FOR [oq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_qty_doe_change]  DEFAULT ((0)) FOR [oq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_time]  DEFAULT (getdate()) FOR [oq_time]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_estab]  DEFAULT (N'编制') FOR [oq_estab]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_check]  DEFAULT (N'未复核') FOR [oq_check]
GO
ALTER TABLE [dbo].[tb_orbital_qty] ADD  CONSTRAINT [DF_tb_orbital_qty_oq_audit]  DEFAULT (N'未审核') FOR [oq_audit]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_code]  DEFAULT ('OU00000000') FOR [ou_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ol_code]  DEFAULT ('OL001') FOR [ol_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_pre_design]  DEFAULT ((0)) FOR [ou_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_pre_change]  DEFAULT ((0)) FOR [ou_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_cur_design]  DEFAULT ((0)) FOR [ou_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_qty_cur_change]  DEFAULT ((0)) FOR [ou_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_time]  DEFAULT (getdate()) FOR [ou_time]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_estab]  DEFAULT (N'编制') FOR [ou_estab]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_check]  DEFAULT (N'未复核') FOR [ou_check]
GO
ALTER TABLE [dbo].[tb_orbital_up] ADD  CONSTRAINT [DF_tb_orbital_up_ou_audit]  DEFAULT (N'未审核') FOR [ou_audit]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_code]  DEFAULT ('RD00000000') FOR [rd_code]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rl_code]  DEFAULT ('RL001') FOR [rl_code]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_qty_pre_design]  DEFAULT ((0)) FOR [rd_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_qty_pre_change]  DEFAULT ((0)) FOR [rd_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_qty_cur_design]  DEFAULT ((0)) FOR [rd_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_qty_cur_change]  DEFAULT ((0)) FOR [rd_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_time]  DEFAULT (getdate()) FOR [rd_time]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_estab]  DEFAULT (N'编制') FOR [rd_estab]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_check]  DEFAULT (N'未复核') FOR [rd_check]
GO
ALTER TABLE [dbo].[tb_road_down] ADD  CONSTRAINT [DF_tb_road_down_rd_audit]  DEFAULT (N'未审核') FOR [rd_audit]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_code]  DEFAULT ('RQ00000000') FOR [rq_code]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rl_code]  DEFAULT ('RL001') FOR [rl_code]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_qty_dwg_design]  DEFAULT ((0)) FOR [rq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_qty_dwg_change]  DEFAULT ((0)) FOR [rq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_qty_chk_design]  DEFAULT ((0)) FOR [rq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_qty_chk_change]  DEFAULT ((0)) FOR [rq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_qty_doe_design]  DEFAULT ((0)) FOR [rq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_qty_doe_change]  DEFAULT ((0)) FOR [rq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_time]  DEFAULT (getdate()) FOR [rq_time]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_estab]  DEFAULT (N'编制') FOR [rq_estab]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_check]  DEFAULT (N'未复核') FOR [rq_check]
GO
ALTER TABLE [dbo].[tb_road_qty] ADD  CONSTRAINT [DF_tb_road_qty_rq_audit]  DEFAULT (N'未审核') FOR [rq_audit]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_code]  DEFAULT ('RU00000000') FOR [ru_code]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_rl_code]  DEFAULT ('RL001') FOR [rl_code]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_qty_pre_design]  DEFAULT ((0)) FOR [ru_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_qty_pre_change]  DEFAULT ((0)) FOR [ru_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_qty_cur_design]  DEFAULT ((0)) FOR [ru_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_qty_cur_change]  DEFAULT ((0)) FOR [ru_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_time]  DEFAULT (getdate()) FOR [ru_time]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_estab]  DEFAULT (N'编制') FOR [ru_estab]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_check]  DEFAULT (N'未复核') FOR [ru_check]
GO
ALTER TABLE [dbo].[tb_road_up] ADD  CONSTRAINT [DF_tb_road_up_ru_audit]  DEFAULT (N'未审核') FOR [ru_audit]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_code]  DEFAULT ('PD00000000') FOR [pd_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pl_code]  DEFAULT ('PL001') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_pre_design]  DEFAULT ((0)) FOR [pd_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_pre_change]  DEFAULT ((0)) FOR [pd_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_cur_design]  DEFAULT ((0)) FOR [pd_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_qty_cur_change]  DEFAULT ((0)) FOR [pd_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_time]  DEFAULT (getdate()) FOR [pd_time]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_estab]  DEFAULT (N'编制') FOR [pd_estab]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_check]  DEFAULT (N'未复核') FOR [pd_check]
GO
ALTER TABLE [dbo].[tb_temp_down] ADD  CONSTRAINT [DF_tb_temp_down_pd_audit]  DEFAULT (N'未审核') FOR [pd_audit]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_code]  DEFAULT ('PQ00000000') FOR [pq_code]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pl_code]  DEFAULT ('PL001') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_dwg_design]  DEFAULT ((0)) FOR [pq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_dwg_change]  DEFAULT ((0)) FOR [pq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_chk_design]  DEFAULT ((0)) FOR [pq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_chk_change]  DEFAULT ((0)) FOR [pq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_doe_design]  DEFAULT ((0)) FOR [pq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_qty_doe_change]  DEFAULT ((0)) FOR [pq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_time]  DEFAULT (getdate()) FOR [pq_time]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_estab]  DEFAULT (N'编制') FOR [pq_estab]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_check]  DEFAULT (N'未复核') FOR [pq_check]
GO
ALTER TABLE [dbo].[tb_temp_qty] ADD  CONSTRAINT [DF_tb_temp_qty_pq_audit]  DEFAULT (N'未审核') FOR [pq_audit]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_code]  DEFAULT ('PU00000000') FOR [pu_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pl_code]  DEFAULT ('PL001') FOR [pl_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_pre_design]  DEFAULT ((0)) FOR [pu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_pre_change]  DEFAULT ((0)) FOR [pu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_cur_design]  DEFAULT ((0)) FOR [pu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_qty_cur_change]  DEFAULT ((0)) FOR [pu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_time]  DEFAULT (getdate()) FOR [pu_time]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_estab]  DEFAULT (N'编制') FOR [pu_estab]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_check]  DEFAULT (N'未复核') FOR [pu_check]
GO
ALTER TABLE [dbo].[tb_temp_up] ADD  CONSTRAINT [DF_tb_temp_up_pu_audit]  DEFAULT (N'未审核') FOR [pu_audit]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_code]  DEFAULT ('TD00000000') FOR [td_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_tl_code]  DEFAULT ('TL001') FOR [tl_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_pre_design]  DEFAULT ((0)) FOR [td_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_pre_change]  DEFAULT ((0)) FOR [td_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_cur_design]  DEFAULT ((0)) FOR [td_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_qty_cur_change]  DEFAULT ((0)) FOR [td_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_time]  DEFAULT (getdate()) FOR [td_time]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_estab]  DEFAULT (N'编制') FOR [td_estab]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_check]  DEFAULT (N'未复核') FOR [td_check]
GO
ALTER TABLE [dbo].[tb_tunnel_down] ADD  CONSTRAINT [DF_tb_tunnel_down_td_audit]  DEFAULT (N'未审核') FOR [td_audit]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_code]  DEFAULT ('TQ00000000') FOR [tq_code]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tl_code]  DEFAULT ('TL001') FOR [tl_code]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_dwg_design]  DEFAULT ((0)) FOR [tq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_dwg_change]  DEFAULT ((0)) FOR [tq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_chk_design]  DEFAULT ((0)) FOR [tq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_chk_change]  DEFAULT ((0)) FOR [tq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_doe_design]  DEFAULT ((0)) FOR [tq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_qty_doe_change]  DEFAULT ((0)) FOR [tq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_time]  DEFAULT (getdate()) FOR [tq_time]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_estab]  DEFAULT (N'编制') FOR [tq_estab]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_check]  DEFAULT (N'未复核') FOR [tq_check]
GO
ALTER TABLE [dbo].[tb_tunnel_qty] ADD  CONSTRAINT [DF_tb_tunnel_qty_tq_audit]  DEFAULT (N'未审核') FOR [tq_audit]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_code]  DEFAULT ('TU00000000') FOR [tu_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tl_code]  DEFAULT ('TL001') FOR [tl_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_pre_design]  DEFAULT ((0)) FOR [tu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_pre_change]  DEFAULT ((0)) FOR [tu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_cur_design]  DEFAULT ((0)) FOR [tu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_qty_cur_change]  DEFAULT ((0)) FOR [tu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_time]  DEFAULT (getdate()) FOR [tu_time]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_estab]  DEFAULT (N'编制') FOR [tu_estab]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_check]  DEFAULT (N'未复核') FOR [tu_check]
GO
ALTER TABLE [dbo].[tb_tunnel_up] ADD  CONSTRAINT [DF_tb_tunnel_up_tu_audit]  DEFAULT (N'未审核') FOR [tu_audit]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_code]  DEFAULT ('YD00000000') FOR [yd_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yl_code]  DEFAULT ('YL001') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_pre_design]  DEFAULT ((0)) FOR [yd_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_pre_change]  DEFAULT ((0)) FOR [yd_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_cur_design]  DEFAULT ((0)) FOR [yd_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_qty_cur_change]  DEFAULT ((0)) FOR [yd_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_time]  DEFAULT (getdate()) FOR [yd_time]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_estab]  DEFAULT (N'编制') FOR [yd_estab]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_check]  DEFAULT (N'未复核') FOR [yd_check]
GO
ALTER TABLE [dbo].[tb_yard_down] ADD  CONSTRAINT [DF_tb_yard_down_yd_audit]  DEFAULT (N'未审核') FOR [yd_audit]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_code]  DEFAULT ('YQ00000000') FOR [yq_code]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yl_code]  DEFAULT ('YL001') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_dwg_design]  DEFAULT ((0)) FOR [yq_qty_dwg_design]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_dwg_change]  DEFAULT ((0)) FOR [yq_qty_dwg_change]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_chk_design]  DEFAULT ((0)) FOR [yq_qty_chk_design]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_chk_change]  DEFAULT ((0)) FOR [yq_qty_chk_change]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_doe_design]  DEFAULT ((0)) FOR [yq_qty_doe_design]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_qty_doe_change]  DEFAULT ((0)) FOR [yq_qty_doe_change]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_date]  DEFAULT (getdate()) FOR [yq_time]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_estab]  DEFAULT (N'编制') FOR [yq_estab]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_check]  DEFAULT (N'未复核') FOR [yq_check]
GO
ALTER TABLE [dbo].[tb_yard_qty] ADD  CONSTRAINT [DF_tb_yard_qty_yq_audit]  DEFAULT (N'未审核') FOR [yq_audit]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_code]  DEFAULT ('YU00000000') FOR [yu_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_pt_code]  DEFAULT ('PT001') FOR [pt_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yl_code]  DEFAULT ('YL001') FOR [yl_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_lr_code]  DEFAULT ('LR001') FOR [lr_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_u_code]  DEFAULT ('U0001') FOR [u_code]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_pre_design]  DEFAULT ((0)) FOR [yu_qty_pre_design]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_pre_change]  DEFAULT ((0)) FOR [yu_qty_pre_change]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_cur_design]  DEFAULT ((0)) FOR [yu_qty_cur_design]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_qty_cur_change]  DEFAULT ((0)) FOR [yu_qty_cur_change]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_time]  DEFAULT (getdate()) FOR [yu_time]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_estab]  DEFAULT (N'编制') FOR [yu_estab]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_check]  DEFAULT (N'未复核') FOR [yu_check]
GO
ALTER TABLE [dbo].[tb_yard_up] ADD  CONSTRAINT [DF_tb_yard_up_yu_audit]  DEFAULT (N'未审核') FOR [yu_audit]
GO
ALTER TABLE [dbo].[tb_bridge_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_down_tb_bridge_lst] FOREIGN KEY([bl_code])
REFERENCES [dbo].[tb_bridge_lst] ([bl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_down] CHECK CONSTRAINT [FK_tb_bridge_down_tb_bridge_lst]
GO
ALTER TABLE [dbo].[tb_bridge_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_down] CHECK CONSTRAINT [FK_tb_bridge_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_bridge_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_down] CHECK CONSTRAINT [FK_tb_bridge_down_tb_points]
GO
ALTER TABLE [dbo].[tb_bridge_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_qty_tb_bridge_lst] FOREIGN KEY([bl_code])
REFERENCES [dbo].[tb_bridge_lst] ([bl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_qty] CHECK CONSTRAINT [FK_tb_bridge_qty_tb_bridge_lst]
GO
ALTER TABLE [dbo].[tb_bridge_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_qty] CHECK CONSTRAINT [FK_tb_bridge_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_bridge_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_up_tb_bridge_lst] FOREIGN KEY([bl_code])
REFERENCES [dbo].[tb_bridge_lst] ([bl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_up] CHECK CONSTRAINT [FK_tb_bridge_up_tb_bridge_lst]
GO
ALTER TABLE [dbo].[tb_bridge_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_up] CHECK CONSTRAINT [FK_tb_bridge_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_bridge_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_bridge_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_bridge_up] CHECK CONSTRAINT [FK_tb_bridge_up_tb_points]
GO
ALTER TABLE [dbo].[tb_orbital_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_down] CHECK CONSTRAINT [FK_tb_orbital_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_orbital_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_down_tb_orbital_lst] FOREIGN KEY([ol_code])
REFERENCES [dbo].[tb_orbital_lst] ([ol_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_down] CHECK CONSTRAINT [FK_tb_orbital_down_tb_orbital_lst]
GO
ALTER TABLE [dbo].[tb_orbital_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_down] CHECK CONSTRAINT [FK_tb_orbital_down_tb_points]
GO
ALTER TABLE [dbo].[tb_orbital_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_qty_tb_orbital_lst] FOREIGN KEY([ol_code])
REFERENCES [dbo].[tb_orbital_lst] ([ol_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_qty] CHECK CONSTRAINT [FK_tb_orbital_qty_tb_orbital_lst]
GO
ALTER TABLE [dbo].[tb_orbital_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_qty] CHECK CONSTRAINT [FK_tb_orbital_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_orbital_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_up] CHECK CONSTRAINT [FK_tb_orbital_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_orbital_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_up_tb_orbital_lst] FOREIGN KEY([ol_code])
REFERENCES [dbo].[tb_orbital_lst] ([ol_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_up] CHECK CONSTRAINT [FK_tb_orbital_up_tb_orbital_lst]
GO
ALTER TABLE [dbo].[tb_orbital_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_orbital_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_orbital_up] CHECK CONSTRAINT [FK_tb_orbital_up_tb_points]
GO
ALTER TABLE [dbo].[tb_road_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_down] CHECK CONSTRAINT [FK_tb_road_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_road_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_down] CHECK CONSTRAINT [FK_tb_road_down_tb_points]
GO
ALTER TABLE [dbo].[tb_road_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_down_tb_road_lst] FOREIGN KEY([rl_code])
REFERENCES [dbo].[tb_road_lst] ([rl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_down] CHECK CONSTRAINT [FK_tb_road_down_tb_road_lst]
GO
ALTER TABLE [dbo].[tb_road_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_qty] CHECK CONSTRAINT [FK_tb_road_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_road_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_qty_tb_road_lst] FOREIGN KEY([rl_code])
REFERENCES [dbo].[tb_road_lst] ([rl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_qty] CHECK CONSTRAINT [FK_tb_road_qty_tb_road_lst]
GO
ALTER TABLE [dbo].[tb_road_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_up] CHECK CONSTRAINT [FK_tb_road_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_road_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_up] CHECK CONSTRAINT [FK_tb_road_up_tb_points]
GO
ALTER TABLE [dbo].[tb_road_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_road_up_tb_road_lst] FOREIGN KEY([rl_code])
REFERENCES [dbo].[tb_road_lst] ([rl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_road_up] CHECK CONSTRAINT [FK_tb_road_up_tb_road_lst]
GO
ALTER TABLE [dbo].[tb_temp_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_down] CHECK CONSTRAINT [FK_tb_temp_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_temp_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_down] CHECK CONSTRAINT [FK_tb_temp_down_tb_points]
GO
ALTER TABLE [dbo].[tb_temp_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_down_tb_temp_lst] FOREIGN KEY([pl_code])
REFERENCES [dbo].[tb_temp_lst] ([pl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_down] CHECK CONSTRAINT [FK_tb_temp_down_tb_temp_lst]
GO
ALTER TABLE [dbo].[tb_temp_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_qty] CHECK CONSTRAINT [FK_tb_temp_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_temp_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_qty_tb_temp_lst] FOREIGN KEY([pl_code])
REFERENCES [dbo].[tb_temp_lst] ([pl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_qty] CHECK CONSTRAINT [FK_tb_temp_qty_tb_temp_lst]
GO
ALTER TABLE [dbo].[tb_temp_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_up] CHECK CONSTRAINT [FK_tb_temp_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_temp_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_up] CHECK CONSTRAINT [FK_tb_temp_up_tb_points]
GO
ALTER TABLE [dbo].[tb_temp_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_temp_up_tb_temp_lst] FOREIGN KEY([pl_code])
REFERENCES [dbo].[tb_temp_lst] ([pl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_temp_up] CHECK CONSTRAINT [FK_tb_temp_up_tb_temp_lst]
GO
ALTER TABLE [dbo].[tb_tunnel_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_down] CHECK CONSTRAINT [FK_tb_tunnel_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_tunnel_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_down] CHECK CONSTRAINT [FK_tb_tunnel_down_tb_points]
GO
ALTER TABLE [dbo].[tb_tunnel_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_down_tb_tunnel_lst] FOREIGN KEY([tl_code])
REFERENCES [dbo].[tb_tunnel_lst] ([tl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_down] CHECK CONSTRAINT [FK_tb_tunnel_down_tb_tunnel_lst]
GO
ALTER TABLE [dbo].[tb_tunnel_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_qty] CHECK CONSTRAINT [FK_tb_tunnel_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_tunnel_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_qty_tb_tunnel_lst] FOREIGN KEY([tl_code])
REFERENCES [dbo].[tb_tunnel_lst] ([tl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_qty] CHECK CONSTRAINT [FK_tb_tunnel_qty_tb_tunnel_lst]
GO
ALTER TABLE [dbo].[tb_tunnel_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_up] CHECK CONSTRAINT [FK_tb_tunnel_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_tunnel_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_up] CHECK CONSTRAINT [FK_tb_tunnel_up_tb_points]
GO
ALTER TABLE [dbo].[tb_tunnel_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_tunnel_up_tb_tunnel_lst] FOREIGN KEY([tl_code])
REFERENCES [dbo].[tb_tunnel_lst] ([tl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_tunnel_up] CHECK CONSTRAINT [FK_tb_tunnel_up_tb_tunnel_lst]
GO
ALTER TABLE [dbo].[tb_yard_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_down_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_down] CHECK CONSTRAINT [FK_tb_yard_down_tb_ledger]
GO
ALTER TABLE [dbo].[tb_yard_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_down_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_down] CHECK CONSTRAINT [FK_tb_yard_down_tb_points]
GO
ALTER TABLE [dbo].[tb_yard_down]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_down_tb_yard_lst] FOREIGN KEY([yl_code])
REFERENCES [dbo].[tb_yard_lst] ([yl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_down] CHECK CONSTRAINT [FK_tb_yard_down_tb_yard_lst]
GO
ALTER TABLE [dbo].[tb_yard_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_qty_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_qty] CHECK CONSTRAINT [FK_tb_yard_qty_tb_points]
GO
ALTER TABLE [dbo].[tb_yard_qty]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_qty_tb_yard_lst] FOREIGN KEY([yl_code])
REFERENCES [dbo].[tb_yard_lst] ([yl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_qty] CHECK CONSTRAINT [FK_tb_yard_qty_tb_yard_lst]
GO
ALTER TABLE [dbo].[tb_yard_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_up_tb_ledger] FOREIGN KEY([lr_code])
REFERENCES [dbo].[tb_ledger] ([lr_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_up] CHECK CONSTRAINT [FK_tb_yard_up_tb_ledger]
GO
ALTER TABLE [dbo].[tb_yard_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_up_tb_points] FOREIGN KEY([pt_code])
REFERENCES [dbo].[tb_points] ([pt_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_up] CHECK CONSTRAINT [FK_tb_yard_up_tb_points]
GO
ALTER TABLE [dbo].[tb_yard_up]  WITH CHECK ADD  CONSTRAINT [FK_tb_yard_up_tb_yard_lst] FOREIGN KEY([yl_code])
REFERENCES [dbo].[tb_yard_lst] ([yl_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tb_yard_up] CHECK CONSTRAINT [FK_tb_yard_up_tb_yard_lst]
GO
