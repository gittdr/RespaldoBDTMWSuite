CREATE TABLE [dbo].[AssignmentPermissons]
(
[ap_id] [int] NOT NULL IDENTITY(1, 1),
[ap_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_assettype] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_assetid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_expiration] [datetime] NOT NULL,
[ap_singleuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ap_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AssignmentPermissons] ADD CONSTRAINT [pk_AssignmentPermissons_ap_id] PRIMARY KEY CLUSTERED ([ap_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_AssignmentPermissons_ap_assettype_ap_assetid] ON [dbo].[AssignmentPermissons] ([ap_assettype], [ap_assetid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[AssignmentPermissons] TO [public]
GO
GRANT INSERT ON  [dbo].[AssignmentPermissons] TO [public]
GO
GRANT REFERENCES ON  [dbo].[AssignmentPermissons] TO [public]
GO
GRANT SELECT ON  [dbo].[AssignmentPermissons] TO [public]
GO
GRANT UPDATE ON  [dbo].[AssignmentPermissons] TO [public]
GO
