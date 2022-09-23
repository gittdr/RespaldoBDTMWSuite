CREATE TABLE [dbo].[EDI_Trading_Partner_Master]
(
[Ident] [int] NOT NULL IDENTITY(1, 1),
[tpm_TradingPartnerID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tpm_TradingPartnerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tpm_Is990Partner] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_Is990Partner] DEFAULT (0),
[tpm_Is204Partner] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_Is204Partner1] DEFAULT (0),
[tpm_Is210Partner] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_Is210Partner2] DEFAULT (0),
[tpm_Is214Partner] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_Is214Partner3] DEFAULT (0),
[tpm_990BatchNumber] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EDITradingPartners_trp_990BatchNumber] DEFAULT (0),
[tpm_990AcceptRequired] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_trp_990AcceptRequired] DEFAULT (1),
[tpm_990DeclineRequired] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_trp_990DeclineRequired] DEFAULT (1),
[tpm_990AllowReasonEditing] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_dx_Allow990ReasonEditing] DEFAULT (0),
[tpm_990AllowReasonFreeForm] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_dx_Allow990ReasonFreeForm] DEFAULT (0),
[tpm_990RequireReason] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_dx_Require990Reason] DEFAULT (0),
[que_ID_204] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EDITradingPartners_dx_QueueIdent204] DEFAULT (1),
[que_ID_990] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EDITradingPartners_dx_QueueIdent990] DEFAULT (0),
[dx_990DefaultReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EDITradingPartners_dx_Default990Reason] DEFAULT (0),
[tpm_990AcceptOnUpdate] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_trp_AcceptOnUpdate] DEFAULT ((1)),
[tpm_990AcceptOnCancel] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_trp_AcceptOnCancel] DEFAULT ((1)),
[tpm_990DeclineOnUpdate] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_trp_DeclineOnUpdate] DEFAULT ((0)),
[tpm_990DeclineOnCancel] [bit] NOT NULL CONSTRAINT [DF_EDITradingPartners_trp_DeclineOnCancel] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_EDI_Trading_Partner_Master] ON [dbo].[EDI_Trading_Partner_Master]
FOR UPDATE
AS


IF UPDATE(tpm_990BatchNumber)
BEGIN
	UPDATE edi_tender_partner
	   SET	etp_BatchNumber = CASE ISNUMERIC(tpm_990BatchNumber) WHEN 1 THEN CONVERT(int, tpm_990BatchNumber) ELSE 0 END
	  FROM inserted
	 WHERE Ident = etp_ident
	   AND tpm_Is204Partner = 1

	UPDATE EDI_Trading_Partner_Master
	   SET EDI_Trading_Partner_Master.tpm_Is204Partner = 1
	  FROM inserted
	 WHERE EDI_Trading_Partner_Master.Ident = inserted.Ident
	   AND inserted.tpm_Is204Partner = 0
END
GO
ALTER TABLE [dbo].[EDI_Trading_Partner_Master] ADD CONSTRAINT [PK_EDITradingPartners] PRIMARY KEY CLUSTERED ([tpm_TradingPartnerID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EDI_Trading_Partner_Master] ADD CONSTRAINT [FK_EDI_Trading_Partner_que_ID_204] FOREIGN KEY ([que_ID_204]) REFERENCES [dbo].[dx_Queues] ([que_ID])
GO
ALTER TABLE [dbo].[EDI_Trading_Partner_Master] ADD CONSTRAINT [FK_EDI_Trading_Partner_que_ID_990] FOREIGN KEY ([que_ID_990]) REFERENCES [dbo].[dx_Queues] ([que_ID])
GO
GRANT DELETE ON  [dbo].[EDI_Trading_Partner_Master] TO [public]
GO
GRANT INSERT ON  [dbo].[EDI_Trading_Partner_Master] TO [public]
GO
GRANT REFERENCES ON  [dbo].[EDI_Trading_Partner_Master] TO [public]
GO
GRANT SELECT ON  [dbo].[EDI_Trading_Partner_Master] TO [public]
GO
GRANT UPDATE ON  [dbo].[EDI_Trading_Partner_Master] TO [public]
GO
