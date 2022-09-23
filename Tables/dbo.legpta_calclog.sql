CREATE TABLE [dbo].[legpta_calclog]
(
[lpc_id] [bigint] NOT NULL IDENTITY(1, 1),
[lpc_datelogged] [datetime] NOT NULL CONSTRAINT [DF__legpta_ca__lpc_d__52137C0D] DEFAULT (getdate()),
[curLeg] [int] NULL,
[ptaType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[utilCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[newPTA] [datetime] NULL,
[calculatedMax] [datetime] NULL,
[curTrc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[today] [datetime] NULL,
[approved] [tinyint] NULL,
[approvedBy] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[approvedOn] [datetime] NULL,
[Dodataupdate] [bit] NULL,
[outStatus] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[existingLegPTA] [int] NULL,
[messagedesc] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[instructions] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_hard_max] [datetime] NULL,
[requested_date] [datetime] NULL,
[requested_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legpta_calclog] TO [public]
GO
GRANT INSERT ON  [dbo].[legpta_calclog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legpta_calclog] TO [public]
GO
GRANT UPDATE ON  [dbo].[legpta_calclog] TO [public]
GO
