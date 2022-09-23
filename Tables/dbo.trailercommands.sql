CREATE TABLE [dbo].[trailercommands]
(
[trlc_id] [int] NOT NULL IDENTITY(1, 1),
[trlc_mcommid] [int] NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acm_system] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_createdate] [datetime] NOT NULL CONSTRAINT [acm_dfcdate] DEFAULT (getdate()),
[trlc_sentdate] [datetime] NULL,
[trlc_accepteddate] [datetime] NULL,
[trlc_actiondate] [datetime] NULL,
[trlc_command] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trlc_parm1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_parm2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_parm3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_parm4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_parm5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_parm6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_success] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_failtext] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_sentby] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlc_status] AS (case  when isnull([trlc_actiondate],'2049-12-31 23:59:59.000')='2049-12-31 23:59:59.000' then case  when isnull([trlc_sentdate],'2049-12-31 23:59:59.000')='2049-12-31 23:59:59.000' then 'UNSENT' else 'IN PROGRESS' end else case  when isnull([trlc_success],'')='' OR [trlc_success]='Y' then 'COMPLETE' else 'FAILED' end end)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailercommands] ADD CONSTRAINT [trlc_cksystem] CHECK (([dbo].[CheckLabel]([acm_system],'MCommSystem',(0))=(1)))
GO
ALTER TABLE [dbo].[trailercommands] ADD CONSTRAINT [trlc_pk] PRIMARY KEY CLUSTERED ([trlc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trailercommands_lastoftype] ON [dbo].[trailercommands] ([acm_system], [trl_id], [trlc_command], [trlc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trailercommands_mcommsystem] ON [dbo].[trailercommands] ([acm_system], [trlc_actiondate], [trl_id], [trlc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_trailercommands_mcommid] ON [dbo].[trailercommands] ([acm_system], [trlc_mcommid], [trlc_id] DESC) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailercommands] TO [public]
GO
GRANT INSERT ON  [dbo].[trailercommands] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailercommands] TO [public]
GO
GRANT SELECT ON  [dbo].[trailercommands] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailercommands] TO [public]
GO
