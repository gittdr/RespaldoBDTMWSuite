CREATE TABLE [dbo].[carrierfilterlist]
(
[cfl_id] [int] NOT NULL IDENTITY(1, 1),
[cfl_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfl_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfl_labeldef] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfl_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caf_viewid] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfl_operator] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cfl_qty] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierfilterlist] ADD CONSTRAINT [PK_carrierfilterlist] PRIMARY KEY CLUSTERED ([cfl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierfilterlist] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierfilterlist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierfilterlist] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierfilterlist] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierfilterlist] TO [public]
GO
