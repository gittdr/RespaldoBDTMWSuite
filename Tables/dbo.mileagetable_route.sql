CREATE TABLE [dbo].[mileagetable_route]
(
[mtd_id] [bigint] NOT NULL IDENTITY(1, 1),
[mt_identity] [int] NOT NULL,
[mtd_seq] [bigint] NOT NULL,
[mtd_latitude] [decimal] (18, 6) NOT NULL,
[mtd_longitude] [decimal] (18, 6) NOT NULL,
[mtd_distance] [decimal] (18, 6) NOT NULL,
[mtd_duration] [decimal] (18, 6) NOT NULL,
[mtd_message] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mtd_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mtd_updatedon] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mileagetable_route] ADD CONSTRAINT [PK_mileagetable_route] PRIMARY KEY CLUSTERED ([mtd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_mileagetable_route_mt_identity] ON [dbo].[mileagetable_route] ([mt_identity]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mileagetable_route] ADD CONSTRAINT [FK_mileagetable_route_mileagetable] FOREIGN KEY ([mt_identity]) REFERENCES [dbo].[mileagetable] ([mt_identity]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[mileagetable_route] TO [public]
GO
GRANT INSERT ON  [dbo].[mileagetable_route] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mileagetable_route] TO [public]
GO
GRANT SELECT ON  [dbo].[mileagetable_route] TO [public]
GO
GRANT UPDATE ON  [dbo].[mileagetable_route] TO [public]
GO
