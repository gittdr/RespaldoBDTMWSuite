CREATE TABLE [dbo].[TMTMeterTransferHistoryTrl]
(
[Mov_number] [int] NULL,
[Trailer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_miles] [float] NULL,
[ReverseEntry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TMTMeterT__Rever__56E8A954] DEFAULT ('N'),
[lgh_number] [int] NULL CONSTRAINT [DF__TMTMeterT__lgh_n__57DCCD8D] DEFAULT ((0)),
[InsertDate] [datetime] NULL CONSTRAINT [DF__TMTMeterT__Inser__58D0F1C6] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Mov_number_Ind] ON [dbo].[TMTMeterTransferHistoryTrl] ([Mov_number]) ON [PRIMARY]
GO
