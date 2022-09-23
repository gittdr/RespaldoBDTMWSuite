CREATE TABLE [dbo].[RapidLogCodeXref]
(
[rlcx_id] [int] NOT NULL IDENTITY(1, 1),
[rlcx_tmwviolationcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rlcx_rapidviolationcode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RapidLogCodeXref] ADD CONSTRAINT [pk_RapidLogCodeXref] PRIMARY KEY CLUSTERED ([rlcx_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RapidLogCodeXref] TO [public]
GO
GRANT INSERT ON  [dbo].[RapidLogCodeXref] TO [public]
GO
GRANT SELECT ON  [dbo].[RapidLogCodeXref] TO [public]
GO
GRANT UPDATE ON  [dbo].[RapidLogCodeXref] TO [public]
GO
