CREATE TABLE [dbo].[ltlfilter_detail]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[header_id] [int] NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[detail_type] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dock_zone] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[terminal_eta] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltlfilter_detail] ADD CONSTRAINT [PK__ltlfilte__3213E83F55BE375C] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltlfilter_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[ltlfilter_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltlfilter_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[ltlfilter_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltlfilter_detail] TO [public]
GO
