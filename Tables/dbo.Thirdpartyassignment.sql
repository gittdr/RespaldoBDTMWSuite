CREATE TABLE [dbo].[Thirdpartyassignment]
(
[tpr_number] [int] NOT NULL IDENTITY(1, 1),
[tpr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[tpa_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[tpa_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [ThirdPartyAssignment_TPA_DEFAULT] DEFAULT ('N'),
[tpr_auto_rate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Thirdpart__tpr_a__3561679E] DEFAULT ('Y'),
[tpr_split] [money] NULL,
[tpr_split_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpa_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThirdPartyType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayScheduleId] [int] NULL,
[tpa_issellingagent] [bit] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__Thirdpart__INS_T__79B2C2A4] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_ThirdPartyAssignment] ON [dbo].[Thirdpartyassignment] FOR INSERT, UPDATE AS
BEGIN
	IF UPDATE(ord_number)
	BEGIN
		UPDATE	ThirdPartyAssignment
		   SET	ThirdPartyAssignment.ord_hdrnumber = orderheader.ord_hdrnumber
		  FROM	inserted
					INNER JOIN orderheader ON inserted.ord_number = orderheader.ord_number AND ISNULL(inserted.ord_hdrnumber, -999) <> orderheader.ord_hdrnumber
					INNER JOIN ThirdPartyAssignment ON inserted.tpr_number = ThirdPartyAssignment.tpr_number
	END
	IF UPDATE(ord_hdrnumber)
	BEGIN
		UPDATE	ThirdPartyAssignment
		   SET	ThirdPartyAssignment.ord_number = orderheader.ord_number
		  FROM	inserted
					INNER JOIN orderheader ON inserted.ord_hdrnumber = orderheader.ord_hdrnumber AND ISNULL(inserted.ord_number, '') <> orderheader.ord_number
					INNER JOIN ThirdPartyAssignment ON inserted.tpr_number = ThirdPartyAssignment.tpr_number
	END	
	IF (SELECT COUNT(*) FROM deleted) = 0
	BEGIN
		UPDATE	ThirdPartyAssignment
		   SET	ThirdPartyAssignment.tpa_default = 'Y'
		  FROM	inserted
		 WHERE	inserted.tpr_number = ThirdPartyAssignment.tpr_number
		   AND	inserted.tpa_status = 'AUTO'
	END
END
GO
ALTER TABLE [dbo].[Thirdpartyassignment] ADD CONSTRAINT [pk_tpr_number] PRIMARY KEY CLUSTERED ([tpr_number]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Thirdpartyassignment_INS_TIMESTAMP] ON [dbo].[Thirdpartyassignment] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_thirdpartyassignment_lgh_number] ON [dbo].[Thirdpartyassignment] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tpa_movnum_status] ON [dbo].[Thirdpartyassignment] ([mov_number], [tpa_status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_thirdpartyassignment_ord_hdrnumber] ON [dbo].[Thirdpartyassignment] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_thirdpartyassignment_ord_number] ON [dbo].[Thirdpartyassignment] ([ord_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Thirdpartyassignment] TO [public]
GO
GRANT INSERT ON  [dbo].[Thirdpartyassignment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Thirdpartyassignment] TO [public]
GO
GRANT SELECT ON  [dbo].[Thirdpartyassignment] TO [public]
GO
GRANT UPDATE ON  [dbo].[Thirdpartyassignment] TO [public]
GO
