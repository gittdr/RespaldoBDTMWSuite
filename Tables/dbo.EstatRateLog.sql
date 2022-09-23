CREATE TABLE [dbo].[EstatRateLog]
(
[erl_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NOT NULL,
[erl_comment] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[erl_total_cost] [money] NULL,
[erl_time] [datetime] NULL,
[erl_batch_id] [int] NULL,
[erl_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[erl_createdt] [datetime] NULL,
[erl_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[erl_lastupdatedt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EstatRateLog] ADD CONSTRAINT [pk_erl_id] PRIMARY KEY CLUSTERED ([erl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[EstatRateLog] TO [public]
GO
GRANT INSERT ON  [dbo].[EstatRateLog] TO [public]
GO
GRANT SELECT ON  [dbo].[EstatRateLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[EstatRateLog] TO [public]
GO
