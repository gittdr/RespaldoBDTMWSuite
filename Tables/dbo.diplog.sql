CREATE TABLE [dbo].[diplog]
(
[dl_identity] [int] NOT NULL IDENTITY(1, 1),
[tank_nbr] [int] NOT NULL,
[dl_date] [datetime] NULL,
[dl_dipreading] [int] NULL,
[dl_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dl_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dl_updatedon] [datetime] NULL,
[dl_delivervolume] [int] NULL,
[dl_salesvolume] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[diplog] ADD CONSTRAINT [pk_diplog] PRIMARY KEY CLUSTERED ([dl_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tankdipdate] ON [dbo].[diplog] ([tank_nbr], [dl_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[diplog] TO [public]
GO
GRANT INSERT ON  [dbo].[diplog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[diplog] TO [public]
GO
GRANT SELECT ON  [dbo].[diplog] TO [public]
GO
GRANT UPDATE ON  [dbo].[diplog] TO [public]
GO
