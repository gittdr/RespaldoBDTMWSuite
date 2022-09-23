CREATE TABLE [dbo].[ltl_images]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Record_Type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Record_Label] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Record_Value] [int] NULL,
[LTL_Image] [image] NULL,
[Folder] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltl_images] ADD CONSTRAINT [PK_ltl_images] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltl_images] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_images] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltl_images] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_images] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_images] TO [public]
GO
