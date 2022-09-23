CREATE TABLE [dbo].[ImagePaperworkLog]
(
[ipl_ID] [int] NOT NULL IDENTITY(1, 1),
[ipl_Date] [datetime] NOT NULL,
[ipl_callingproc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ipl_ordnum] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipl_doctype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipl_lghnumber] [int] NULL,
[ipl_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipl_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipl_carrierinvoice] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipl_invoiceamt] [money] NULL,
[ipl_HldPay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [INX_iplID] ON [dbo].[ImagePaperworkLog] ([ipl_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImagePaperworkLog] TO [public]
GO
GRANT INSERT ON  [dbo].[ImagePaperworkLog] TO [public]
GO
GRANT SELECT ON  [dbo].[ImagePaperworkLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImagePaperworkLog] TO [public]
GO
