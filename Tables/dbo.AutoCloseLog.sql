CREATE TABLE [dbo].[AutoCloseLog]
(
[acl_batch] [int] NOT NULL,
[acl_sequence] [int] NOT NULL,
[acl_ordnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_asgnid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_payperiod] [datetime] NOT NULL,
[acl_errorflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_message] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acl_rundate] [datetime] NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyd_amount] [money] NOT NULL
) ON [PRIMARY]
GO
