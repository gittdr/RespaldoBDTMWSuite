CREATE TABLE [dbo].[RailTemplateRouting]
(
[rtr_id] [int] NOT NULL IDENTITY(1, 1),
[rth_id] [int] NOT NULL,
[rtr_sequence] [int] NOT NULL,
[rtr_location] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtr_interchange_to] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtr_rule11] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rtr_lastupdate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RailTemplateRouting] ADD CONSTRAINT [pk_railtemplaterouting_rtr_id] PRIMARY KEY CLUSTERED ([rtr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_railtemplaterouting_rth_id] ON [dbo].[RailTemplateRouting] ([rth_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RailTemplateRouting] TO [public]
GO
GRANT INSERT ON  [dbo].[RailTemplateRouting] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RailTemplateRouting] TO [public]
GO
GRANT SELECT ON  [dbo].[RailTemplateRouting] TO [public]
GO
GRANT UPDATE ON  [dbo].[RailTemplateRouting] TO [public]
GO
