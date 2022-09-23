CREATE TABLE [dbo].[dx_Lookup]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_lookuptable] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_lookuprawdatavalue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_lookuptranslatedvalue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Lookup] ADD CONSTRAINT [pk_dx_Lookup] PRIMARY KEY CLUSTERED ([dx_importid], [dx_lookuptable], [dx_lookuprawdatavalue]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Lookup] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Lookup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Lookup] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Lookup] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Lookup] TO [public]
GO
