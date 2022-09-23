CREATE TABLE [dbo].[im_iso_codes]
(
[iso_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [decimal] (18, 0) NULL,
[width] [decimal] (18, 0) NULL,
[height] [decimal] (18, 0) NULL,
[trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_type4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[max_pallets] [int] NULL,
[max_weight] [decimal] (18, 0) NULL,
[max_volume] [decimal] (18, 0) NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[im_iso_codes] ADD CONSTRAINT [PK__im_iso_codes__2DB75320] PRIMARY KEY CLUSTERED ([iso_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[im_iso_codes] TO [public]
GO
GRANT INSERT ON  [dbo].[im_iso_codes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[im_iso_codes] TO [public]
GO
GRANT SELECT ON  [dbo].[im_iso_codes] TO [public]
GO
GRANT UPDATE ON  [dbo].[im_iso_codes] TO [public]
GO
