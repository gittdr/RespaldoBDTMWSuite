CREATE TABLE [dbo].[cityzip]
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
[cz_zipcodetype] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cz_ALK_FileValidatedYR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cityzip] ADD CONSTRAINT [pk_cityzip] PRIMARY KEY CLUSTERED ([zip], [cty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ux_ctycode] ON [dbo].[cityzip] ([cty_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ux_zipcity] ON [dbo].[cityzip] ([cty_nmstct]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cityzip] TO [public]
GO
GRANT INSERT ON  [dbo].[cityzip] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cityzip] TO [public]
GO
GRANT SELECT ON  [dbo].[cityzip] TO [public]
GO
GRANT UPDATE ON  [dbo].[cityzip] TO [public]
GO
