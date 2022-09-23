CREATE TABLE [dbo].[TMTMeterTransferHistory]
(
[Mov_number] [int] NULL,
[tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_miles] [float] NULL,
[ReverseEntry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TMTMeterT__Rever__7B1204DF] DEFAULT ('N'),
[lgh_number] [int] NULL CONSTRAINT [DF__TMTMeterT__lgh_n__7C062918] DEFAULT (0),
[InsertDate] [datetime] NULL CONSTRAINT [DF__TMTMeterT__Inser__7CFA4D51] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Mov_number_Ind] ON [dbo].[TMTMeterTransferHistory] ([Mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMTMeterTransferHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[TMTMeterTransferHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMTMeterTransferHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[TMTMeterTransferHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMTMeterTransferHistory] TO [public]
GO
