CREATE TABLE [dbo].[TMTECMTransferHistory]
(
[Mov_number] [int] NULL,
[tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_miles] [float] NULL,
[ReverseEntry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__TMTECMTra__Rever__414380F8] DEFAULT ('N'),
[lgh_number] [int] NULL CONSTRAINT [DF__TMTECMTra__lgh_n__4237A531] DEFAULT ((0)),
[InsertDate] [datetime] NULL CONSTRAINT [DF__TMTECMTra__Inser__432BC96A] DEFAULT (getdate()),
[TRCorTRL] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Mov_number_Ind] ON [dbo].[TMTECMTransferHistory] ([Mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMTECMTransferHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[TMTECMTransferHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMTECMTransferHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[TMTECMTransferHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMTECMTransferHistory] TO [public]
GO
