CREATE TABLE [dbo].[CarrierWatchMisc]
(
[cwm] [int] NOT NULL IDENTITY(1, 1),
[csa_id] [int] NOT NULL,
[docket] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[emailaddress] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scac] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierWatchMisc] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierWatchMisc] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierWatchMisc] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierWatchMisc] TO [public]
GO
