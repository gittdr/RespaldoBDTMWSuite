CREATE TABLE [dbo].[cityziparchive]
(
[zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cty_code] [int] NOT NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cz_zone] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cz_area] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cz_latitude] [decimal] (8, 4) NULL,
[cz_longitude] [decimal] (8, 4) NULL,
[cz_county] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cz_countyfips] [int] NULL,
[cz_zipcodetype] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cityziparchive] ADD CONSTRAINT [pk_cityziparchive] PRIMARY KEY CLUSTERED ([zip], [cty_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cityziparchive] TO [public]
GO
GRANT INSERT ON  [dbo].[cityziparchive] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cityziparchive] TO [public]
GO
GRANT SELECT ON  [dbo].[cityziparchive] TO [public]
GO
GRANT UPDATE ON  [dbo].[cityziparchive] TO [public]
GO
