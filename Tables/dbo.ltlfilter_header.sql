CREATE TABLE [dbo].[ltlfilter_header]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[applies_to] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[filter_description] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltlfilter_header] ADD CONSTRAINT [PK__ltlfilte__3213E83F823890F1] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltlfilter_header] TO [public]
GO
GRANT INSERT ON  [dbo].[ltlfilter_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltlfilter_header] TO [public]
GO
GRANT SELECT ON  [dbo].[ltlfilter_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltlfilter_header] TO [public]
GO
