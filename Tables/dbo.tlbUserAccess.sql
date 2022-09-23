CREATE TABLE [dbo].[tlbUserAccess]
(
[usr_userid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_password] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_mail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_access] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usr_create] [datetime] NULL,
[usr_update] [datetime] NULL
) ON [PRIMARY]
GO
