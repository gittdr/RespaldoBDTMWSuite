CREATE TABLE [dbo].[splittrip_reason]
(
[spl_id] [int] NOT NULL IDENTITY(1, 1),
[spl_ord_hdrnumber] [int] NOT NULL,
[spl_legnumber] [int] NOT NULL,
[spl_reason] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[spl_notes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_createddate] [datetime] NULL,
[spl_createdby] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spl_lastupdatedt] [datetime] NULL,
[spl_lastupdateby] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[splittrip_reason] ADD CONSTRAINT [pk_spl_id] PRIMARY KEY CLUSTERED ([spl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[splittrip_reason] TO [public]
GO
GRANT INSERT ON  [dbo].[splittrip_reason] TO [public]
GO
GRANT REFERENCES ON  [dbo].[splittrip_reason] TO [public]
GO
GRANT SELECT ON  [dbo].[splittrip_reason] TO [public]
GO
GRANT UPDATE ON  [dbo].[splittrip_reason] TO [public]
GO
