CREATE TABLE [dbo].[delayincident]
(
[di_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[di_prev_stp_number] [int] NULL,
[di_next_stp_number] [int] NULL,
[di_prev_stp_sequence] [int] NULL,
[di_next_stp_sequence] [int] NULL,
[di_delaytype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[di_delayreason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[di_delay_explanation] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[di_delay_min] [int] NULL,
[di_delay_starttime] [datetime] NULL,
[di_delay_endtime] [datetime] NULL,
[pyd_number] [int] NULL,
[ivd_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[delayincident] ADD CONSTRAINT [pk_delayincident] PRIMARY KEY CLUSTERED ([di_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_delayincident_ord] ON [dbo].[delayincident] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[delayincident] TO [public]
GO
GRANT INSERT ON  [dbo].[delayincident] TO [public]
GO
GRANT SELECT ON  [dbo].[delayincident] TO [public]
GO
GRANT UPDATE ON  [dbo].[delayincident] TO [public]
GO
