CREATE TABLE [dbo].[paydetail_delete_reason]
(
[pyd_number] [int] NOT NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_quantity] [float] NULL,
[pyd_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_rate] [money] NULL,
[pyd_amount] [money] NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[pyd_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updsrc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updatedon] [datetime] NULL,
[pdr_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_paydetail_delete_reason] ON [dbo].[paydetail_delete_reason]
FOR  INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/* Revision History:
LOR	PTS# 32400	created
*/

declare	@reason	varchar(6),
		@seq	int
if exists(select * from generalinfo where gi_name = 'AuditPay' and upper(gi_string1) = 'Y')
Begin
	select @reason = pdr_reason,
			@seq = audit_sequence
	from inserted i, paydetailaudit a
	where audit_status = 'D' and i.pyd_number = a.pyd_number and i.asgn_type = a.asgn_type and i.asgn_id = a.asgn_id 

	update paydetailaudit 
	set audit_reason_del_canc = @reason
	where audit_sequence = @seq
End
GO
ALTER TABLE [dbo].[paydetail_delete_reason] ADD CONSTRAINT [pk_pdr_number] PRIMARY KEY CLUSTERED ([pyd_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paydetail_delete_reason] TO [public]
GO
GRANT INSERT ON  [dbo].[paydetail_delete_reason] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paydetail_delete_reason] TO [public]
GO
GRANT SELECT ON  [dbo].[paydetail_delete_reason] TO [public]
GO
GRANT UPDATE ON  [dbo].[paydetail_delete_reason] TO [public]
GO
