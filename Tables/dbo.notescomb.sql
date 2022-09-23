CREATE TABLE [dbo].[notescomb]
(
[shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[supplier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[security_note] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updated] [datetime] NOT NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_notescomb] ON [dbo].[notescomb] ([shipper], [consignee], [supplier]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notescomb] TO [public]
GO
GRANT INSERT ON  [dbo].[notescomb] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notescomb] TO [public]
GO
GRANT SELECT ON  [dbo].[notescomb] TO [public]
GO
GRANT UPDATE ON  [dbo].[notescomb] TO [public]
GO
