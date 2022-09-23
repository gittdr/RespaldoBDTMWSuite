CREATE TABLE [dbo].[excesshours]
(
[pyd_number] [int] NOT NULL,
[pyh_number] [int] NULL,
[lgh_number] [int] NULL,
[asgn_number] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivd_number] [int] NULL,
[pyd_prorap] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[pyd_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyr_ratecode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_quantity] [float] NULL,
[pyd_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_rate] [money] NULL,
[pyd_amount] [money] NULL,
[pyd_pretax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_glnum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_currency] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_currencydate] [datetime] NULL,
[pyd_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnumtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnum] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyh_payperiod] [datetime] NULL,
[pyd_workperiod] [datetime] NULL,
[lgh_startpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_startcity] [int] NULL,
[lgh_endpoint] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_endcity] [int] NULL,
[ivd_payrevenue] [money] NULL,
[pyd_revenueratio] [float] NULL,
[pyd_lessrevenue] [money] NULL,
[pyd_payrevenue] [money] NULL,
[pyd_transdate] [datetime] NULL,
[pyd_minus] [int] NULL,
[pyd_sequence] [int] NULL,
[std_number] [int] NULL,
[pyd_loadstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_xrefnumber] [int] NULL,
[ord_hdrnumber] [int] NULL,
[pyt_fee1] [money] NULL,
[pyt_fee2] [money] NULL,
[pyd_grossamount] [money] NULL,
[pyd_adj_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_id] [int] NULL,
[pyd_transferdate] [datetime] NULL,
[pyd_exportstatus] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_releasedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_billedweight] [int] NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psd_batch_id] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updsrc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_updatedon] [datetime] NULL,
[pyd_offsetpay_number] [int] NULL,
[pyd_credit_pay_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ivh_hdrnumber] [int] NULL,
[psd_number] [int] NULL,
[pyd_ref_invoice] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_ref_invoicedate] [datetime] NULL,
[pyd_ignoreglreset] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_authcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_PostProcSource] [smallint] NULL,
[pyd_GPTrans] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_hourlypaydate] [datetime] NULL,
[xsh_acceptflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xsh_LastUpdateBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xsh_LastUpdated] [datetime] NULL,
[xsh_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xsh_RecAdjType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_excesshours]
ON [dbo].[excesshours]
FOR  UPDATE
AS

/**
 * 
 * NAME:
 * dbo.it_excesshours
 *
 * TYPE:
 * [Trigger] 
 *
 * DESCRIPTION:
 * This trigger ensures the user id is set when the record is changed
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * none
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
* NONE 

 * 
 * REVISION HISTORY:
 * 11/07/2006.01 ? PTS35098 - DPETE created 
 * 4/19/08 PTS 40260 recode Pauls into main source
 **/
declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output
If not update(xsh_lastupdateby) 
   update excesshours
   set xsh_lastupdateby = @tmwuser
       ,xsh_lastupdated = getdate()
   from inserted where excesshours.pyd_number = inserted.pyd_number


GO
ALTER TABLE [dbo].[excesshours] ADD CONSTRAINT [PK_excesshours] PRIMARY KEY CLUSTERED ([pyd_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [INX_leg] ON [dbo].[excesshours] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_excesshours_xsh_acceptflag] ON [dbo].[excesshours] ([xsh_acceptflag]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[excesshours] TO [public]
GO
GRANT INSERT ON  [dbo].[excesshours] TO [public]
GO
GRANT SELECT ON  [dbo].[excesshours] TO [public]
GO
GRANT UPDATE ON  [dbo].[excesshours] TO [public]
GO
