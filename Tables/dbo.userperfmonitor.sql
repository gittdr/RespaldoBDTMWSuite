CREATE TABLE [dbo].[userperfmonitor]
(
[upm_type] [int] NULL,
[upm_connect_tm] [datetime] NOT NULL,
[upm_duration] [int] NOT NULL,
[upd_complete_tm] [datetime] NOT NULL CONSTRAINT [DF__userperfm__upd_c__2839B111] DEFAULT (getdate()),
[upd_extra1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upd_extra2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upm_app] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__userperfm__upm_a__292DD54A] DEFAULT (app_name()),
[upm_host] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__userperfm__upm_h__2A21F983] DEFAULT (host_name()),
[upm_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__userperfm__upm_u__2B161DBC] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userperfmonitor] TO [public]
GO
GRANT INSERT ON  [dbo].[userperfmonitor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userperfmonitor] TO [public]
GO
GRANT SELECT ON  [dbo].[userperfmonitor] TO [public]
GO
GRANT UPDATE ON  [dbo].[userperfmonitor] TO [public]
GO
