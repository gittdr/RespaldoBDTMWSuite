CREATE TABLE [dbo].[settlementdriverdaycustom]
(
[sdd_id] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[sdd_day] [datetime] NULL,
[sdd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdd_created_date] [datetime] NOT NULL,
[sdd_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sdd_modified_date] [datetime] NOT NULL,
[sdd_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[settlementdriverdaycustom] ADD CONSTRAINT [PK_settlementdriverdaycustom] PRIMARY KEY NONCLUSTERED ([sdd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[settlementdriverdaycustom] TO [public]
GO
GRANT INSERT ON  [dbo].[settlementdriverdaycustom] TO [public]
GO
GRANT REFERENCES ON  [dbo].[settlementdriverdaycustom] TO [public]
GO
GRANT SELECT ON  [dbo].[settlementdriverdaycustom] TO [public]
GO
GRANT UPDATE ON  [dbo].[settlementdriverdaycustom] TO [public]
GO
