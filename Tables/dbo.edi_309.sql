CREATE TABLE [dbo].[edi_309]
(
[record_id] [int] NOT NULL IDENTITY(1, 1),
[data_col] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batch_number] [int] NULL,
[mov_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[edi_309] ADD CONSTRAINT [PK__edi_309__4BD68E25] PRIMARY KEY CLUSTERED ([record_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_309] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_309] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_309] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_309] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_309] TO [public]
GO
