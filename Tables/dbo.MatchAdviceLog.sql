CREATE TABLE [dbo].[MatchAdviceLog]
(
[mal_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ma_transaction_id] [bigint] NOT NULL,
[ma_tour_number] [int] NOT NULL,
[ma_tour_sequence] [int] NOT NULL,
[ma_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ma_power_id] [int] NULL,
[mal_status] [int] NOT NULL,
[mal_action_details] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mal_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mal_updatedate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MatchAdviceLog] ADD CONSTRAINT [PK_MatchAdviceLog] PRIMARY KEY CLUSTERED ([mal_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_MatchAdviceLog_TransactionTourSequence] ON [dbo].[MatchAdviceLog] ([ma_transaction_id], [ma_tour_number], [ma_tour_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MatchAdviceLog] TO [public]
GO
GRANT INSERT ON  [dbo].[MatchAdviceLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MatchAdviceLog] TO [public]
GO
GRANT SELECT ON  [dbo].[MatchAdviceLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[MatchAdviceLog] TO [public]
GO
