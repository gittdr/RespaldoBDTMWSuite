CREATE TABLE [dbo].[edi_tender_partner]
(
[etp_ident] [int] NOT NULL IDENTITY(1, 1),
[etp_partnerId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[etp_partnerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[etp_sourceType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_sourceType] DEFAULT ('EDI'),
[etp_BatchNumber] [int] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_BatchNumber] DEFAULT ((0)),
[etp_AutoAccept] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_Response_AutoAccept] DEFAULT ((0)),
[etp_AcceptRequired] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_AcceptRequired] DEFAULT ((0)),
[etp_DeclineRequired] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_DeclineRequired] DEFAULT ((0)),
[etp_RequireReason] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_RequireReason] DEFAULT ((0)),
[etp_AllowReasonEditing] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_AllowReasonEditing] DEFAULT ((0)),
[etp_AllowReasonFreeForm] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_AllowReasonFreeForm] DEFAULT ((0)),
[etp_DefaultReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_DefaultReason] DEFAULT (''),
[etp_ExportPath] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_ExportPath] DEFAULT (''),
[etp_ResponseWarning] [int] NULL,
[etp_ResponseCritical] [int] NULL,
[etp_AutoDeclineWhenExpired] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_990_AutoDecline] DEFAULT ((0)),
[etp_CompanyID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_CompanyID] DEFAULT (''),
[etp_AcceptOnUpdate] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_AcceptOnUpdate] DEFAULT ((0)),
[etp_AcceptOnCancel] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_AcceptOnCancel] DEFAULT ((0)),
[etp_DeclineOnUpdate] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_DeclineOnUpdate] DEFAULT ((0)),
[etp_DeclineOnCancel] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_DeclineOnCancel] DEFAULT ((0)),
[etp_ExportWrapper] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etp_AllowAcceptText] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_AllowAcceptText] DEFAULT ((0)),
[etp_DefaultAcceptText] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etp_OverrideMaxUpdateStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etp_divertNew204s] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_divertNew204s] DEFAULT ((0)),
[etp_divertUpdate204s] [bit] NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_divertUpdate204s] DEFAULT ((0)),
[etp_divertRestrictBillto] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_edi_tender_partner_etp_divertRestrictBillto] DEFAULT ('UNKNOWN')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iudt_edi_tender_partner] ON [dbo].[edi_tender_partner]
FOR INSERT, UPDATE, DELETE
AS

IF (SELECT COUNT(1) FROM inserted) > 0 OR (SELECT COUNT(1) FROM deleted) > 0
BEGIN
	DELETE EDI_Trading_Partner_Master
	 WHERE tpm_TradingPartnerID IN (SELECT deleted.etp_partnerID FROM deleted 
			   LEFT JOIN inserted ON deleted.etp_partnerID = inserted.etp_partnerID
			  WHERE inserted.etp_partnerID IS NULL)
	
	UPDATE EDI_Trading_Partner_Master
	   SET	tpm_TradingPartnerName = etp_partnerName,
		tpm_Is990Partner = CASE WHEN etp_AcceptRequired = 1 OR etp_DeclineRequired = 1 THEN 1 ELSE 0 END,
		tpm_Is204Partner = 0,
		tpm_990BatchNumber = convert(varchar(45), etp_BatchNumber),
		tpm_990AcceptRequired = etp_AcceptRequired,
		tpm_990DeclineRequired = etp_DeclineRequired,
		tpm_990AllowReasonEditing = 0,
		tpm_990AllowReasonFreeForm = 0,
		tpm_990RequireReason = 0,
		dx_990DefaultReason = etp_DefaultReason,
		tpm_990AcceptOnUpdate = etp_AcceptOnUpdate,
		tpm_990AcceptOnCancel = etp_AcceptOnCancel,
		tpm_990DeclineOnUpdate = etp_DeclineOnUpdate,
		tpm_990DeclineOnCancel = etp_DeclineOnCancel
	  FROM	inserted
	 WHERE	tpm_TradingPartnerID = etp_partnerID

	INSERT EDI_Trading_Partner_Master
		(tpm_TradingPartnerID, tpm_TradingPartnerName, tpm_Is990Partner, tpm_Is204Partner, tpm_Is210Partner, 
		 tpm_Is214Partner, tpm_990BatchNumber, tpm_990AcceptRequired, tpm_990DeclineRequired, tpm_990AllowReasonEditing,
		 tpm_990AllowReasonFreeForm, tpm_990RequireReason, que_ID_204, que_ID_990, dx_990DefaultReason,
		 tpm_990AcceptOnUpdate,tpm_990AcceptOnCancel,tpm_990DeclineOnUpdate,tpm_990DeclineOnCancel)
	SELECT etp_partnerID, etp_partnerName, (case when etp_AcceptRequired = 1 or etp_DeclineRequired = 1 then 1 else 0 end),
		 1, 0, 0, convert(varchar(45), etp_BatchNumber), etp_AcceptRequired, etp_DeclineRequired, etp_AllowReasonEditing,
		 etp_AllowReasonFreeForm, etp_RequireReason, 'UNKNOWN', 'UNKNOWN', etp_DefaultReason,
		 etp_AcceptOnUpdate,etp_AcceptOnCancel,etp_DeclineOnUpdate,etp_DeclineOnCancel
	  FROM inserted
	 WHERE etp_partnerID NOT IN (SELECT tpm_TradingPartnerID FROM EDI_Trading_Partner_Master)
END
GO
ALTER TABLE [dbo].[edi_tender_partner] ADD CONSTRAINT [PK_edi_tender_partner] PRIMARY KEY CLUSTERED ([etp_partnerId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_tender_partner] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_tender_partner] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_tender_partner] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_tender_partner] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_tender_partner] TO [public]
GO
