CREATE TABLE [dbo].[ediaccessorial]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_accessorial_code] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_accessorial_code2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_cmp_acc] ON [dbo].[ediaccessorial] ([cmp_id], [cht_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ediaccessorial] TO [public]
GO
GRANT INSERT ON  [dbo].[ediaccessorial] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ediaccessorial] TO [public]
GO
GRANT SELECT ON  [dbo].[ediaccessorial] TO [public]
GO
GRANT UPDATE ON  [dbo].[ediaccessorial] TO [public]
GO
