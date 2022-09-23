CREATE TABLE [dbo].[ltlosd_detail]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[osd_id] [int] NULL,
[fgt_number] [int] NULL,
[osd_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_quantity] [decimal] (10, 2) NULL,
[osd_quantity_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_image] [image] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltlosd_detail] ADD CONSTRAINT [PK__ltlosd_d__3213E83F26202BF1] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ltlosddtl_osd] ON [dbo].[ltlosd_detail] ([osd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltlosd_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[ltlosd_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltlosd_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[ltlosd_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltlosd_detail] TO [public]
GO
