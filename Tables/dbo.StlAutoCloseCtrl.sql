CREATE TABLE [dbo].[StlAutoCloseCtrl]
(
[sac_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sac_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sac_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sac_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sac_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sac_dateflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sac_autoflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psh_id] [int] NOT NULL
) ON [PRIMARY]
GO
