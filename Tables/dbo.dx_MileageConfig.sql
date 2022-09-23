CREATE TABLE [dbo].[dx_MileageConfig]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_mileagexface] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_mileagetype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_mileageoptions] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_mileagelookupby] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_useCOMobject] [bit] NULL,
[dx_lookinTMWfirst] [bit] NULL,
[dx_savemileage] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_MileageConfig] ADD CONSTRAINT [pk_dx_MileageConfig] PRIMARY KEY CLUSTERED ([dx_importid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_MileageConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_MileageConfig] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_MileageConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_MileageConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_MileageConfig] TO [public]
GO
